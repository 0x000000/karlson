[[https://github.com/0x000000/karlson/blob/master/docs/karlson.jpg]]

This code is written for educational reasons as a part of research I have done around 2012-2013.
It was inspired by CORBA, SOAP and early implementations of Google's Protobuf (before 3rd version).

# General idea (or Why?)

Main statement — RESTful way is not always the best way to organize JSON API.

To explain why I think so, I am going to use a pseudocode without handling various corner cases, errors, exceptions etc.
UI/UX is not a part of this conversation also.

Let's talk about bank accounts. Here is a simple UI mock:

[[https://github.com/0x000000/karlson/blob/master/docs/account_card.png]]


What we can do here:
* check account info: number and balance
* add funds (from nowhere)
* remove funds (to nowhere)

How many conceptions we can introduce from this mock (if we forget about session, auth system, I18n and so on for this example)?
At least two for now: User and Account. As a developer with some accounting background, I can say that
isolated immutable transactions is a good approach to manage money from many perspectives:
clean architecture, simple history handling, easy to rollback state. So we will
use another entity to describe manipulations with accounts: Transaction.

RESTful url schema can looks like:

Check account info: `GET /account`
Add funds: `POST /account/transaction/create` with `amount=<requred ammount>` in params
Remove funds: `POST /account/transaction/create` with `amount=<requred ammount>` in params

Everything looks good, but what if we add new requirements:

[[https://github.com/0x000000/karlson/blob/master/docs/many_users_many_accs.png]]


Now our UI should be able to support multiple users
Now our user should be able to have multiple accounts

Here is a new look of our schema:

```
  GET user/:user_id/accounts
  POST user/:user_id/account/:account_id/transaction/create
```

### 1st target

Let's say we want to allow our admins to transfer money between different accounts among different users:

[[https://github.com/0x000000/karlson/blob/master/docs/transfer_funds.png]]

It will require different scheme like `POST accounts/transfer/create`
So we ended with two paths for accounts: `/accounts` and `user/:user_id/accounts`.

For big apps with many cross-relations it can be confusing to have different roots for the same entity.
And this will be the first target for optimization:

**1**. Do not let internal code organization structure affect client's API. Let client work with object hierarchy as flat as possible.

### 2nd target

What if we want to use obfuscated ids for users and accounts with special rule that denies all visually similar symbols
and lets using only one of them. `0`, `o` and `O` look similar in some fonts, so we can allow only zero symbol.
The same situation with `Q` (may looks like 0), `I` (== 1 or == l) and `l` (==I or ==l).
So now it's harder to make a mistake while dictating such number as "01Hg4u1" by phone call.

Our API client can form url like this `GET user/01Hg4u1/accounts`, but how to tell them that O1Hg4uI is invalid id before
submitting this information to our app? We can write this as regexp (Ruby): `/\A[0-9a-zA-Z&&[^oOIl]]\Z/` but it's
hard to declare such knowledge for clients within classic REST way.

This is our second target:
**2**. Move url composing logic from request's endpoint to request's body. Make sure that every app's endpoint uses only
static names without any variable parts.

### 3rd target

What if we want to gather information about all accounts for users: A, B and C?
We can do 3 requests in row like:

```
GET user/A/accounts
GET user/B/accounts
GET user/C/accounts
...
```

(which is not a perfect solution by any terms, what if we want to request 100 users?)

or we can create a new endpoint to request such information?: `GET users/accounts` with params `users_ids=<array of user ids>`,
because we need both User and Account entities.
What about User + Account + Transactions? `GET users/accounts/transactions`?

What if we want to pick only some accounts from some users? Moreover, what if we want to perform a batch of actions over these
accounts, like mass freezing; and do so in one request? Seems like we have to create tons of separate endpoints for single actions and for batched actions.

Looks like we have a 3rd target:
**3**. Provide an easy way to query many objects and execute many commands as part of the one request/responce cycle.


### Additional target:
Do not mess with messaging protocols, describe only format of messages. (Hello Thrift'12, with hardcoded jQuery-ajax transport as only one option available for browsers!)

# Possible implementation (or How?)

Let's describe all entities again, but with more attention to detail this time. I am going to use ActonScript 3/TypeScript-like syntax.

We are going to use two user-defined types `ObfuscatedId` and `Money`:

```
type ObfuscatedId {
  value: String, allow_chars: "0123456789abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPRSTUVWXYZ"
  // remove o, O, Q, I, l
  // sadly we can't use lang-specific regexps here, because we need to translate this to all target languages
}

type Money {
  value: Float, precision: 2, max: ..., min: 0.01
  // our backend can store real data with any precision we need,
  // but to simplify interacting with clients we can say that 1 cent is a minimum possible value
}
```

We also need enum to describe variety of Transaction types:

```
enum TransactionType {
  ADD_FUNDS:    0
  REMOVE_FUNDS: 1
}

// to perform bitwise operation with enums it can be declared in the following way:

enum TransactionType {
  ADD_FUNDS:    1 << 0
  REMOVE_FUNDS: 1 << 1
  SMTHING_ELSE: 1 << 2
  // ...
}
```

Now we are ready to declare major domain objects:

```
object Transaction {
  type: TransactionType
  amount: Money
}

object Account {
  id: ObfuscatedId
  totals: Money
  transactions: Array of Transaction
}

object User {
  id: ObfuscatedId
  accounts: Array of Account
}
```

Let's try to describe all requests' and responses' parameters similar to our GET requests above:

```
request AllTransactionsRequest {}

response TransactionsResponse {
  for AllTransactionsRequest

  transactions: Array of Transaction
}

object AccountDetails {
  id: ObfuscatedId
  transactionsRequest: AllTransactionsRequest
}

request AccountRequest {
  accountDetails: AccountDetails
}

response AccountResponse {
  for AccountRequest

  account: Account
}

object AllAccountsDetails {
  transactionsRequest: AllTransactionsRequest
}

request AllAcountsRequest {
  accountDetails: AllAccountsDetails
}
request AccountsRequest {
  accountDetails: Array of AccountDetails
}

response AccountsResponse {
  for AllAcountsRequest, AccountsRequest

  accounts: Array of Account
}


object UserDetails {
  id: ObfuscatedId
  accountRequest: AccountRequest, AccountsRequest, AllAcountsRequest
}

request UserRequest {
  userDetails: UserDetails
}

response UserResponse {
  for UserRequest

  user: User
}


request UsersRequest {
  userDetails: Array of UserDetails
}

response UsersResponse {
  for UsersRequest

  users: Array of User
}
```

Seems like a big wall of code, but actually we can do many flexible things with it, like:

* requesting some user with all accounts without transactions:

```
accountRequest: AllAccountsRequest = new AllAccountsRequest()
userDetails: UserDetails = new UserDetails(id: "A", accountRequest: accountRequest)
request: UserRequest = new UserRequest(userDefails: userDetails)

send(request) // should return UserResponse object
```

* requesting specific users with specific accounts with and without transactions (depends on user):

```
// show all accounts for user A but without transactions
accountRequestA: AllAccountsRequest = new AllAccountsRequest()
userDetailsA: UserDetails = new UserDetails(id: "A", accountRequest: accountRequest)

// show two accounts (B1 and B2) for user B, show account B1 with transactions and B2 — without
accountDetailsB1: AccountDetails = new AccountDetails(id: "B1", transactionsRequest: new AllTransactionsRequest())
accountDetailsB2: AccountDetails = new AccountDetails(id: "B2")
accountsRequestB: AccountsRequest = new AccountsRequest(accountsDetails: [accountDetailsB1, accountDetailsB2])
userDetailsB: UserDetails = new UserDetails(id: "B", accountRequest: accountsRequestB)

request: UsersRequest = new UsersRequest(userDefails: [userDetailsA, userDetailsB])

send(request) // should return UsersResponse object

```

Second example is a bit overkill, but I am trying to explain all possible scenarios.

With the same principle it's possible to implement everything we need, e.g:

* requesting some objects without obligate nesting to other (like Accounts without Users):

```
request: AccountsRequest = new AccountsRequest(accountsDetails: [
  new AccountDetails(id: "B1"),
  new AccountDetails(id: "B2"),
  new AccountDetails(id: "B3"),
])

send(request)

```

* simple updates:

```
object TransactionDetails {
  account_id: ObfuscatedId
  transaction: Transaction
}

request ApplyTransaction {
  transactionDetails: TransactionDetails
}

transaction: Transaction = new Transaction(type: TransactionType.ADD_FUNDS, amount: 100.05)
details: TransactionDetails = new TransactionDetails(account_id: "A", transaction: transaction)
request: ApplyTransaction = new ApplyTransaction(transactionDetails: details)

send(request)

```

* batch updates:

```
request ApplyTransactions {
  transactionDetails: Array of TransactionDetails
}

transactionA: Transaction = new Transaction(type: TransactionType.REMOVE_FUNDS, amount: 100.05)
transactionB: Transaction = new Transaction(type: TransactionType.ADD_FUNDS, amount: 100.05)

detailsA: TransactionDetails = new TransactionDetails(account_id: "A", transaction: transactionA)
detailsB: TransactionDetails = new TransactionDetails(account_id: "B", transaction: transactionB)

request: ApplyTransactions = new ApplyTransactions(transactionDetails: [detailsA, detailsB])

send(request)
```

* additional validations:

```
object UserDetails {
  id: ObfuscatedId, required: true
  accountRequest: AccountRequest, AccountsRequest, AllAcountsRequest, allow_empty: true
}

```

Conclusion:

**1**. It's possible to explicitly declare app domain objects. Everyone will benefit from that fact: internal team can reuse
types, enums and objects (as well as validations/restrictions), external clients can use predefined architecture
without worrying of reinventing everything with different abstractions.

**2**. App can use only one endpoint for all messages per application (like /bus)
or declare a few specific endpoints (e.g. /chat, /accounting) to narrow backend code responsibility.
Moving all variable metadata to message itself removes problem with REST-like url constructions and
additional validations.

Strict typing on the message body level allows developers to handle clients messages in async way
(of course if it is acceptable for current situation) by organizing a few queues:

1) queue for all raw messages from clients: M
2) queue for validated messages: validated(M)
3) queue for validated messages when client authenticated and authorized to perform such request: auth(validated(M))

So main app code can pick processed messages only from 3rd queue and skip auth code and schema validation, focusing
only on business related logic.

**3**. Complex requests (with complex responses) can be declared and performed simply.


# About this repo (or OMG man finally!)

This code is my attempt to implement all the stuff described above.
Sadly, but I abandoned this project to move all my free time to [my another project](https://www.instagram.com/p/BJcpRGFBCAf/?taken-by=arudenka).


What were done:
* [good name](https://www.wikiwand.com/en/Karlsson-on-the-Roof) for gem (50% of work is done by this point)
* basic DSL with easy type system
* implementation of `object` (`pack` in terms of this library)
* implementation of `enum`
* simple validation system
* code structure and some very basic attempts to compile DSL to target lang objects/classes
* actually I implemented part of js integration with specs, but I deleted that code because it
 was a prototype to play with idea, not a production-grade code.
* tests

What should be done:
* versioning system with Rails-like transactions to change schema
* `request/response` objects based on `pack` functionality
* user-defined `types` — pseudo-primitive types for inline replacing in DSL with additional validations/restrictions
* DSL to Ruby and DSL to es5 translations + tests
* Small libraries to support schema validations for ruby and js code + tests


## Major decisions

I decided that using `yacc` is a overkill for this project by three reasons:
1) There is nothing to put in "tree", so instead of AST there is only a flat list.
2) Because of 1) I tried to create a very simple way to extend library to support another languages
Seems like not everyone is familiar with tools like `yacc` but almost every web-developer is good with
"templates" concept.
3) yacc'12 was a great tool with terrible way to create good error messages about "what's going wrong with this DSL".
So I choose plain Ruby for that.

## Overview

Main gem structure (please take a look at appropriate `specs/` files for more details):

```
gem's root
|
+-- readers/
|   |  # you may think about readers as of dead simple lexer/parsers to translate DSL into
|   |  # lists of simple tokens
|   |
|   +-- empty_object.rb
|   |    # my attempt to create a blank-state object for DSL
|   |    # you can use all internal BasicObject methods
|   |    # such as initialize, __send__ or __id__
|   |    # as a valid DSL field names without any problems
|   |    # so as a client programmer you should not worry about
|   |    # knowlege of Ruby internals and use any words you want
|   |
|   +-- enum_reader.rb
|   +-- pack_reader.rb
|   |    # declare methods to transform DSL blocks to list of tokens for enums and objects
|   |
|   +-- types_registry.rb
|        # singleton to keep records about all tokens defined in DSL
|
|
+-- writers/
|   |  # writers transform tokens from DSL to end-point language using .erb templates
|   |  # (or at least should do so in theory)
|   |
|   +-- base_render.rb
|   |    # superclass for all renders, its main purpose — simplify work with erb templates
|   |    # by providing Rails-like name conventions for templates
|   |    # in terms of gem, render transforms tokens to source string, acceptable by some language
|   |
|   +-- base_writer.rb
|   |    # superclass for readers — auxillary classes to translate rendered strings into files and directories
|   |    # structure, common for target language
|   |    # provides simple DSL to do so (right, DSL inside DSL)
|   |
|   +-- javascript/
|   +-- ruby/
|   +-- etc/
|        # it supposed to be a language-specific implementation of writers and rendereres
|
+-- validation/
|    # set of validations for internal error messages and DSL checks
|    # you can think about them as a programming contracts moved to runtime
|
+-- dsl.rb
|    # all methods available for top-level of config DSL file
```

Accounts example re-written in gem's DSL:

```ruby
enum :transaction_type do
  add_funds    0
  remove_funds 1
end

pack :transaction do
  type 1, :transaction_type
  amount 2, :number
end

pack :account do
  id 1, :string
  totals 2, :number
  transactions 3, [:transaction]
end

pack :user do
 id 1, :string
 accounts 2, [:account]
end
```


## How to run tests

```
$ git clone git@github.com:0x000000/karlson.git
$ cd karlson
$ bundle
$ rspec --format=doc
```

## Useful links:

All described here can be implemented on top of these great libraries:

* [Protobuf 3 + JSON serializer](https://developers.google.com/protocol-buffers/docs/proto3#json)
* [GraphQL](http://graphql.org/)
