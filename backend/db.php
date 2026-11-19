<?php
/**
 * A single shared PDO connection, created on first use.
 * Throws on any query error (ERRMODE_EXCEPTION) rather than failing
 * silently — callers should wrap writes in try/catch where they need
 * to report a friendly error back to the page or the API.
 */
require_once __DIR__ . '/config.php';

function getDB() {
    static $pdo = null;
    if ($pdo === null) {
        $dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4';
        $pdo = new PDO($dsn, DB_USER, DB_PASS, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]);
    }
    return $pdo;
}

// Turns '' into NULL for optional DATE columns — MySQL rejects '' as a date.
function nullIfEmpty($value) {
    return ($value === null || $value === '') ? null : $value;
}
function db(){return getDB();}
