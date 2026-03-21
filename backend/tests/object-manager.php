<?php

declare(strict_types=1);

use App\Kernel;
use Doctrine\Persistence\ObjectManager;

require dirname(__DIR__) . '/vendor/autoload.php';

$kernel = new Kernel('test', true);
$kernel->boot();

$container = $kernel->getContainer();

/** @var ObjectManager $objectManager */
$objectManager = $container->get('doctrine')->getManager();

return $objectManager;
