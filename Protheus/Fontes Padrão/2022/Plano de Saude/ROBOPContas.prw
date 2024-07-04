#Include 'Protheus.ch'

/*
Sugestão de INI

[ONSTART]
JOBS=ROBO_PEG,ROBO_GUIA,ROBO_EVENTO
Refreshrate=600;; a cada 600 segundos o protheus verifica se os jobs estão no ar. é recomendavel a cada 10 minutos

[ROBO_PEG]
ENVIRONMENT=P12
INSTANCES=5,5
main=fRoboPeg

[ROBO_GUIA]
ENVIRONMENT=P12
INSTANCES=5,5
main=fRoboGuia

[ROBO_EVENTO]
ENVIRONMENT=P12
INSTANCES=5,5
main=fRoboEvent
*/
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fRoboPeg
Robo de processamento em fila de Protocolo

@author    Lucas Nonato
@version   V12
@since     10/04/2018
/*/
function fRoboPeg(lAutoma)
local oFila	    as object 
local lSucess   as logical
local cEnv      := GetEnvServer() 
local cEmp      := AllTrim(GETPVPROFSTRING(cEnv,"EMPROBOXML","",GetADV97()))//local cEmp := AllTrim(GETPVPROFSTRING(cEnv,"JEMP","",GetADV97()))
local cFil      := AllTrim(GETPVPROFSTRING(cEnv,"FILROBOXML","",GetADV97())) //local cFil := AllTrim(GETPVPROFSTRING(cEnv,"JFIL","",GetADV97()))
local cCodOpe   := ""
local lSemProc	:= .F.
local nVoltasem := 0
local cHoraFim  := time()
private cHoraIni := time()
default lAutoma := .f.

rpcSetType(3)    
rpcSetEnv( cEmp, cFil,,,cEnv,, )
ptInternal(1,"[fRoboPeg] ") 
oFila   := filaPContas():New()
lSucess := oFila:setupFila()
lDebugP := .f.

cCodOpe := PLSINTPAD()

while !(KillApp()) 

    if oFila:getPeg()
        cHoraIni := TIME()		
        PLSTime('[fRoboPeg];PEG localizada. Inicio;'+oFila:cCodPeg) 
        PLconvRDA7( cCodOpe, oFila:cCodLdp, oFila:cCodPeg )
        //Validação pré add guia
        oFila:addGuia()
        
        lSemProc	:= .F.
        nVoltasem := 0
    else
    	lSemProc	:= .T.
    endif

    if oFila:getPegOk()
        
        //Validação pós processamento da PEG
        BCI->(DbSetOrder(1))
        BCI->(Msseek(xfilial("BCI") + cCodOpe + oFila:cCodLdp + oFila:cCodPeg))
        if BCI->BCI_FASE == "1"
	        PLPEGTOT() //atualiza totais
	        PLSM190Pro(,,,,,,,,,,,.f.,.t.,BCI->(recno()),.t.,.t.) //Atualiza Status
            
            cHoraFim := TIME()
            cElapsed := ElapTime( cHoraIni, cHoraFim )	        
        endIf
        oFila:close()
        PLSTime('[fRoboPeg];Processou todas as guias;'+oFila:cCodPeg)
        lSemProc	:= .F.
    elseif !lSemProc
    	lSemProc	:= .T.
    endif    
    
    oFila:getEveError() 
    oFila:getGuiError()

    If lSemProc
        if lAutoma
            exit
        endif
    	Sleep(100)
    	nVoltasem++
    	If nVoltasem > 10            
    		sleep(500)
    		nVoltasem := 0
    	endIF
    endIf    
    
enddo

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fRoboGuia
Robo de processamento em fila de Guias

@author    Lucas Nonato
@version   V12
@since     10/04/2018
/*/
function fRoboGuia(lAutoma)
local oFila	    as object
local lSucess   as logical
local cEnv      := GetEnvServer()
local cEmp      := AllTrim(GETPVPROFSTRING(cEnv,"EMPROBOXML","",GetADV97()))//local cEmp := AllTrim(GETPVPROFSTRING(cEnv,"JEMP","",GetADV97()))
local cFil      := AllTrim(GETPVPROFSTRING(cEnv,"FILROBOXML","",GetADV97())) //local cFil := AllTrim(GETPVPROFSTRING(cEnv,"JFIL","",GetADV97()))
Local lSemProc  := .F.
Local lSemAdd   := .F.
Local nVoltasem := 0
private cHoraIni := time()
default lAutoma := .f.
lDebugG := .F.

