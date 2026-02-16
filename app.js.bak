const jsonFiles = [
    'ginkgo_OS2_0_104_5.json'
];

let romData = [];
let availableTags = [];

async function loadROMData() {
    // Fetch tags first
    try {
        const tagsRes = await fetch('./tags.json');
        if (tagsRes.ok) {
            availableTags = await tagsRes.json();
            renderFilters();
            renderUploadTags();
        }
    } catch (e) {
        console.error("Error loading tags:", e);
    }

    const grid = document.getElementById('rom-grid');
    grid.innerHTML = '<p style="text-align:center; grid-column: 1/-1;">Loading HyperOS Ports...</p>';

    try {
        const promises = jsonFiles.map(file =>
            fetch(`./info/${file}`).then(res => {
                if (!res.ok) throw new Error(`Failed to load ${file}`);
                return res.json();
            })
        );
        romData = await Promise.all(promises);

        console.log("Loaded data:", romData);
        renderROMs(romData);
    } catch (error) {
        console.error("Error loading ROM data:", error);
        grid.innerHTML = `
            <div style="text-align:center; grid-column: 1/-1; padding: 2rem;">
                <p style="color: #ff4444; margin-bottom: 1rem;">Error loading data from JSON files.</p>
                <p style="font-size: 0.9rem; color: var(--text-secondary);">
                    Note: If you are opening index.html directly from your file manager,
                    browsers block loading local JSON files for security.
                    Please use a local web server or VS Code "Live Server".
                </p>
            </div>
        `;
    }
}

function renderROMs(filteredData) {
    const grid = document.getElementById('rom-grid');
    grid.innerHTML = '';

    if (filteredData.length === 0) {
        grid.innerHTML = '<p style="text-align:center; grid-column: 1/-1;">No Ports found matching your criteria.</p>';
        return;
    }

    filteredData.forEach(rom => {
        const card = document.createElement('div');
        card.className = 'rom-card glass-card';

        // Generate multiple tags HTML
        const tagsHtml = rom.tags ? rom.tags.map(tag =>
            tag !== 'All Ports' ? `<span class="rom-tag">${tag}</span>` : ''
        ).join('') : '';

        card.innerHTML = `
            <div class="tag-container">${tagsHtml}</div>
            <h3>${rom.port_rom_name}</h3>
            <p class="device-info">${rom.device_name} (${rom.codename})</p>
            <div class="maintainer">
                <div class="avatar">${rom.porter_name.charAt(0)}</div>
                <span>By <strong>${rom.porter_name}</strong></span>
            </div>
            <div class="card-footer">
                <span class="android-version">Android ${rom.android_version}</span>
                <button class="btn-primary" onclick="showDetails('${rom.codename}')">Details</button>
            </div>
        `;
        grid.appendChild(card);
    });
}

// Initial Load
loadROMData();

// Filtering Logic
function renderFilters() {
    const container = document.getElementById('filter-container');
    if (!container) return;

    container.innerHTML = availableTags.map(tag => {
        const value = tag === 'All Ports' ? 'all' : tag;
        const activeClass = tag === 'All Ports' ? 'active' : '';
        return `<button class="filter-btn ${activeClass}" data-filter="${value}">${tag}</button>`;
    }).join('');

    // Re-attach event listeners to new buttons
    const filterButtons = container.querySelectorAll('.filter-btn');
    filterButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            filterButtons.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');

            const filter = btn.getAttribute('data-filter');
            const filtered = filter === 'all'
                ? romData
                : romData.filter(rom => rom.tags && rom.tags.includes(filter));

            renderROMs(filtered);
        });
    });
}

function renderUploadTags() {
    const container = document.getElementById('upload-tags-container');
    if (!container) return;

    container.innerHTML = availableTags.map(tag => {
        const isAllPorts = tag === 'All Ports';
        return `
            <label class="checkbox-pill">
                <input type="checkbox" name="up-tags" value="${tag}" 
                    ${isAllPorts ? 'checked disabled' : ''}> 
                ${tag}
            </label>
        `;
    }).join('');
}

// Search Logic
const searchInput = document.getElementById('rom-search');
searchInput.addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase();
    const filtered = romData.filter(rom =>
        rom.port_rom_name.toLowerCase().includes(query) ||
        rom.device_name.toLowerCase().includes(query) ||
        rom.codename.toLowerCase().includes(query)
    );
    renderROMs(filtered);
});

