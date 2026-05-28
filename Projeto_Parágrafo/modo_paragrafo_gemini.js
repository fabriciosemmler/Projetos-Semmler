(function() {
    let baseNode = document;
    const msgs = document.querySelectorAll('message-content, .message-content');
    if (msgs.length > 0) {
        baseNode = msgs[msgs.length - 1];
    }
    
    const elements = [...baseNode.querySelectorAll('.markdown p, .markdown li, .markdown img, code, p')].filter(el => !el.closest('button,[role="button"]') && el.textContent.trim().length > 0);
    
    if (elements.length === 0) return;
    
    const stage = document.createElement('div');
    stage.id = 'reading-stage';
    Object.assign(stage.style, { position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', backgroundColor: '#000', color: '#fff', zIndex: 100000, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '5vh 10vw', boxSizing: 'border-box', overflow: 'hidden' });
    document.body.style.overflow = 'hidden';
    document.body.appendChild(stage);
    
    let st = localStorage.getItem('txt_' + location.pathname);
    let currentIndex = st ? elements.findIndex(el => el.textContent.trim().substring(0, 30) === st) : -1;
    
    if (currentIndex === -1) currentIndex = parseInt(localStorage.getItem('prgf_' + location.pathname)) || 0;
    if (currentIndex >= elements.length) currentIndex = 0;
    
    function autoFit(element) {
        let fontSize = 72;
        element.style.fontSize = fontSize + 'px';
        element.style.lineHeight = '1.4';
        const maxAllowedHeight = window.innerHeight * 0.85;
        while (element.scrollHeight > maxAllowedHeight && fontSize > 14) {
            fontSize -= 2;
            element.style.fontSize = fontSize + 'px';
        }
    }
    
    function render() {
        localStorage.setItem('prgf_' + location.pathname, currentIndex);
        if (elements[currentIndex]) localStorage.setItem('txt_' + location.pathname, elements[currentIndex].textContent.trim().substring(0, 30));
        
        stage.replaceChildren();
        
        const original = elements[currentIndex];
        
        if (original.tagName === 'IMG') {
            const img = document.createElement('img');
            img.src = original.getAttribute('data-src') || original.getAttribute('data-lazy-src') || original.src;
            Object.assign(img.style, { maxWidth: '100%', maxHeight: '85vh', objectFit: 'contain', margin: 'auto', display: 'block' });
            stage.appendChild(img);
        } else {
            const clone = original.cloneNode(true);
            Object.assign(clone.style, { display: (clone.tagName === 'LI') ? 'list-item' : 'block', width: '100%', maxWidth: '1000px', margin: 0, color: '#fff' });
            
            if (clone.tagName === 'CODE') {
                Object.assign(clone.style, { fontFamily: 'monospace', whiteSpace: 'pre', backgroundColor: '#1e1e1e', padding: '20px', borderRadius: '8px', textAlign: 'left', border: '1px solid #333', boxSizing: 'border-box', maxHeight: '80vh', overflow: 'auto' });
                clone.querySelectorAll('[class*=lineno],[class*=line-number],[class*=nums]').forEach(n => n.style.display = 'none');
            }
            
            clone.querySelectorAll('img').forEach(img => img.style.maxHeight = '40vh');
            stage.appendChild(clone);
            autoFit(clone);
        }
        
        const c = document.createElement('div');
        c.style.cssText = 'position:absolute;bottom:20px;right:20px;font-family:sans-serif;color:#888;font-size:18px;cursor:pointer;user-select:none;text-align:right;';
        c.innerText = Math.round(((currentIndex + 1) / elements.length) * 100) + '%\n🔍 ' + (currentIndex + 1) + ' / ' + elements.length;
        
        c.onclick = () => {
            let p = prompt('Ir para a página (1-' + elements.length + '):');
            if (p) {
                let n = parseInt(p, 10);
                if (n > 0 && n <= elements.length) {
                    currentIndex = n - 1;
                    render();
                }
            }
        };
        stage.appendChild(c);
        
        let nL = document.querySelector('.nav-button-next')?.closest('.nav-link');
        if (nL && nL.href) {
            c.style.right = '70px';
            const nb = document.createElement('div');
            nb.textContent = '⏭️';
            nb.style.cssText = 'position:absolute;bottom:25px;right:20px;font-size:24px;cursor:pointer;color:#888;';
            nb.onclick = () => location.href = nL.href;
            stage.appendChild(nb);
        }
    }
    
    window.addEventListener('keydown', (e) => {
        if (e.key === 'PageDown' && currentIndex < elements.length - 1) {
            e.preventDefault();
            currentIndex++;
            render();
        } else if (e.key === 'PageUp' && currentIndex > 0) {
            e.preventDefault();
            currentIndex--;
            render();
        } else if (e.key === 'Home' && currentIndex > 0) {
            e.preventDefault();
            currentIndex = 0;
            render();
        } else if (e.key === 'End' && currentIndex < elements.length - 1) {
            e.preventDefault();
            currentIndex = elements.length - 1;
            render();
        } else if (e.altKey && e.key === 'ArrowRight') {
            let nx = document.querySelector('.nav-button-next')?.closest('.nav-link');
            if (nx && nx.href) {
                e.preventDefault();
                location.href = nx.href;
            }
        }
    });
    
    window.addEventListener('resize', render);
    render();
})();
