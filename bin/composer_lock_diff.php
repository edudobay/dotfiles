#!/usr/bin/env php
<?php

/**
 * @return array{name: string, section: string, version: string, sourceReference: null|string}
 */
function get_package_data(array $package, string $section): array {
        $version = $package['version'];
        $sourceRef = $package['source']['reference'] ?? null;
        return [
            'name' => $package['name'],
            'section' => $section,
            'version' => $version,
            'sourceReference' => $sourceRef,
        ];
}

/**
 * @return array<string, array{section: string, version: string, sourceReference: string}>
 */
function get_versions(array $doc): array {
    $packages = [];
    foreach ($doc['packages'] ?? [] as $package) {
        $packageData = get_package_data($package, section: '');
        $packages[$packageData['name']] = $packageData;
    }
    foreach ($doc['packages-dev'] ?? [] as $package) {
        $packageData = get_package_data($package, section: 'dev');
        $packages[$packageData['name']] = $packageData;
    }
    return $packages;
}

function compare(array $packages1, array $packages2): array {
    $packages = array_fill_keys(array_keys(array_merge($packages1, $packages2)), []);

    foreach ($packages as $name => &$data) {
        if (! isset($packages2[$name])) {
            $data = ['result' => 'removed', ...$packages1[$name]];
            continue;
        }
        if (! isset($packages1[$name])) {
            $data = ['result' => 'added', ...$packages2[$name]];
            continue;
        }

        if (($p1 = $packages1[$name]) === ($p2 = $packages2[$name])) {
            $data = ['result' => 'unchanged'];
            continue;
        }

        $data = [
            'result' => 'changed',
            'name' => $name,
            'section' => [$p1['section'], $p2['section']],
            'version' => [$p1['version'], $p2['version']],
            'sourceReference' => [$p1['sourceReference'], $p2['sourceReference']],
        ];
    }
    unset($data);

    ksort($packages);

    return $packages;
}

$file1 = str_replace('/proc/self/fd/', 'php://fd/', $argv[1]);
$file2 = str_replace('/proc/self/fd/', 'php://fd/', $argv[2]);
$file1 = file_get_contents($file1);
$file2 = file_get_contents($file2);

$doc1 = json_decode($file1, true, flags: JSON_THROW_ON_ERROR);
$doc2 = json_decode($file2, true, flags: JSON_THROW_ON_ERROR);

$v1 = get_versions($doc1);
$v2 = get_versions($doc2);

$diff = compare($v1, $v2);

$output = array_filter($diff, fn (array $r) => $r['result'] !== 'unchanged');
echo json_encode($output, flags: JSON_PRETTY_PRINT), "\n";