// Modal Logic
const uploadTrigger = document.getElementById('upload-trigger');
const uploadModal = document.getElementById('upload-modal');
const closeModal = document.querySelector('.close-modal');

uploadTrigger.addEventListener('click', () => {
    uploadModal.style.display = 'flex';
    // Initialize rows only if empty
    if (document.getElementById('changelog-inputs').children.length === 0) {
        initFormRows();
    }
});

closeModal.addEventListener('click', () => {
    uploadModal.style.display = 'none';
});

window.addEventListener('click', (e) => {
    if (e.target === uploadModal) {
        uploadModal.style.display = 'none';
    }
});

const uploadForm = document.getElementById('upload-form');

// SVG Icons
const ICON_REMOVE = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>`;
const ICON_ADD = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>`;

// Initialize Add Buttons with Icons
document.getElementById('add-changelog-btn').innerHTML = ICON_ADD;
document.getElementById('add-install-btn').innerHTML = ICON_ADD;
document.getElementById('add-download-btn').innerHTML = ICON_ADD;

// Helper to add dynamic input rows
function addDynamicRow(containerId, placeholder, className) {
    const container = document.getElementById(containerId);
    const card = document.createElement('div');
    card.className = 'item-card';
    card.innerHTML = `
        <input type="text" class="${className}" placeholder="${placeholder}">
        <button type="button" class="remove-btn" title="Remove">${ICON_REMOVE}</button>
    `;
    container.appendChild(card);

    card.querySelector('.remove-btn').addEventListener('click', () => {
        card.style.transform = 'translateX(20px)';
        card.style.opacity = '0';
        setTimeout(() => card.remove(), 200);
    });
}

// Event Listeners for Dynamic Rows
document.getElementById('add-changelog-btn').addEventListener('click', () => {
    addDynamicRow('changelog-inputs', 'Fixed NFC issues...', 'changelog-item');
});

document.getElementById('add-install-btn').addEventListener('click', () => {
    addDynamicRow('installation-inputs', 'Wipe Data/Metadata...', 'install-item');
});

document.getElementById('add-download-btn').addEventListener('click', () => {
    const container = document.getElementById('download-inputs');
    const card = document.createElement('div');
    card.className = 'download-input-card';
    card.innerHTML = `
        <div class="input-group-row">
            <div style="flex: 1;">
                <label>Label</label>
                <input type="text" class="dl-label" placeholder="e.g. MEGA" required>
            </div>
            <div style="flex: 2;">
                <label>URL</label>
                <input type="url" class="dl-url" placeholder="Download link" required>
            </div>
        </div>
        <button type="button" class="remove-btn" title="Remove">${ICON_REMOVE}</button>
    `;
    container.appendChild(card);
    card.querySelector('.remove-btn').addEventListener('click', () => {
        card.style.transform = 'translateX(20px)';
        card.style.opacity = '0';
        setTimeout(() => card.remove(), 200);
    });
});

// Initialize with one row each
function initFormRows() {
    // Clear existing to avoid duplicates
    const containers = ['changelog-inputs', 'installation-inputs', 'download-inputs'];
    containers.forEach(id => {
        const el = document.getElementById(id);
        if (el) el.innerHTML = '';
    });

    addDynamicRow('changelog-inputs', 'Fixed NFC issues...', 'changelog-item');
    addDynamicRow('installation-inputs', 'Wipe Data/Metadata...', 'install-item');

    // Add first download row
    const container = document.getElementById('download-inputs');
    const card = document.createElement('div');
    card.className = 'download-input-card';
    card.innerHTML = `
        <div class="input-group-row">
            <div style="flex: 1;">
                <label>Label</label>
                <input type="text" class="dl-label" placeholder="e.g. SourceForge" required>
            </div>
            <div style="flex: 2;">
                <label>URL</label>
                <input type="url" class="dl-url" placeholder="Download link" required>
            </div>
        </div>
    `;
    container.appendChild(card);
}


