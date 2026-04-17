# Guidelines

Development guidelines for AI agents and developers.

## Installation

```bash
composer require maarheeze/guidelines --dev
```

## With Laravel Boost

If using Laravel Boost, also install:

```bash
composer require maarheeze/boost-guidelines --dev
php artisan boost:install
php artisan boost:update --discover
```

This automatically discovers and loads guidelines from all installed packages with `.ai/guidelines/`.

## Override in Your Project

Add `.ai/guidelines/` files to override any guideline.