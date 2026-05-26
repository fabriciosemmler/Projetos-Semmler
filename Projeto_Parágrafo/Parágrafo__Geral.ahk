#Requires AutoHotkey v2.0
#SingleInstance Force

global ModoParagrafo := false
global AbaSalva := ""

; Código minificado SEM a palavra "javascript:" no início. Adicionada a busca por texto nas variáveis iniciais e no render()
global jsCode := "(function(){const elements=[...document.querySelectorAll('.entry-content p, .entry-content li, .cpp-image-wrapper img, article p, article li, article img, main p, main li, main img, code, .content p, .post p, p')].filter(el=>!el.closest('noscript,header,footer,aside,iframe,.adsbygoogle,[id*=google_ads],[class*=ad-container],[class*=ad-slot],[id*=carbonads]')&&el.textContent.trim()!=='Please enable JavaScript'&&(el.tagName==='IMG'||el.textContent.trim().length>0));if(elements.length===0)return;const stage=document.createElement('div');stage.id='reading-stage';Object.assign(stage.style,{position:'fixed',top:0,left:0,width:'100vw',height:'100vh',backgroundColor:'#000',color:'#fff',zIndex:100000,display:'flex',alignItems:'center',justifyContent:'center',padding:'5vh 10vw',boxSizing:'border-box',overflow:'hidden'});document.body.style.overflow='hidden';document.body.appendChild(stage);let st=localStorage.getItem('txt_'+location.pathname);let currentIndex=st?elements.findIndex(el=>el.textContent.trim().substring(0,30)===st):-1;if(currentIndex===-1)currentIndex=parseInt(localStorage.getItem('prgf_'+location.pathname))||0;if(currentIndex>=elements.length)currentIndex=0;function autoFit(element){let fontSize=72;element.style.fontSize=fontSize+'px';element.style.lineHeight='1.4';const maxAllowedHeight=window.innerHeight*0.85;while(element.scrollHeight>maxAllowedHeight&&fontSize>14){fontSize-=2;element.style.fontSize=fontSize+'px';}}function render(){localStorage.setItem('prgf_'+location.pathname,currentIndex);if(elements[currentIndex])localStorage.setItem('txt_'+location.pathname,elements[currentIndex].textContent.trim().substring(0,30));stage.innerHTML='';const original=elements[currentIndex];if(original.tagName==='IMG'){const img=document.createElement('img');img.src=original.getAttribute('data-src')||original.getAttribute('data-lazy-src')||original.src;Object.assign(img.style,{maxWidth:'100%',maxHeight:'85vh',objectFit:'contain',margin:'auto',display:'block'});stage.appendChild(img);}else{const clone=original.cloneNode(true);Object.assign(clone.style,{display:(clone.tagName==='LI')?'list-item':'block',width:'100%',maxWidth:'1000px',margin:0,color:'#fff'});if(clone.tagName==='CODE'){Object.assign(clone.style,{fontFamily:'monospace',whiteSpace:'pre-wrap',backgroundColor:'#1e1e1e',padding:'20px',borderRadius:'8px',textAlign:'left',border:'1px solid #333',boxSizing:'border-box'});clone.querySelectorAll('[class*=lineno],[class*=line-number],[class*=nums]').forEach(n=>n.style.display='none');}clone.querySelectorAll('img').forEach(img=>img.style.maxHeight='40vh');stage.appendChild(clone);autoFit(clone);}const c=document.createElement('div');c.style.cssText='position:absolute;bottom:20px;right:20px;font-family:sans-serif;color:#888;font-size:18px;cursor:pointer;user-select:none;text-align:right;';c.innerHTML=Math.round(((currentIndex+1)/elements.length)*100)+'%<br>&#128269; '+(currentIndex+1)+' / '+elements.length;c.onclick=()=>{let p=prompt('Ir para a página (1-'+elements.length+'):');if(p){let n=parseInt(p,10);if(n>0&&n<=elements.length){currentIndex=n-1;render();}}};stage.appendChild(c);let nL=document.querySelector('.nav-button-next')?.closest('.nav-link');if(nL&&nL.href){c.style.right='70px';const nb=document.createElement('div');nb.innerHTML='&#9193;';nb.style.cssText='position:absolute;bottom:25px;right:20px;font-size:24px;cursor:pointer;color:#888;';nb.onclick=()=>location.href=nL.href;stage.appendChild(nb);}}window.addEventListener('keydown',(e)=>{if(e.key==='PageDown'&&currentIndex<elements.length-1){e.preventDefault();currentIndex++;render();}else if(e.key==='PageUp'&&currentIndex>0){e.preventDefault();currentIndex--;render();}else if(e.key==='Home'&&currentIndex>0){e.preventDefault();currentIndex=0;render();}else if(e.key==='End'&&currentIndex<elements.length-1){e.preventDefault();currentIndex=elements.length-1;render();}});window.addEventListener('resize',render);render();})();"