rpcSetType(3)    
rpcSetEnv( cEmp, cFil,,,cEnv,, )
ptInternal(1,"[fRoboGuia] ") 
oFila   := filaPContas():New()
lSucess := oFila:setupFila()

while !(KillApp()) 
    if oFila:getGuia()
        
    	If !PLSPEG001(oFila)  
	        //Validação antes de adicionar os BD6
        	oFila:addEvento()
            
            nVoltasem := 0
        else
        	oFila:guiaNaoProc()
    	endif
    	lSemAdd := .F.
    else
    	lSemAdd := .T.
    endif
    
    if oFila:getGuiaOk()
        
    	PLSGUIA001(oFila)
        
        //Validação depois que processou os BD6
        oFila:fimGuia()
        
        lSemProc := .F.
        nVoltasem := 0
    else        
        lSemProc := .T.
    endif
    
    If lSemProc .and. lSemAdd
        oFila:getExpiredEve()        

        if lAutoma
            exit
        endif
    	Sleep(100)
    	nVoltasem++
    	If nVoltasem > 10    		
            sleep(500)
    		nVoltasem := 0
    	endIF
    endIf   
    
enddo

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fRoboEvent
Robo de processamento em fila de Eventos

@author    Lucas Nonato
@version   V12
@since     10/04/2018
/*/
function fRoboEvent(lAutoma)
local oFila	    as object 
local lSucess   as logical
local cEnv := GetEnvServer()
local cEmp := AllTrim(GETPVPROFSTRING(cEnv,"EMPROBOXML","",GetADV97()))
local cFil := AllTrim(GETPVPROFSTRING(cEnv,"FILROBOXML","",GetADV97())) 
local nVoltasem := 1
private cChumbs   := SubStr("1234567890ABCDEFGHIFKLMNOPQRLTUVXZ",Randomize( 1,34 ),1)
private cHoraIni := time()
default lAutoma := .f.
lDebugE := .f.

rpcSetType(3)    
rpcSetEnv( cEmp, cFil,,,cEnv,, )

ptInternal(1,"[fRoboEvent] ") 
oFila   := filaPContas():New()
lSucess := oFila:setupFila()

//PLTime("["+cChumbs+"] To na area.")

while !(KillApp()) //.t.
    if nVoltasem == 0
        
    endif
    if oFila:getEvento()
        
    	Z1PosTab(oFila)
        
        oFila:fimEvento()  
        
        nVoltasem := 0  
    else
     	nVoltasem++
     	If nVoltasem > 10
            if lAutoma
                exit
            endif 
            //PLTime("["+cChumbs+"]Puts cai no sleep " ) 
     		Sleep(500)
     	endIf
    endif        
enddo

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} addFilaPLS
Função resumida que adiciona os itens na fila sem precisar instanciar a classe

@author    Lucas Nonato
@version   V12
@since     10/04/2018
/*/
function addFilaPLS(cCodPeg, cCodLdp, cTipGui, cNumGui, cSequen)
local oFila	   as object 
local lSucess  as logical

default cCodPeg := ''
default cCodLdp := ''
default cTipGui := '02'
default cNumGui := ''
default cSequen := ''

oFila   := filaPContas():New()

lSucess := oFila:setupFila()
if empty(cCodPeg) .or. empty(cCodLdp) 
    lSucess := .f.
endif

if lSucess    
    oFila:setTipGui(cTipGui)
    oFila:setCodLdp(cCodLdp)
    oFila:setCodPeg(cCodPeg)
    if !(empTy(cNumGui))
    	oFila:setPriority()
    	oFila:setNumGui(cNumGui)
    endIf
    if !(empTy(cSequen))
    	oFila:setSequen(cSequen)
    endIf
   
    oFila:addFila()
   
endif

return lSucess

//funcoes para chamar a rotina manualmente, sem estar no startjob do server
//para desenvolvedor
user function fRoboGuia
    fRoboGuia(.t.)
return

user function fRoboEve
    fRoboEvent(.t.)
return

user function fRoboPeg
    fRoboPeg(.t.)
return

function PLSTime(cTexto)
	/*cHoraFim := TIME() 
    cElapsed := ElapTime( cHoraIni, cHoraFim ) 
	cHoraIni := cHoraFim
	PlsPtuLog(cTexto + " ; " + cHoraIni + " ; " + cHoraFim + " ; " + cElapsed , "ROBOPContas.log")*/
return

