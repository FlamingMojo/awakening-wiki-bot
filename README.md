# Awakening Wiki Bot

A simple Discord Bot for linking user's MediaWiki and Discord accounts for the [Dune: Awakening Community Wiki](https://awakening.wiki).

## Requirements

While this bot is made for the Awakening wiki primarily, it could be used on other discord servers to link any MediaWiki accounts.
This does not provide user sign in (OAuth) but from the Discord, nor has any persistent storage itself, instead using hidden wiki pages.
 
 * A [MediaWiki](https://www.mediawiki.org) Server with emailing enabled
 * The [Lockdown Extension](https://www.mediawiki.org/wiki/Extension:Lockdown) to prevent unauthorised edits to verification pages
   * Configure the Lockdown by adding the following to `LocalSettings.php`. This creates a protected namespace `Discord_verification:`
   ```php
    wfLoadExtension( 'Lockdown' );
    $wgExtraNamespaces[3100] = 'Discord_verification';
    $wgExtraNamespaces[3101] = 'Discord_verification_talk';
    $wgNamespacePermissionLockdown[3100]['*'] = [ 'sysop' ];
    $wgNamespacePermissionLockdown[3101]['*'] = [ 'sysop' ];
   ```
 * A Wiki bot user. See [The Docs](https://www.mediawiki.org/wiki/Manual:Bots) with the following permissions:
   * Edit existing pages
   * Edit protected pages
   * Create, edit, and move pages
   * Delete pages, revisions, and log entries
   * Protect and unprotect pages
   * Send email to other users
 * A Discord Bot - See [The Discord Developer Portal](https://discord.com/developers) with the following grants:
   * Use Slash Commands

## Installation

To Be Added. TL;DR: Add all .env vars with secrets and run `ruby ./bot.rb`

## TODO
 - Help command
 - Wiki Page to explain how to use
 - Adding custom discord verified user group?