// JSON File Download Helper
function downloadJSON(data, filename) {
    const blob = new Blob([JSON.stringify(data, null, 4)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    setTimeout(() => {
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);
    }, 0);
}

// Form Submission Logic
uploadForm.addEventListener('submit', (e) => {
    e.preventDefault();

    // Collect tags
    const tags = Array.from(document.querySelectorAll('input[name="up-tags"]:checked')).map(cb => cb.value);

    // Collect dynamic lists
    const changelog = Array.from(document.querySelectorAll('.changelog-item'))
        .map(input => input.value.trim())
        .filter(val => val !== '');

    const instructions = Array.from(document.querySelectorAll('.install-item'))
        .map(input => input.value.trim())
        .filter(val => val !== '');

    const downloads = Array.from(document.querySelectorAll('.download-input-card')).map(card => ({
        label: card.querySelector('.dl-label').value.trim(),
        url: card.querySelector('.dl-url').value.trim()
    })).filter(dl => dl.label && dl.url);

    // Create JSON object
    const romEntry = {
        device_name: document.getElementById('up-device-name').value.trim(),
        codename: document.getElementById('up-codename').value.trim().toLowerCase(),
        port_rom_name: document.getElementById('up-rom-name').value.trim(),
        port_rom_version: document.getElementById('up-rom-version').value.trim(),
        android_version: document.getElementById('up-android-version').value,
        porter_name: document.getElementById('up-porter-name').value.trim(),
        porter_contact: document.getElementById('up-porter-contact').value.trim(),
        additional_credits: document.getElementById('up-additional-credits').value.trim(),
        tags: tags,
        date_of_upload: new Date().toISOString().split('T')[0],
        download_links: downloads,
        brief_note: document.getElementById('up-brief-note').value.trim(),
        changelog: changelog.length > 0 ? changelog : ["Initial release"],
        installation_instructions: instructions.length > 0 ? instructions : ["Wipe data", "Flash ZIP", "Reboot"]
    };

    // Filename generation
    const filename = `${romEntry.codename}_${romEntry.port_rom_version.replace(/\./g, '_')}.json`;

    // Download JSON file
    downloadJSON(romEntry, filename);

    // Create mailto link
    const email = "dipanshu247k@gmail.com";
    const subject = `New ROM Submission: ${romEntry.port_rom_name} for ${romEntry.device_name}`;
    const body = `Hi Alok,\n\nI've attached the generated JSON file (${filename}) for the new ROM submission.\n\nPlease find it in my downloads.\n\nThanks!`;

    const mailtoUrl = `mailto:${email}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;

    alert(`Success! JSON file "${filename}" has been downloaded.\n\nOpening your email client now. Please ATTACH the downloaded file and send it.\n\nAlternatively, send the file to @Alok_Kurohane on Telegram.`);

    window.location.href = mailtoUrl;
    uploadModal.style.display = 'none';
    uploadForm.reset();

    // Clear dynamic inputs extra rows (keep only the first one if possible or just clear all and let user add)
    document.querySelectorAll('.input-with-remove').forEach(row => row.remove());
});

// Navigation Logic
const navExplore = document.getElementById('nav-explore');
const navDevices = document.getElementById('nav-devices');
const exploreView = document.getElementById('explore-view');
const devicesView = document.getElementById('devices-view');
const detailsView = document.getElementById('details-view');

function switchView(viewName) {
    // Hide all views
    [exploreView, devicesView, detailsView].forEach(v => {
        if (v) v.style.display = 'none';
    });

    // Show target view
    if (viewName === 'explore') {
        exploreView.style.display = 'block';
        navExplore.classList.add('active');
        navDevices.classList.remove('active');
    } else if (viewName === 'devices') {
        devicesView.style.display = 'block';
        navExplore.classList.remove('active');
        navDevices.classList.add('active');
        renderDevices();
    } else if (viewName === 'details') {
        detailsView.style.display = 'block';
        navExplore.classList.remove('active');
        navDevices.classList.remove('active');
    }

    // Scroll to top
    window.scrollTo(0, 0);
}

navExplore.addEventListener('click', (e) => {
    e.preventDefault();
    switchView('explore');
});

navDevices.addEventListener('click', (e) => {
    e.preventDefault();
    switchView('devices');
});

function renderDevices() {
    const deviceGrid = document.getElementById('device-grid');
    deviceGrid.innerHTML = '';

    // Get unique devices by codename
    const uniqueDevices = [];
    const codenames = new Set();

    romData.forEach(rom => {
        if (!codenames.has(rom.codename)) {
            codenames.add(rom.codename);
            uniqueDevices.push({
                name: rom.device_name,
                codename: rom.codename,
                brand: rom.device_name.split(' ')[0]
            });
        }
    });

    uniqueDevices.forEach(device => {
        const card = document.createElement('div');
        card.className = 'device-card glass-card';
        card.innerHTML = `
            <div class="device-icon-box">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="5" y="2" width="14" height="20" rx="2" ry="2"></rect><line x1="12" y1="18" x2="12" y2="18"></line></svg>
            </div>
            <h3>${device.name}</h3>
            <code class="codename">${device.codename}</code>
            <p class="brand-label">${device.brand}</p>
            <button class="btn-secondary" onclick="filterByDevice('${device.codename}')">View ROMs</button>
        `;
        deviceGrid.appendChild(card);
    });
}

function filterByDevice(codename) {
    switchView('explore');
    const filtered = romData.filter(rom => rom.codename === codename);
    renderROMs(filtered);

    // Clear filter button active states since we are filtering by device
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
}

function showDetails(codename) {
    const rom = romData.find(r => r.codename === codename);
    if (!rom) return;

    switchView('details');

    // Populate Hero Header
    document.getElementById('details-hero').innerHTML = `
        <h1>${rom.port_rom_name}</h1>
        <div class="details-meta-row">
            <span class="meta-pill">${rom.device_name} (${rom.codename})</span>
            <span class="meta-pill">HyperOS ${rom.port_rom_version}</span>
            <span class="meta-pill">Android ${rom.android_version}</span>
        </div>
    `;

    // Populate Description
    document.getElementById('details-note').innerHTML = `<p>${rom.brief_note || "No additional notes provided for this port."}</p>`;

    // Populate Changelog with refined items
    const changelogList = document.getElementById('details-changelog');
    changelogList.innerHTML = rom.changelog ? rom.changelog.map(item => `
        <li>
            <span>${item}</span>
        </li>
    `).join('') : '<li>Initial release of the port.</li>';

    // Populate Installation Steps with numbers
    const installContainer = document.getElementById('details-installation');
    installContainer.innerHTML = rom.installation_instructions ? rom.installation_instructions.map((step, index) => `
        <div class="install-step">
            <div class="step-number">${index + 1}</div>
            <div class="step-text">${step}</div>
        </div>
    `).join('') : '<p class="content-body">Standard recovery installation recommended.</p>';

    // Populate Porter Card
    document.getElementById('details-porter-card').innerHTML = `
        <h3 class="sidebar-title">The Porter</h3>
        <div class="porter-profile">
            <div class="porter-avatar-large">${rom.porter_name.charAt(0)}</div>
            <div class="porter-info-text">
                <label>Maintained by</label>
                <p>${rom.porter_name}</p>
                <a href="${rom.porter_contact}" style="font-size: 0.8rem; color: var(--primary); text-decoration: none;" target="_blank">Contact Porter</a>
            </div>
        </div>
    `;

    // Populate Downloads
    const downloadContainer = document.getElementById('details-downloads');
    downloadContainer.innerHTML = rom.download_links ? rom.download_links.map(link => `
        <a href="${link.url}" class="btn-download-refined" target="_blank">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
            ${link.label}
        </a>
    `).join('') : '<p class="meta-label">No links available.</p>';

    // Populate System Meta
    document.getElementById('details-system-meta').innerHTML = `
        <h3 class="sidebar-title">Port Specs</h3>
        <div class="meta-row-refined">
            <span class="meta-label">Android Version</span>
            <span class="meta-value">${rom.android_version}</span>
        </div>
        <div class="meta-row-refined">
            <span class="meta-label">HyperOS Version</span>
            <span class="meta-value">${rom.port_rom_version}</span>
        </div>
        <div class="meta-row-refined">
            <span class="meta-label">Upload Date</span>
            <span class="meta-value">${rom.date_of_upload}</span>
        </div>
        ${rom.additional_credits ? `
        <div class="meta-row-refined" style="margin-top: 1rem; padding-top: 1rem; border-top: 1px solid rgba(255, 255, 255, 0.1);">
            <span class="meta-label">Additional Credits</span>
            <span class="meta-value" style="white-space: pre-wrap;">${rom.additional_credits}</span>
        </div>
        ` : ''}
    `;
}
