AdminPanel.Settings = AdminPanel.Settings || {};

AdminPanel.Settings.DEFAULTS = {
    darkMode: true,
    seeThrough: false,
    notifications: true,
    showPlayerGraph: true,
    smallMode: true,
    theme: 0,
    font: 0,
    posTop: null,
    posLeft: null
};

AdminPanel.Settings.STORAGE_PREFIX = '919-admin:setting:';

AdminPanel.Settings.init = function() {
    AdminPanel.Settings.loadAll();
};

AdminPanel.Settings.save = function(key, value) {
    try {
        const storageKey = AdminPanel.Settings.STORAGE_PREFIX + key;
        localStorage.setItem(storageKey, JSON.stringify(value));
        return true;
    } catch (error) {
        console.error('Failed to save setting:', key, error);
        return false;
    }
};

AdminPanel.Settings.load = function(key, defaultValue = null) {
    try {
        const storageKey = AdminPanel.Settings.STORAGE_PREFIX + key;
        const value = localStorage.getItem(storageKey);
        
        if (value === null) {
            return defaultValue !== null ? defaultValue : AdminPanel.Settings.DEFAULTS[key];
        }
        
        return JSON.parse(value);
    } catch (error) {
        console.error('Failed to load setting:', key, error);
        return defaultValue !== null ? defaultValue : AdminPanel.Settings.DEFAULTS[key];
    }
};

AdminPanel.Settings.loadAll = function() {
    const settings = {};
    
    Object.keys(AdminPanel.Settings.DEFAULTS).forEach(key => {
        settings[key] = AdminPanel.Settings.load(key);
    });
    
    AdminPanel.Settings.current = settings;
    return settings;
};

AdminPanel.Settings.get = function(key) {
    if (!AdminPanel.Settings.current) {
        AdminPanel.Settings.loadAll();
    }
    return AdminPanel.Settings.current[key];
};

AdminPanel.Settings.set = function(key, value) {
    if (!AdminPanel.Settings.current) {
        AdminPanel.Settings.loadAll();
    }
    
    AdminPanel.Settings.current[key] = value;
    return AdminPanel.Settings.save(key, value);
};

AdminPanel.Settings.clear = function() {
    try {
        Object.keys(AdminPanel.Settings.DEFAULTS).forEach(key => {
            const storageKey = AdminPanel.Settings.STORAGE_PREFIX + key;
            localStorage.removeItem(storageKey);
        });
        AdminPanel.Settings.current = { ...AdminPanel.Settings.DEFAULTS };
        return true;
    } catch (error) {
        console.error('Failed to clear settings:', error);
        return false;
    }
};

AdminPanel.Settings.export = function() {
    return { ...AdminPanel.Settings.current };
};

AdminPanel.Settings.import = function(settings) {
    try {
        Object.entries(settings).forEach(([key, value]) => {
            if (AdminPanel.Settings.DEFAULTS.hasOwnProperty(key)) {
                AdminPanel.Settings.set(key, value);
            }
        });
        return true;
    } catch (error) {
        console.error('Failed to import settings:', error);
        return false;
    }
};

AdminPanel.Settings.resetPosition = function() {
    AdminPanel.Settings.set('posTop', null);
    AdminPanel.Settings.set('posLeft', null);
    console.log('Position settings reset. Refresh the admin panel to see changes.');
}; 