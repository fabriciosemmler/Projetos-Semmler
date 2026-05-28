#Requires AutoHotkey v2.0
#SingleInstance Force

; Código minificado SEM a palavra "javascript:" no início
global jsCode := "(function(){const elements=document.querySelectorAll('.entry-content p, .entry-content li, .cpp-image-wrapper img');if(elements.length===0)return;const stage=document.createElement('div');stage.id='reading-stage';Object.assign(stage.style,{position:'fixed',top:0,left:0,width:'100vw',height:'100vh',backgroundColor:'#fff',zIndex:100000,display:'flex',alignItems:'center',justifyContent:'center',padding:'5vh 10vw',boxSizing:'border-box',overflow:'hidden'});document.body.appendChild(stage);let currentIndex=0;function autoFit(element){let fontSize=72;element.style.fontSize=fontSize+'px';element.style.lineHeight='1.4';const maxAllowedHeight=window.innerHeight*0.85;while(element.scrollHeight>maxAllowedHeight&&fontSize>14){fontSize-=2;element.style.fontSize=fontSize+'px';}}function render(){stage.innerHTML='';const original=elements[currentIndex];if(original.tagName==='IMG'){const img=document.createElement('img');img.src=original.getAttribute('data-src')||original.getAttribute('data-lazy-src')||original.src;Object.assign(img.style,{maxWidth:'100%',maxHeight:'85vh',objectFit:'contain',margin:'auto',display:'block'});stage.appendChild(img);}else{const clone=original.cloneNode(true);Object.assign(clone.style,{display:(clone.tagName==='LI')?'list-item':'block',width:'100%',maxWidth:'1000px',margin:0});clone.querySelectorAll('img').forEach(img=>img.style.maxHeight='40vh');stage.appendChild(clone);autoFit(clone);}const c=document.createElement('div');c.style.cssText='position:absolute;bottom:20px;right:20px;font-family:sans-serif;color:#888;font-size:18px;cursor:pointer;user-select:none;';c.innerHTML='&#128269; '+(currentIndex+1)+' / '+elements.length;c.onclick=()=>{let p=prompt('Ir para a página (1-'+elements.length+'):');if(p){let n=parseInt(p,10);if(n>0&&n<=elements.length){currentIndex=n-1;render();}}};stage.appendChild(c);}window.addEventListener('keydown',(e)=>{if(e.key==='PageDown'&&currentIndex<elements.length-1){e.preventDefault();currentIndex++;render();}else if(e.key==='PageUp'&&currentIndex>0){e.preventDefault();currentIndex--;render();}});window.addEventListener('resize',render);render();})();"

^F12:: {
    SavedClip := A_Clipboard
    A_Clipboard := jsCode
    ClipWait(1)
; Teste
    Send("^l")              ; Foca a barra de endereços do Chrome (Ctrl+L)
    Sleep(50)
    SendText("javascript:") ; Digita o prefixo para burlar a trava de segurança
    Send("^v")              ; Cola o resto do código
    Sleep(50)
    Send("{Enter}")         ; Executa a mágica

    Sleep(100)
    A_Clipboard := SavedClip ; Devolve o seu texto copiado original
}
