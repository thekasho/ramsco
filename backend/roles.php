<?php
/**
 * Role helpers for Field Ledger 2.1
 * Requires user_roles + roles tables (upgrade-to-2.1.0.sql).
 */

function currentUserId() {
    return isset($_SESSION['user_id']) ? (int)$_SESSION['user_id'] : 0;
}

/** @return string[] role codes for current user */
function currentUserRoles($pdo = null) {
    static $cache = null;
    if ($cache !== null) return $cache;
    $uid = currentUserId();
    if ($uid <= 0) {
        $cache = [];
        return $cache;
    }
    try {
        if (!$pdo) {
            require_once __DIR__ . '/db.php';
            $pdo = getDB();
        }
        $st = $pdo->prepare('SELECT role_code FROM user_roles WHERE user_id = ?');
        $st->execute([$uid]);
        $cache = $st->fetchAll(PDO::FETCH_COLUMN) ?: [];
    } catch (Exception $e) {
        // Pre-2.1 DB: treat logged-in user as admin
        $cache = ['admin'];
    }
    if (!$cache) $cache = ['admin']; // legacy single-user
    return $cache;
}

function userHasRole($role, $pdo = null) {
    $roles = currentUserRoles($pdo);
    if (in_array('admin', $roles, true)) return true;
    if (is_array($role)) {
        foreach ($role as $r) {
            if (in_array($r, $roles, true)) return true;
        }
        return false;
    }
    return in_array($role, $roles, true);
}

/**
 * Roles allowed to write financial / costing data.
 * admin always passes via userHasRole.
 */
function requireCostWriteApi($pdo = null) {
    requireLoginApi();
    if (!userHasRole(['admin', 'cost_accountant', 'supervisor'], $pdo)) {
        http_response_code(403);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['error' => 'Forbidden — cost write requires cost_accountant, supervisor, or admin'], JSON_UNESCAPED_UNICODE);
        exit;
    }
}

function requireAdminApi($pdo = null) {
    requireLoginApi();
    if (!userHasRole('admin', $pdo)) {
        http_response_code(403);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['error' => 'Forbidden — admin only'], JSON_UNESCAPED_UNICODE);
        exit;
    }
}

function listRoles($pdo) {
    try {
        return $pdo->query('SELECT code, label_en, label_ar, sort_order FROM roles ORDER BY sort_order, code')->fetchAll(PDO::FETCH_ASSOC) ?: [];
    } catch (Exception $e) {
        return [];
    }
}

function listUsersWithRoles($pdo) {
    try {
        $users = $pdo->query('SELECT id, username, display_name, is_active FROM users ORDER BY id')->fetchAll(PDO::FETCH_ASSOC) ?: [];
    } catch (Exception $e) {
        $users = $pdo->query('SELECT id, username FROM users ORDER BY id')->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }
    $map = [];
    try {
        $rows = $pdo->query('SELECT user_id, role_code FROM user_roles')->fetchAll(PDO::FETCH_ASSOC) ?: [];
        foreach ($rows as $r) {
            $map[(int)$r['user_id']][] = $r['role_code'];
        }
    } catch (Exception $e) { /* empty */ }
    foreach ($users as &$u) {
        $u['id'] = (int)$u['id'];
        $u['roles'] = $map[$u['id']] ?? ['admin'];
        if (!isset($u['display_name'])) $u['display_name'] = null;
        if (!isset($u['is_active'])) $u['is_active'] = 1;
    }
    return $users;
}

function setUserRoles($pdo, $userId, $roleCodes) {
    $userId = (int)$userId;
    if ($userId <= 0) throw new InvalidArgumentException('user_id required');
    $pdo->prepare('DELETE FROM user_roles WHERE user_id = ?')->execute([$userId]);
    $ins = $pdo->prepare('INSERT INTO user_roles (user_id, role_code) VALUES (?, ?)');
    foreach ((array)$roleCodes as $code) {
        $code = trim((string)$code);
        if ($code === '') continue;
        $ins->execute([$userId, $code]);
    }
    return true;
}
