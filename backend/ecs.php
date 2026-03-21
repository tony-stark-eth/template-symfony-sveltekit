<?php

declare(strict_types=1);

use Symplify\EasyCodingStandard\Config\ECSConfig;

return ECSConfig::configure()
    ->withPaths(['src', 'tests'])
    ->withPreparedSets(
        psr12: true,
        common: true,
        strict: true,
        cleanCode: true,
    );
