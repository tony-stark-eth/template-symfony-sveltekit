<?php

declare(strict_types=1);

use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return static function (ContainerConfigurator $container): void {
    $container->extension('framework', [
        'cache' => [
            'pools' => [
                'doctrine.system_cache_pool' => [
                    'adapter' => 'cache.adapter.system',
                ],
                'doctrine.result_cache_pool' => [
                    'adapter' => 'cache.adapter.system',
                ],
            ],
        ],
    ]);
};
