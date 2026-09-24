# Labeling Guide

This guide defines how reviews are categorized in this project. It is used for hand-labeling the training and test data and keeps labels consistent.

## Categories

| Category | What it covers | Example review |
|---|---|---|
| Bank connection / sync | Accounts won't link, missing or duplicated transactions, wrong balances, constant re-authorization | "Loses connection with my bank and resets all my data when I reconnect." |
| Bugs & performance | Crashes, freezing, slow loading, errors, features not working as intended | "App is poorly optimized for Android making it slow and glitchy." |
| Pricing & subscription | Price complaints, paywalls, trials, unexpected charges, difficulty canceling, bill negotiation fees | "Been trying to cancel since October. They keep taking my money." |
| Usability & design | Confusing interface, hard navigation, disliked redesigns, steep learning curve | "The new UI is so clunky. I do not like the most recent update." |
| Missing features | Feature requests or expected features that aren't there | "Would be a five star app if the widgets weren't iOS exclusive." |
| Account, login & support | Can't log in, verification problems, closed accounts, unhelpful or unreachable customer support | "Can't log in anymore and no way to change my phone number." |
| Ads & upselling | Too many ads, pushy upgrade offers, sales calls, product recommendations | "Tired of seeing the ads every 5 minutes." |
| Praise | Positive reviews with no specific complaint | "Easy to use. Love it." |
| Other / off-topic | Credit score or credit report topics, vague reviews, gibberish, anything unrelated to budgeting | "The credit scores aren't accurate." |

## Labeling rules

1. **One label per review.** Choose the main issue: the one the user emphasizes most, or mentions first if unclear.
2. **Complaints beat praise.** A mixed review ("love the app but sync keeps failing") gets the complaint category, not Praise.
3. **Vague reviews:** short positive reviews ("great", "good app") are Praise; short negative reviews with no specific issue ("horrible", "bad") are Other.
4. **Rating doesn't decide the label.** Label the text, not the stars. A 2-star review saying "Great app" is Praise.
5. **Credit score reviews are Other.** This project focuses on budgeting, so Credit Karma's credit score and credit report reviews go in Other.
6. **Mint mentions are not a category.** They are tracked separately in the `mentions_mint` column.
7. **When unsure, write a note.** Tricky cases go in the notes column and, if they come up repeatedly, into the list below.

## Tricky cases

| Review type | Label | Why |
|---|---|---|
| Login fails because of a bug ("fingerprint login broken") | Account, login & support | Login problems are grouped together regardless of cause |
| Subscriptions not detected (Rocket Money) | Bank connection / sync | It's a data-detection problem, like missing transactions |
| Wrong calculations (net worth, categories) | Bugs & performance | The app produces incorrect results |
| "Not as good as Mint" with no specific issue | Usability & design | Usually about overall experience; use a specific category if one is named |
| Web version better than mobile app | Usability & design | Unless a specific missing feature is named |
| Hard to cancel a subscription | Pricing & subscription | Cancellation is part of the billing experience |

## Change history

- **v2:** After labeling a pilot sample of 160 reviews (40 per app, balanced across star ratings), "Privacy & trust" was renamed "Ads & upselling" because nearly all its reviews were about ads, and "Customer support" was expanded into "Account, login & support" because login and account problems had no fitting category and support complaints were too few on their own.
- **v1:** Initial nine categories defined before reading the data.