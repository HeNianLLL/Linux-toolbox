// Language Switching
function initLanguage() {
    const langBtn = document.getElementById('langBtn');
    if (!langBtn) return;

    let currentLang = 'zh';
    
    langBtn.addEventListener('click', () => {
        currentLang = currentLang === 'zh' ? 'en' : 'zh';
        langBtn.textContent = currentLang === 'zh' ? 'EN' : 'CN';
        updateContent(currentLang);
    });

    function updateContent(lang) {
        const translations = {
            zh: {
                'nav.features': '功能',
                'nav.systems': '系统支持',
                'nav.download': '下载',
                'nav.changelog': '版本',
                'nav.about': '关于',
                'hero.title': '一键式Linux系统管理解决方案',
                'hero.desc': '轻松管理软件源、安装开发环境、优化系统性能，让Linux服务器管理变得简单高效。',
                'hero.badge': 'v1.0.0 正式发布',
                'hero.btn1': '立即使用',
                'hero.btn2': 'GitHub',
                'stats.downloads': '使用次数',
                'stats.systems': '支持系统',
                'stats.mirrors': '支持的软件包版本',
                'stats.success': '成功率',
                'features.title': '强大功能',
                'features.desc': '专业级工具，为Linux系统提供全方位支持',
                'feature.1.title': '软件源管理',
                'feature.1.desc': '一键切换国内外镜像源，解决下载慢问题，支持多种Linux系统',
                'feature.2.title': 'Python安装',
                'feature.2.desc': '多版本Python快速安装与管理，支持自定义安装目录',
                'feature.3.title': 'Node.js安装',
                'feature.3.desc': '最新版本Node.js一键安装，支持多版本管理',
                'feature.4.title': '交换内存管理',
                'feature.4.desc': '创建和管理虚拟内存，提升系统性能',
                'feature.5.title': '系统信息',
                'feature.5.desc': '详细展示系统硬件和软件信息',
                'feature.6.title': '网络工具',
                'feature.6.desc': '网络检测和优化工具，确保网络连接稳定',
                'systems.title': '广泛兼容',
                'systems.desc': '支持多种Linux发行版',
                'download.title': '快速开始',
                'download.desc': '选择适合你的安装方式',
                'download.online': '在线运行',
                'download.manual': '手动下载',
                'download.note1': '复制命令到终端执行，即可开始使用SetBox',
                'download.note2': '下载后执行以下命令：',
                'changelog.title': '版本历史',
                'changelog.desc': '查看功能更新和版本迭代',
                'changelog.v1': 'SetBox v1.0.0',
                'changelog.feature1': '支持多系统软件源管理',
                'changelog.feature2': 'Python多版本安装',
                'changelog.feature3': '最新Node.js版本安装',
                'changelog.feature4': '交换内存管理',
                'changelog.feature5': '系统信息检测',
                'changelog.feature6': '网络工具集成',
                'changelog.feature7': '中英文双语支持',
                'about.title': '关于我们',
                'about.desc': 'SetBox是一个开源项目，致力于为Linux用户提供简单易用的系统管理工具。我们的目标是让Linux系统管理变得更加简单高效。',
                'about.domain': '官方网站',
                'about.contact': '联系邮箱',
                'about.github': 'GitHub 仓库',
                'footer.product': '产品',
                'footer.community': '社区',
                'footer.copyright': '© 2026 SetBox. 保留所有权利.'
            },
            en: {
                'nav.features': 'Features',
                'nav.systems': 'Systems',
                'nav.download': 'Download',
                'nav.changelog': 'Changelog',
                'nav.about': 'About',
                'hero.title': 'One-stop Linux Server Management Solution',
                'hero.desc': 'Easily manage software sources, install development environments, optimize system performance, and make Linux server management simple and efficient.',
                'hero.badge': 'v1.0.0 Released',
                'hero.btn1': 'Get Started',
                'hero.btn2': 'GitHub',
                'stats.downloads': 'Usage Count',
                'stats.systems': 'Supported Systems',
                'stats.mirrors': 'Supported Package Versions',
                'stats.success': 'Success Rate',
                'features.title': 'Powerful Features',
                'features.desc': 'Professional tools for comprehensive Linux system support',
                'feature.1.title': 'Software Source Management',
                'feature.1.desc': 'One-click switch between domestic and international mirrors, solve download speed issues, support multiple Linux systems',
                'feature.2.title': 'Python Installation',
                'feature.2.desc': 'Multi-version Python quick installation and management, support custom installation directory',
                'feature.3.title': 'Node.js Installation',
                'feature.3.desc': 'Latest Node.js version one-click installation, support multi-version management',
                'feature.4.title': 'Swap Memory Management',
                'feature.4.desc': 'Create and manage virtual memory, improve system performance',
                'feature.5.title': 'System Information',
                'feature.5.desc': 'Detailed display of system hardware and software information',
                'feature.6.title': 'Network Tools',
                'feature.6.desc': 'Network detection and optimization tools to ensure stable network connection',
                'systems.title': 'Wide Compatibility',
                'systems.desc': 'Supports multiple Linux distributions',
                'download.title': 'Quick Start',
                'download.desc': 'Choose your installation method',
                'download.online': 'Online Run',
                'download.manual': 'Manual Download',
                'download.note1': 'Copy the command to your terminal to start using SetBox',
                'download.note2': 'After downloading, run the following command:',
                'changelog.title': 'Version History',
                'changelog.desc': 'View feature updates and version iterations',
                'changelog.v1': 'SetBox v1.0.0',
                'changelog.feature1': 'Multi-system software source management',
                'changelog.feature2': 'Python multi-version installation',
                'changelog.feature3': 'Latest Node.js version installation',
                'changelog.feature4': 'Swap memory management',
                'changelog.feature5': 'System information detection',
                'changelog.feature6': 'Network tool integration',
                'changelog.feature7': 'Chinese/English bilingual support',
                'about.title': 'About Us',
                'about.desc': 'SetBox is an open-source project dedicated to providing simple and easy-to-use system management tools for Linux users. Our goal is to make Linux system management more simple and efficient.',
                'about.domain': 'Official Website',
                'about.contact': 'Contact Email',
                'about.github': 'GitHub Repository',
                'footer.product': 'Product',
                'footer.community': 'Community',
                'footer.copyright': '© 2026 SetBox. All rights reserved.'
            }
        };

        // Update navigation links
        const navLinks = document.querySelectorAll('.nav-links a');
        const navTexts = ['features', 'systems', 'download', 'changelog', 'about'];
        navLinks.forEach((link, index) => {
            if (navTexts[index]) {
                link.textContent = translations[lang]['nav.' + navTexts[index]];
            }
        });

        // Update hero section
        const heroBadge = document.querySelector('.hero-text .badge');
        const heroTitle = document.querySelector('.hero-text h1');
        const heroDesc = document.querySelector('.hero-text p');
        const heroBtns = document.querySelectorAll('.hero-buttons a');
        const heroMobileBtns = document.querySelectorAll('.hero-buttons-mobile a');
        if (heroBadge) heroBadge.textContent = translations[lang]['hero.badge'];
        if (heroTitle) heroTitle.textContent = translations[lang]['hero.title'];
        if (heroDesc) heroDesc.textContent = translations[lang]['hero.desc'];
        if (heroBtns[0]) heroBtns[0].textContent = translations[lang]['hero.btn1'];
        if (heroBtns[1]) heroBtns[1].textContent = translations[lang]['hero.btn2'];
        if (heroMobileBtns[0]) heroMobileBtns[0].textContent = translations[lang]['hero.btn1'];
        if (heroMobileBtns[1]) heroMobileBtns[1].textContent = translations[lang]['hero.btn2'];

        // Update stats section
        const statLabels = document.querySelectorAll('.stat-label');
        const statTexts = ['downloads', 'systems', 'mirrors', 'success'];
        statLabels.forEach((label, index) => {
            if (statTexts[index]) {
                label.textContent = translations[lang]['stats.' + statTexts[index]];
            }
        });

        // Update features section
        const featuresHeader = document.querySelector('.features .section-header h2');
        const featuresDesc = document.querySelector('.features .section-header p');
        if (featuresHeader) featuresHeader.textContent = translations[lang]['features.title'];
        if (featuresDesc) featuresDesc.textContent = translations[lang]['features.desc'];

        const featureCards = document.querySelectorAll('.feature-card');
        for (let i = 0; i < featureCards.length; i++) {
            const title = featureCards[i].querySelector('h3');
            const desc = featureCards[i].querySelector('p');
            if (title) title.textContent = translations[lang]['feature.' + (i+1) + '.title'];
            if (desc) desc.textContent = translations[lang]['feature.' + (i+1) + '.desc'];
        }

        // Update systems section
        const systemsHeader = document.querySelector('.systems .section-header h2');
        const systemsDesc = document.querySelector('.systems .section-header p');
        if (systemsHeader) systemsHeader.textContent = translations[lang]['systems.title'];
        if (systemsDesc) systemsDesc.textContent = translations[lang]['systems.desc'];

        // Update download section
        const downloadHeader = document.querySelector('.download .section-header h2');
        const downloadDesc = document.querySelector('.download .section-header p');
        if (downloadHeader) downloadHeader.textContent = translations[lang]['download.title'];
        if (downloadDesc) downloadDesc.textContent = translations[lang]['download.desc'];

        const downloadCards = document.querySelectorAll('.download-card h3');
        const downloadNotes = document.querySelectorAll('.download-note');
        if (downloadCards[0]) downloadCards[0].textContent = translations[lang]['download.online'];
        if (downloadCards[1]) downloadCards[1].textContent = translations[lang]['download.manual'];
        if (downloadNotes[0]) downloadNotes[0].textContent = translations[lang]['download.note1'];
        if (downloadNotes[1]) downloadNotes[1].textContent = translations[lang]['download.note2'];

        // Update code blocks
        const codeBlocks = document.querySelectorAll('.code-block code');
        if (codeBlocks[0]) {
            codeBlocks[0].textContent = lang === 'zh' ? 
                'bash <(curl -sSL https://linuxset.com/linux-setbox-cn.sh)' : 
                'bash <(curl -sSL https://linuxset.com/linux-setbox-en.sh)';
        }
        if (codeBlocks[1]) {
            codeBlocks[1].textContent = lang === 'zh' ? 
                'wget https://linuxset.com/linux-setbox-cn.sh' : 
                'wget https://linuxset.com/linux-setbox-en.sh';
        }
        if (codeBlocks[2]) {
            codeBlocks[2].textContent = lang === 'zh' ? 
                'chmod +x linux-setbox-cn.sh && ./linux-setbox-cn.sh' : 
                'chmod +x linux-setbox-en.sh && ./linux-setbox-en.sh';
        }

        // Update terminal content
        const terminalContents = document.querySelectorAll('.terminal-content');
        terminalContents.forEach(content => {
            if (content.dataset.lang === lang) {
                content.classList.remove('hidden');
            } else {
                content.classList.add('hidden');
            }
        });

        // Update changelog section
        const changelogHeader = document.querySelector('.changelog .section-header h2');
        const changelogDesc = document.querySelector('.changelog .section-header p');
        if (changelogHeader) changelogHeader.textContent = translations[lang]['changelog.title'];
        if (changelogDesc) changelogDesc.textContent = translations[lang]['changelog.desc'];

        const changelogTitle = document.querySelector('.changelog-content h3');
        if (changelogTitle) changelogTitle.textContent = translations[lang]['changelog.v1'];

        const featureListItems = document.querySelectorAll('.feature-list li');
        for (let i = 0; i < featureListItems.length; i++) {
            if (featureListItems[i]) {
                featureListItems[i].textContent = translations[lang]['changelog.feature' + (i+1)];
            }
        }

        // Update about section
        const aboutHeader = document.querySelector('.about .section-header h2');
        const aboutDesc = document.querySelector('.about-description');
        const domainLabel = document.querySelector('.domain-label');
        const contactLabel = document.querySelector('.contact-label');
        const aboutLinks = document.querySelectorAll('.about-link span:last-child');
        if (aboutHeader) aboutHeader.textContent = translations[lang]['about.title'];
        if (aboutDesc) aboutDesc.textContent = translations[lang]['about.desc'];
        if (domainLabel) domainLabel.textContent = translations[lang]['about.domain'];
        if (contactLabel) contactLabel.textContent = translations[lang]['about.contact'];
        if (aboutLinks[0]) aboutLinks[0].textContent = translations[lang]['about.github'];

        // Update footer
        const footerColumns = document.querySelectorAll('.footer-column h4');
        const footerTexts = ['product', 'community'];
        footerColumns.forEach((column, index) => {
            if (footerTexts[index]) {
                column.textContent = translations[lang]['footer.' + footerTexts[index]];
            }
        });

        const footerCopyright = document.querySelector('.footer-bottom p');
        if (footerCopyright) footerCopyright.textContent = translations[lang]['footer.copyright'];
    }
}

