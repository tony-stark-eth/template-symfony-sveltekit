<?php

declare(strict_types=1);

use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return static function (ContainerConfigurator $container): void {
    $container->extension('doctrine', [
        'dbal' => [
            'url' => '%env(resolve:DATABASE_URL)%',
        ],
        'orm' => [
            'enable_native_lazy_objects' => true,
            'entity_managers' => [
                'default' => [
                    'naming_strategy' => 'doctrine.orm.naming_strategy.underscore_number_aware',
                    'auto_mapping' => true,
                    'validate_xml_mapping' => true,
                    'mappings' => [
                        'App' => [
                            'type' => 'attribute',
                            'is_bundle' => false,
                            'dir' => '%kernel.project_dir%/src',
                            'prefix' => 'App\\',
                            'alias' => 'App',
                        ],
                    ],
                ],
            ],
        ],
    ]);

    if ($container->env() === 'test') {
        $container->extension('doctrine', [
            'dbal' => [
                'dbname_suffix' => '_test%env(default::TEST_TOKEN)%',
            ],
        ]);
    }

    if ($container->env() === 'prod') {
        $container->extension('doctrine', [
            'orm' => [
                'entity_managers' => [
                    'default' => [
                        'metadata_cache_driver' => ['type' => 'pool', 'pool' => 'doctrine.system_cache_pool'],
                        'result_cache_driver' => ['type' => 'pool', 'pool' => 'doctrine.result_cache_pool'],
                    ],
                ],
            ],
        ]);
    }
};
