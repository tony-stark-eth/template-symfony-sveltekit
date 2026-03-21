<?php

declare(strict_types=1);

namespace Tests\Architecture;

use PHPat\Selector\Selector;
use PHPat\Test\Builder\Rule;
use PHPat\Test\PHPat;

/**
 * Enforces layer dependency direction:
 * services must not depend on controllers.
 */
final class LayerDependencyTest
{
    /**
     * Services must not import or depend on controllers.
     * Controllers depend on services, never the other way around.
     */
    public function testServicesDoNotDependOnControllers(): Rule
    {
        return PHPat::rule()
            ->classes(Selector::inNamespace('App\*\Service'))
            ->shouldNot()->dependOn()
            ->classes(Selector::inNamespace('App\*\Controller'));
    }
}