^F12:: {
    global ModoParagrafo := true
    global AbaSalva := WinGetTitle("A")
    SetTimer(VerificaAbaChrome, 250)

    SavedClip := A_Clipboard
    A_Clipboard := jsCode
    ClipWait(1)
    Send("^l")              ; Foca a barra de endereços do Chrome (Ctrl+L)
    Sleep(100)
    SendText("javascript:") ; Digita o prefixo para burlar a trava de segurança
    Send("^v")              ; Cola o resto do código
    Sleep(100)
    Send("{Enter}")         ; Executa a mágica

    Sleep(100)
    MouseMove(A_ScreenWidth - 150, A_ScreenHeight / 2)
    A_Clipboard := SavedClip ; Devolve o seu texto copiado original
}

^F13:: {
    global ModoParagrafo := false
    SetTimer(VerificaAbaChrome, 0)
    global AbaSalva := ""
    Send("{F5}") ; Recarrega a página para sair do Modo Parágrafo
}

VerificaAbaChrome() {
    global ModoParagrafo, AbaSalva
    if WinActive("ahk_exe chrome.exe") {
        if (WinGetTitle("A") == AbaSalva) {
            ModoParagrafo := true
        } else {
            ModoParagrafo := false
        }
    }
}

; --- NAVEGAÇÃO ERGONÔMICA (SÓ FUNCIONA COM MODO PARÁGRAFO ATIVO) ---
#HotIf WinActive("ahk_exe chrome.exe") && ModoParagrafo
$Capslock::
{
    MouseMove(A_ScreenWidth - 150, A_ScreenHeight / 2)
    Send("{PgUp}")
}
$Space::
{
    MouseMove(A_ScreenWidth - 150, A_ScreenHeight / 2)
    Send("{PgDn}")
}

; --- ANOTAÇÃO RÁPIDA (FUNCIONA SEMPRE NO CHROME) ---
#HotIf WinActive("ahk_exe chrome.exe")

NumpadAdd:: {
    janelaOriginal := WinGetID("A")
    
    A_Clipboard := ""
    Sleep(50)
    Send "^c"
    
    if !ClipWait(1) {
        return 
    }
    
    ; --- INÍCIO DO TRATAMENTO DE TEXTO ---
    textoTratado := Trim(A_Clipboard, " `t`r`n")
    
    textoTratado := StrUpper(SubStr(textoTratado, 1, 1)) . SubStr(textoTratado, 2)
    
    if (SubStr(textoTratado, -1) != ".") {
        textoTratado .= "."
    }
    
    A_Clipboard := textoTratado
    ; --- FIM DO TRATAMENTO DE TEXTO ---
    
if WinExist("ahk_exe Obsidian.exe") {
        WinActivate "ahk_exe Obsidian.exe"
        
        ; Aguarda até 2 segundos para garantir que o Obsidian está realmente focado e pronto
        if WinWaitActive("ahk_exe Obsidian.exe", , 2) {
            Sleep 100 ; Pequena pausa de segurança para o buffer do teclado do Windows
            Send "^v"
            Sleep 100
            Send "{Enter}" ; Envia os dois Enters de forma limpa e econômica
            Sleep 100
            
            WinActivate "ahk_id " janelaOriginal
        }
    
    } else {
        MsgBox "O Obsidian não parece estar aberto.", "Aviso de Anotação"
    }
}

NumpadSub:: {
    A_Clipboard := ""
    Send "^c"
    
    if !ClipWait(1) {
        return 
    }
    
    Sleep(100)
    
    if WinExist("ahk_exe Code.exe") {
        WinActivate "ahk_exe Code.exe"
    } else {
        Run "code"
    }
    
    ; Aguarda até 3 segundos para garantir que o VS Code abriu/está em foco
    if WinWaitActive("ahk_exe Code.exe", , 3) {
        Sleep(100)
        Send "^1"
        Sleep(100)
        Send "^n"
        Sleep(100)
        Send "^v"
        Sleep(100)
        Send "^s"
        Sleep(300)
        SendText("*.cpp")
    }
}

#HotIf