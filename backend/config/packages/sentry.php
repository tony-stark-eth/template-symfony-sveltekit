<?php

declare(strict_types=1);

use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return static function (ContainerConfigurator $container): void {
    $container->extension('sentry', [
        'dsn' => '%env(SENTRY_DSN)%',
        'tracing' => [
            'enabled' => false,
        ],
        'messenger' => [
            'enabled' => true,
            'capture_soft_fails' => true,
        ],
    ]);
};
