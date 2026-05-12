/**
 * site-prefs.js
 * ✅ এই file টা রাখো:  src/main/webapp/js/site-prefs.js
 * ✅ প্রতিটা JSP এর <head> এ যোগ করো (BEFORE অন্য script):
 *    <script src="${pageContext.request.contextPath}/js/site-prefs.js"></script>
 */
(function () {

    /* ══════════════════════════════════════
       DARK MODE — সব page এ কাজ করবে
       ══════════════════════════════════════ */
    function applyDarkMode(isDark) {
        if (isDark) {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }
        var toggle = document.getElementById('darkModeToggle');
        if (toggle) toggle.checked = isDark;
    }

    // settings page থেকে call হবে
    window.toggleDarkMode = function (isDark) {
        localStorage.setItem('darkMode', isDark ? '1' : '0');
        applyDarkMode(isDark);
    };

    // page load হওয়ার সাথে সাথেই apply (flash এড়াতে)
    applyDarkMode(localStorage.getItem('darkMode') === '1');


    /* ══════════════════════════════════════
       FONT SIZE — সব page এর সব text এ
       ══════════════════════════════════════ */
    function applyFontSize(size) {
        size = parseInt(size, 10);
        if (isNaN(size) || size < 12 || size > 18) size = 14;
        // CSS variable — যেসব page এ var(--font-size) use করা আছে
        document.documentElement.style.setProperty('--font-size', size + 'px');
        // body style — সব page এর সব text cover করতে
        document.documentElement.style.fontSize = size + 'px';
    }

    window.changeFontSize = function (size) {
        size = parseInt(size, 10);
        localStorage.setItem('fontSize', size);
        applyFontSize(size);
        // settings page এর UI update
        var preview = document.getElementById('previewText');
        var label   = document.getElementById('fontSizeLabel');
        var slider  = document.getElementById('fontSizeSlider');
        if (preview) preview.style.fontSize = size + 'px';
        if (label)   label.textContent = size + 'px';
        if (slider) {
            slider.value = size;
            var pct = ((size - 12) / (18 - 12)) * 100;
            slider.style.background =
                'linear-gradient(to right,#007a63 0%,#007a63 ' + pct + '%,#c8d8e8 ' + pct + '%,#c8d8e8 100%)';
        }
    };

    // page load এ font size apply
    var savedFont = localStorage.getItem('fontSize');
    if (savedFont) applyFontSize(savedFont);


    /* ══════════════════════════════════════
       LANGUAGE — Bengali/English সব page এ
       ══════════════════════════════════════ */
    var BN = {
        'Dashboard': 'ড্যাশবোর্ড',
        'Patients': 'রোগী',
        'Surgeries': 'অস্ত্রোপচার',
        'Schedule Surgery': 'অস্ত্রোপচার নির্ধারণ',
        'Surgeons': 'সার্জন',
        'Operation Theaters': 'অপারেশন থিয়েটার',
        'Settings': 'সেটিংস',
        'About': 'সম্পর্কে',
        'Logout': 'লগআউট',
        'Profile': 'প্রোফাইল',
        'Hospital': 'হাসপাতাল',
        'System': 'সিস্টেম',
        'Risk Settings': 'ঝুঁকি সেটিংস',
        'Notifications': 'বিজ্ঞপ্তি',
        'Security': 'নিরাপত্তা',
        'Save Changes': 'পরিবর্তন সংরক্ষণ',
        'Save Profile': 'প্রোফাইল সংরক্ষণ',
        'Update Password': 'পাসওয়ার্ড আপডেট',
        'Save Preferences': 'পছন্দ সংরক্ষণ',
        'Total Patients': 'মোট রোগী',
        'Total Surgeries': 'মোট অস্ত্রোপচার',
        'Available OTs': 'উপলব্ধ ওটি',
        'High Risk Cases': 'উচ্চ ঝুঁকির ক্ষেত্র',
        'Today\'s Surgeries': 'আজকের অস্ত্রোপচার',
        'Patient': 'রোগী',
        'Surgeon': 'সার্জন',
        'Surgery Type': 'অস্ত্রোপচারের ধরন',
        'Risk': 'ঝুঁকি',
        'Status': 'অবস্থা',
        'Actions': 'কার্যক্রম',
        'Date & Time': 'তারিখ ও সময়',
        'IP Address': 'আইপি ঠিকানা',
        'Completed': 'সম্পন্ন',
        'Pending': 'অপেক্ষমাণ',
        'Cancelled': 'বাতিল',
        'Low': 'কম',
        'Medium': 'মাঝারি',
        'High': 'উচ্চ',
        'Critical': 'জটিল',
        'Search': 'অনুসন্ধান',
        'Add New': 'নতুন যোগ করুন',
        'Edit': 'সম্পাদনা',
        'Delete': 'মুছুন',
        'View': 'দেখুন',
        'Name': 'নাম',
        'Age': 'বয়স',
        'Gender': 'লিঙ্গ',
        'Phone': 'ফোন',
        'Email': 'ইমেইল',
        'Address': 'ঠিকানা',
        'Submit': 'জমা দিন',
        'Cancel': 'বাতিল করুন',
        'Reset': 'রিসেট',
        'No data found': 'কোনো তথ্য পাওয়া যায়নি',
        'Loading...': 'লোড হচ্ছে...',
        'Main': 'মেনু',
        'Management': 'ব্যবস্থাপনা',
        'Resources': 'রিসোর্স',
        'Account': 'অ্যাকাউন্ট'
    };

    function translatePage() {
        var walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
        var node;
        while ((node = walker.nextNode())) {
            var t = node.nodeValue.trim();
            if (BN[t]) {
                node.nodeValue = node.nodeValue.replace(t, BN[t]);
            }
        }
        // placeholder গুলোও translate করো
        document.querySelectorAll('[placeholder]').forEach(function(el) {
            var p = el.getAttribute('placeholder').trim();
            if (BN[p]) el.setAttribute('placeholder', BN[p]);
        });
    }

    window.applyLanguage = function (lang) {
        localStorage.setItem('language', lang);
        if (lang === 'Bengali') {
            translatePage();
        } else {
            location.reload(); // English এ ফিরতে reload
        }
    };


    /* ══════════════════════════════════════
       DOM READY — toggle/slider sync
       ══════════════════════════════════════ */
    document.addEventListener('DOMContentLoaded', function () {

        // Dark mode toggle sync
        var darkToggle = document.getElementById('darkModeToggle');
        if (darkToggle) darkToggle.checked = localStorage.getItem('darkMode') === '1';

        // Font size slider sync
        var slider = document.getElementById('fontSizeSlider');
        if (slider) {
            var fs = parseInt(localStorage.getItem('fontSize') || '14', 10);
            slider.value = fs;
            var pct = ((fs - 12) / (18 - 12)) * 100;
            slider.style.background =
                'linear-gradient(to right,#007a63 0%,#007a63 ' + pct + '%,#c8d8e8 ' + pct + '%,#c8d8e8 100%)';
            var preview = document.getElementById('previewText');
            var label   = document.getElementById('fontSizeLabel');
            if (preview) preview.style.fontSize = fs + 'px';
            if (label)   label.textContent = fs + 'px';
        }

        // Language apply
        var savedLang = localStorage.getItem('language');
        if (savedLang === 'Bengali') translatePage();

        // Language select sync + live change
        var langSelect = document.querySelector('select[name="sys_language"]');
        if (langSelect) {
            if (savedLang) langSelect.value = savedLang;
            langSelect.addEventListener('change', function () {
                window.applyLanguage(this.value);
            });
        }

    });

})();