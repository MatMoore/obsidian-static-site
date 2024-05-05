# Obsidian static site generator

**This is currently a work in progress and is not ready to be used by anyone else. If you are interested in collaborating, please raise an issue.**

## Purpose

This is a limited static site generator that generates a website from a directory containing markdown notes (e.g. a vault created by [Obsidian](https://obsidian.md/)).

## Why not use an existing static site framework?

I find static site frameworks tend to have a steep learning curve, and come with a lot of features I don't need. For this project I found it more interesting to just roll my own than spend time wrestling with a 3rd party framework.

I also want my site to generate quickly, so it's useful to have full control over the generation process.

## Why not pay for Obsidian Publish?

I think the pricing is quite expensive for what you get, and I'd rather not rely on subscription software that I could lose access to at short notice.

## Obsidian parser gem

The code for parsing the contents of the vault is available as a gem, [obsidian-parser](https://github.com/MatMoore/obsidian-parser).

## Local development

- Clone this repo
- Clone `obsidian-parser`
- In this repo:
  - `gem install bundler`
  - `bundle config set local.obsidian_parser ../obsidian-parser`
  - `bundle install`

## Usage

- `bundle exec generator.rb`

## Licence

MIT
