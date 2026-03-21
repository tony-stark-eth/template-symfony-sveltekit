<?php

declare(strict_types=1);

namespace Tests\Architecture;

use PHPat\Selector\Selector;
use PHPat\Test\Builder\Rule;
use PHPat\Test\PHPat;

/**
 * Enforces naming conventions across the codebase.
 */
final class NamingConventionTest
{
    /**
     * All classes inside an Exception namespace must extend RuntimeException.
     * This prevents non-exception classes from living in the Exception namespace.
     */
    public function testExceptionNamespaceContainsOnlyExceptions(): Rule
    {
        return PHPat::rule()
            ->classes(Selector::inNamespace('App\*\Exception'))
            ->should()->extend()
            ->classes(Selector::classname(\RuntimeException::class));
    }
}