// Copy Button Functionality
function initCopyButtons() {
    const copyButtons = document.querySelectorAll('.copy-btn');
    copyButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const codeBlock = btn.closest('.code-block');
            const code = codeBlock.querySelector('code').textContent;
            
            navigator.clipboard.writeText(code).then(() => {
                const originalText = btn.textContent;
                btn.textContent = '✓';
                setTimeout(() => {
                    btn.textContent = originalText;
                }, 2000);
            });
        });
    });
}

// Smooth Scrolling
function initSmoothScrolling() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;
            
            const targetElement = document.querySelector(targetId);
            if (targetElement) {
                targetElement.scrollIntoView({ 
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

// Scroll Animations
function initScrollAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('fade-in');
            }
        });
    }, observerOptions);

    document.querySelectorAll('.stat-item, .feature-card, .system-item, .download-card, .changelog-item').forEach(el => {
        observer.observe(el);
    });
}

// Animate number counting
function animateNumber(element, target) {
    const duration = 1000;
    const start = 0;
    const startTime = performance.now();
    
    function update(currentTime) {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);
        
        // Easing function
        const easeOutQuart = 1 - Math.pow(1 - progress, 4);
        const current = Math.floor(start + (target - start) * easeOutQuart);
        
        element.textContent = current.toLocaleString();
        
        if (progress < 1) {
            requestAnimationFrame(update);
        }
    }
    
    requestAnimationFrame(update);
}

// Initialize all functions when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initLanguage();
    initCopyButtons();
    initSmoothScrolling();
    initScrollAnimations();
});
