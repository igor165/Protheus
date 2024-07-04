#INCLUDE "TOTVS.CH"

#define LOWERCASE   'abcdefghijklmnopqrstuvwxyz'
#define UPPERCASE   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
#define NUMBERS     '1234567890'
#define SPECIAL     '`~!@#$%^&*()-=_+[]{}|;\:",./<>?' + '''
#define HEX         '123456789ABCDEF'

#define WAITING         '1'
#define PROCESSING      '2'
#define FINISHED        '3'

#define CODINT      plsintpad()
#define NOPRIORITY  '0'
#define PRIORITY    '1'
#define ORACLE      substr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE" 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} filaPContas
Classe referente a engine de fila do processamento de guias.

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
class filaPContas
    data cTableP
    data cTableG
    data cTableE
    data cError
    data nExpire
    data cPriority
    data cToken
    data cCodUsrSys
    
    data cTipGui
    data cCodLdp
    data cCodPeg
    data cNumGui
    data cSequen
	
    method New(cTableP,cTableG,cTableE) Constructor
    method criaFila(cTable)
    method setupFila()
    method initFila(cTable)
    method testAlias(cSql)
    method commit(cSql)
    method executaQuery(cSql)
    method addFila()
    method addGuia()
    method addEvento()
    method setToken(cToken)
    method setTipGui(cTipGui)
    method setCodLdp(cCodLdp)
    method setCodPeg(cCodPeg)
    method setNumGui(cNumGui)
    method setSequen(cSequen)
    method setPriority()
    method newToken()
    method getPeg()
    method getPegOk()
    method getGuia()
    method getGuiaOk()
    method getEvento()
    method setStatus(cToken,cStatus)
    method dropMsg()
    method fimEvento()
    method fimGuia()
    method close()
    method lock()
    method getExpiredEve()
    method chkFimFila()
    method setCodSys()
    method guiaNaoProc() 
    method closeArea() 
    method getEveError() 
    method getGuiError() 
    
endClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Inicialização da classe

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method New(cTableP,cTableG,cTableE) class filaPContas
    default cTableP := "TABPEG"+cEmpAnt
    default cTableG := "TABGUI"+cEmpAnt
    default cTableE := "TABEVE"+cEmpAnt

    self:cTableP    := cTableP
    self:cTableG    := cTableG
    self:cTableE    := cTableE
    self:nExpire    := 0
    self:cError     := ""
    self:cPriority  := NOPRIORITY
    self:cTipGui    := "02"
    self:cCodLdp    := ""
    self:cCodPeg    := ""
    self:cNumGui    := ""
    self:cSequen    := ""
    self:cCodUsrsys	:= ""

    self:setupFila()

return self

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} criaFila
Cria a tabela temporaria 

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method criaFila(cTable) Class filaPContas
local cSql      as char

cSql := " CREATE TABLE " + cTable + " ( "
cSql += "     TOKEN      varchar(64),
cSql += "     EXPIRETIME int,
cSql += "     QTD        int, 
cSql += "     TIPGUI     varchar(2),               
cSql += "     CODLDP     varchar(4),               
cSql += "     CODPEG     varchar(8),
cSql += "     NUMGUI     varchar(8),
cSql += "     SEQUEN     varchar(3),
cSql += "     CODPAD     varchar(2),
cSql += "     CODPRO     varchar(16),
cSql += "     MATRIC     varchar(17),
cSql += "     PRIORITY   varchar(1),
cSql += "     STATUS     varchar(1),
cSql += "     EXPIREQTD  int,
cSql += "     CODUSRSYS  varchar(6)
cSql += " ) "

nSucess := iif(self:commit(cSql),1,0)

return nSucess

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setupFila
Inicia a estrutura de filas

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method setupFila() class filaPContas
local lRetP as logical
local lRetG as logical 
local lRetE as logical
/*local lRet := varsetuid("abc", .t.)

if !lRet
	return lRet
endif*/

lRetP := self:initFila(self:cTableP)
lRetG := self:initFila(self:cTableG)
lRetE := self:initFila(self:cTableE)

return iif(lRetP .and. lRetG .and. lRetE, .t., .f.)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} initFila
Inicia a estrutura de filas

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method initFila(cTable) class filaPContas
local nRet as numeric
local cSql as char

cSql := "SELECT * FROM " + cTable

if self:testAlias(cSql)
    nRet := 0
else
    nRet := self:criaFila(cTable)
endif

if nRet != 0
    self:cError := "### ERRO ### " + "Erro ao fazer o Setup" + " Erro: " + AllTrim(Str(nRet))
endif

return nRet == 0

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} testAlias
Verifica se a tabela ja esta criada, caso não estiver cria.

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method testAlias(cSql) class filaPContas
local lRet  := .F.
default cSql := ""
if !empty(cSql) 
   lRet := TCSqlExec( cSql ) >= 0 
endif
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} commit
Executa query 

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method commit(cSql) class filaPContas
local lRet  := .F.
if !empty(cSql)    
    lRet := TcSqlEXEC(cSql) >= 0
    if lRet .and. ORACLE
       	lRet := TcSqlEXEC("COMMIT") >= 0
    endif
endif

return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} executaQuery
Executa query 

@author    Lucas Nonato
@version   V12
@since     11/06/2019
/*/
method executaQuery(cSql) class filaPContas
local cAlias := "CMDFILA"
local lRet  := .F.
if !empty(cSql)     
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)
    if (cAlias)->(!eof())
        lRet := .t.
    endif
endif

return lRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} closeArea
Fecha o alias da query 

@author    Lucas Nonato
@version   V12
@since     11/06/2019
/*/
method closeArea(cAlias) class filaPContas
default cAlias := "CMDFILA"

(cAlias)->(dbCloseArea())

return .t.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} addFila
Adiciona o que foi enviado na fila.

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method addFila() class filaPContas
local cSql      as char
local cToken    as char
local lRet      as logical
local nQtd      as numeric
local cAlias    as char
local cAliQtd   as char

cToken := self:newToken()

if empty(self:cNumGui)
    if self:cTipGui == '05' .or. self:cTipGui == '03'
        cAlias := "BE4"
    else
        cAlias := "BD5"
    endif
    cSql := " SELECT COUNT(*) QTD, "+ cAlias +"_CODPEG FROM " + RetSqlName(cAlias)
    cSql += " WHERE "+ cAlias +"_FILIAL = '"+ xFilial(cAlias) +"' "
    cSql += " AND "+ cAlias +"_CODOPE = '"+ CODINT +"' "
    cSql += " AND "+ cAlias +"_CODLDP = '"+ self:cCodLdp +"' "
    cSql += " AND "+ cAlias +"_CODPEG = '"+ self:cCodPeg +"' "
    cSql += " AND "+ cAlias + "_SITUAC = '1' "
    cSql += " AND "+ cAlias + "_FASE = '1' "
    cSql += " AND D_E_L_E_T_ = ' ' "
    cSql += " GROUP BY "+ cAlias +"_CODPEG "
    cAliQtd := getNextAlias()
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliQtd,.F.,.T.)
    nQtd := (cAliQtd)->QTD
    (cAliQtd)->(dbCloseArea())
else
    nQtd := 1
endif

cSql := "INSERT INTO " + self:cTableP 
cSql += " (TOKEN,EXPIRETIME,QTD,PRIORITY,STATUS,TIPGUI,CODLDP,CODPEG,NUMGUI,SEQUEN,EXPIREQTD,CODUSRSYS) VALUES ("
cSql += "'" + cToken + "', "  
cSql += " " + alltrim(str(0)) + ", "
cSql += " " + alltrim(str(nQtd)) + ", "
cSql += "'" + self:cPriority + "', "
cSql += "'" + WAITING + "', "
cSql += "'" + self:cTipGui + "', "
cSql += "'" + self:cCodLdp + "', "
cSql += "'" + self:cCodPeg + "', "
cSql += "'" + self:cNumGui + "', "
cSql += "'" + self:cSequen + "', "
cSql += " " + '0' + " , "
cSql += "'" + self:cCodUsrsys + "' ) "
lRet:= .t.
if !self:commit(cSql)
    lRet:= .f.
    self:cError := "### ERRO ### " + "Erro ao enviar mensagem" + " Erro: " + TCSqlError()
endif   

return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} addGuia
Adiciona guias na fila e controla a quantidade

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method addGuia() class filaPContas
local cSql      as char
local lRet      as logical
local cAlias    as char
local cAliTmp   as char
local cAliQtd   as char
local nQtd      as numeric

cAliTmp	:= getNextAlias()

if self:cTipGui == '05' .or. self:cTipGui == '03'
    cAlias := "BE4"
else
    cAlias := "BD5"
endif

//Tratar caso mande somente a PEG
cSql := " SELECT " + cAlias + "_NUMERO NUMGUI FROM  " + RetSqlName(cAlias) + " " + cAlias
cSql += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += " AND " + cAlias + "_CODOPE = '" + CODINT + "' "
cSql += " AND " + cAlias + "_CODLDP = '" + self:cCodLdp + "' "
cSql += " AND " + cAlias + "_CODPEG = '" + self:cCodPeg + "' "
if !empty(self:cNumGui)
    cSql += " AND " + cAlias + "_NUMERO = '" + self:cNumGui + "' "
endif
cSql += " AND " + cAlias + "_SITUAC = '1' "
cSql += " AND " + cAlias + "_FASE = '1' "
cSql += " AND D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliTmp,.F.,.T.)

lRet:= .t.

if (cAliTmp)->(eof())
    self:close()
endif

while !(cAliTmp)->(eof())
    if empty(self:cSequen)
        cSql := " SELECT COUNT(*) QTD, BD6_NUMERO FROM  " + RetSqlName("BD6") + " BD6 "
        cSql += " WHERE BD6_FILIAL = '" + xFilial(cAlias) + "' "
        cSql += " AND BD6_CODOPE = '" + CODINT + "' "
        cSql += " AND BD6_CODLDP = '" + self:cCodLdp + "' "
        cSql += " AND BD6_CODPEG = '" + self:cCodPeg + "' "
        cSql += " AND BD6_NUMERO = '" + (cAliTmp)->NUMGUI + "' "
        cSql += " AND BD6_FASE = '1' "
        cSql += " AND BD6.D_E_L_E_T_ = ' ' "
        cSql += " GROUP BY BD6_NUMERO "
        cAliQtd := getNextAlias()
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliQtd,.F.,.T.)
        nQtd := (cAliQtd)->QTD
        (cAliQtd)->(dbCloseArea())
    else
        nQtd := 1
    endif

    cSql := "INSERT INTO " + self:cTableG 
    cSql += " (TOKEN,EXPIRETIME,QTD,PRIORITY,STATUS,TIPGUI,CODLDP,CODPEG,NUMGUI,SEQUEN,EXPIREQTD) VALUES ("
    cSql += "'" + self:cToken + "', "  
    cSql += "'" + alltrim(str(val(FWTimeStamp(4)))) + "', "
    cSql += "'" + alltrim(str(nQtd)) + "', "
    cSql += "'" + self:cPriority + "', "
    cSql += "'" + WAITING + "', "
    cSql += "'" + self:cTipGui + "', " 
    cSql += "'" + self:cCodLdp + "', "
    cSql += "'" + self:cCodPeg + "', "
    cSql += "'" + (cAliTmp)->NUMGUI + "', "
    cSql += "'" + self:cSequen + "', "
    cSql += " " + '0' + " ) "
    if !self:commit(cSql)
        lRet:= .f.
        self:cError := "### ERRO ### " + "Erro ao enviar mensagem" + " Erro: " + TCSqlError()
    endif
    (cAliTmp)->(dbskip()) 
enddo
   
(cAliTmp)->(dbCloseArea())
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} addEvento
Adiciona eventos na fila e controla a quantidade

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method addEvento() class filaPContas
local cSql      as char
local lRet      as logical
local cAliTmp   as char

cAliTmp	:= getNextAlias()

cSql := " SELECT BD6_SEQUEN, BD6_CODPAD, BD6_CODPRO, BD6_OPEUSR, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_DIGITO FROM  " + RetSqlName('BD6') + " BD6 "  
cSql += " WHERE BD6_FILIAL = '" + xFilial('BD6') + "' "
cSql += " AND BD6_CODOPE = '" + CODINT + "' "
cSql += " AND BD6_CODLDP = '" + self:cCodLdp + "' "
cSql += " AND BD6_CODPEG = '" + self:cCodPeg + "' "
cSql += " AND BD6_NUMERO = '" + self:cNumGui + "' "
if !empty(self:cSequen)
    cSql += " AND BD6_SEQUEN = '" + self:cSequen + "' "
endif
cSql += " AND BD6_FASE = '1' "
cSql += " AND D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliTmp,.F.,.T.)

lRet:= .t.

while !(cAliTmp)->(eof())
    cSql := "INSERT INTO " + self:cTableE 
    cSql += " (TOKEN,EXPIRETIME,QTD,PRIORITY,STATUS,TIPGUI,CODLDP,CODPEG,NUMGUI,SEQUEN,CODPAD,CODPRO,MATRIC,EXPIREQTD) VALUES ("
    cSql += "'" + self:cToken + "', "  
    cSql += "'" + alltrim(str(val(FWTimeStamp(4)))) + "', "
    cSql += "'" + alltrim(str(1)) + "', "
    cSql += "'" + self:cPriority + "', "
    cSql += "'" + WAITING + "', "
    cSql += "'" + self:cTipGui + "', "
    cSql += "'" + self:cCodLdp + "', "
    cSql += "'" + self:cCodPeg + "', "
    cSql += "'" + self:cNumGui + "', "
    cSql += "'" + (cAliTmp)->BD6_SEQUEN + "', "
    cSql += "'" + (cAliTmp)->BD6_CODPAD + "', "
    cSql += "'" + (cAliTmp)->BD6_CODPRO + "', "
    cSql += "'" + (cAliTmp)->BD6_OPEUSR + (cAliTmp)->BD6_CODEMP + (cAliTmp)->BD6_MATRIC + (cAliTmp)->BD6_TIPREG + (cAliTmp)->BD6_DIGITO + "', "
    csql += " " + '0' + " ) "
    if !self:commit(cSql)
        lRet:= .f.
        self:cError := "### ERRO ### " + "Erro ao enviar mensagem" + " Erro: " + TCSqlError()
    endif
    (cAliTmp)->(dbskip())
enddo
   
(cAliTmp)->(dbCloseArea())
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setCodLdp

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method setCodLdp(cCodLdp) class filaPContas
return self:cCodLdp := cCodLdp

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setCodPeg

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method setCodPeg(cCodPeg) class filaPContas
return self:cCodPeg := cCodPeg

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setNumGui

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method setNumGui(cNumGui) class filaPContas
return self:cNumGui := cNumGui

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setSequen

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method setSequen(cSequen) class filaPContas
return self:cSequen := cSequen

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setPriority

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method setPriority() class filaPContas
return self:cPriority := PRIORITY

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setToken

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method setToken(cToken) class filaPContas
return self:cToken := cToken

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setTipGui

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method setTipGui(cTipGui) class filaPContas
if !empty(cTipGui)
    self:cTipGui := cTipGui
endif
return self:cTipGui

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setCodLdp

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method setCodSys(cCodUsrSys) class filaPContas
return self:cCodUsrSys := cCodUsrSys

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getPeg
Verifica se tem alguma PEG na fila para processar

@author    Lucas Nonato
@version   V12
/*/
method getPeg(cStatusBus, cStatusUpd, lOk) class filaPContas
local nRet      as numeric
local cSql      as char
local cOracle   as char
local cSqlTop   as char
default cStatusBus := WAITING
default cStatusUpd := PROCESSING
default lOk     := .f.

nRet := -1
cSqlTop := ""
cOracle := ""
if ORACLE
    cOracle := " AND ROWNUM = 1 "
else
    cSqlTop := " TOP(1) "
endif

cSql := " SELECT " + cSqlTop + " TOKEN, TIPGUI, CODLDP, CODPEG, NUMGUI, SEQUEN, CODUSRSYS FROM " + self:cTableP
if lOk
    cSql += " WHERE QTD <= 0 "
else
    cSql += " WHERE STATUS = '" + cStatusBus + "' " 
endif
cSql += cOracle
cSql += " ORDER BY PRIORITY

if self:executaQuery(cSql) 
	self:closeArea()
	self:lock(self:cTableP)	
	if self:executaQuery(cSql) 
	    if !empty(CMDFILA->TOKEN)
	        self:setToken( CMDFILA->TOKEN)
	        self:setTipGui(CMDFILA->TIPGUI)
	        self:setCodLdp(CMDFILA->CODLDP)
	        self:setCodPeg(CMDFILA->CODPEG)
	        self:setNumGui(CMDFILA->NUMGUI)
	        self:setSequen(CMDFILA->SEQUEN)
	        self:setCodSys(CMDFILA->CODUSRSYS)
	        if !empty(CMDFILA->TOKEN) .and. self:setStatus(CMDFILA->TOKEN, self:cTableP, cStatusUpd)        
	            nRet := 0
	        endif
	    endif	    
	endif
    self:lock(self:cTableP, .t.)		
endif

self:closeArea()

return nRet == 0 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getPegOk
Verifica se tem alguma PEG finalizada na fila para processar

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method getPegOk() class filaPContas
local lRet as logical
    lRet := self:getPeg(PROCESSING, FINISHED, .t.)     
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getGuiaOk
Verifica se tem alguma guia finalizada na fila para processar

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method getGuiaOk() class filaPContas
local lRet as logical
    lRet := self:getGuia(PROCESSING, FINISHED, .t.) 
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getGuia
Verifica se tem alguma guia na fila para processar

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method getGuia(cStatusBus, cStatusUpd, lOk) class filaPContas
local cSql      as char
local nRet      as numeric
local cOracle   as char
local cSqlTop   as char
default cStatusBus := WAITING
default cStatusUpd := PROCESSING
default lOk     := .f.
cSqlTop := ""
cOracle := ""
nRet := -1

if ORACLE
    cOracle := " AND ROWNUM = 1 "
else
    cSqlTop := " TOP(1) "
endif

cSql := " SELECT " + cSqlTop + " * FROM " + self:cTableG
cSql += " WHERE STATUS = '" + cStatusBus + "' "
if lOk
    cSql += " AND QTD <= 0 "
endif
cSql += cOracle
cSql += " ORDER BY PRIORITY "

if self:executaQuery(cSql) 
	self:closeArea()
	self:lock(self:cTableG)
	if self:executaQuery(cSql)     
	    self:setToken( CMDFILA->TOKEN)
	    self:setTipGui(CMDFILA->TIPGUI)
	    self:setCodLdp(CMDFILA->CODLDP)
	    self:setCodPeg(CMDFILA->CODPEG)
	    self:setNumGui(CMDFILA->NUMGUI)
	    self:setSequen(CMDFILA->SEQUEN)
	    if !empty(CMDFILA->TOKEN) .and. self:setStatus(CMDFILA->TOKEN, self:cTableG, cStatusUpd, self:cNumGui)
	        nRet := 0
	    endif	    
	endif
	self:lock(self:cTableG, .t.)
endif

self:closeArea()

return nRet == 0

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getEvento
Verifica se tem algum evento na fila para processar

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method getEvento() class filaPContas
local cSql      as char
local nRet      as numeric
local cOracle   as char
local cSqlTop   as char
/*
cSql := " SELECT * FROM " + self:cTableE + " TAB1 "
cSql += " WHERE STATUS = '" + WAITING + "' "
csql += " AND NOT EXISTS( Select * from " + self:cTableE + " TAB2 "
cSql += " Where TAB1.CODPAD = TAB2.CODPAD AND TAB1.CODPRO = TAB2.CODPRO AND TAB1.MATRIC = TAB2.MATRIC AND TAB2.STATUS = '" + PROCESSING + "') "
cSql += " ORDER BY PRIORITY DESC LIMIT 1 "
*/
cSqlTop := ""
cOracle := ""

if ORACLE
    cOracle := " AND ROWNUM = 1 "
else
    cSqlTop := " TOP(1) "
endif

cSql := " SELECT " + cSqlTop + " T1.TOKEN TOKEN, T1.TIPGUI TIPGUI, T1.CODLDP CODLDP, T1.CODPEG CODPEG, T1.NUMGUI NUMGUI, T1.SEQUEN SEQUEN, T1.PRIORITY PRIORITY "
cSql += " FROM " + self:cTableE + " T1 "
cSql += " LEFT JOIN " + self:cTableE + " T2 "
cSql += " ON  T1.CODPAD = T2.CODPAD "
cSql += " AND T1.CODPRO = T2.CODPRO "
cSql += " AND T1.MATRIC = T2.MATRIC "
cSql += " AND T2.STATUS = '" + PROCESSING + "' "
cSql += " WHERE T1.STATUS = '" + WAITING + "' "
cSql += " AND   COALESCE(T2.CODPEG, '0') = '0' " 
cSql += cOracle
cSql += " ORDER BY PRIORITY "

nRet := -1

if self:executaQuery(cSql) 
	self:closeArea()
	self:lock(self:cTableE)
	if self:executaQuery(cSql)
        self:setToken( CMDFILA->TOKEN)
        self:setTipGui(CMDFILA->TIPGUI)
        self:setCodLdp(CMDFILA->CODLDP)
        self:setCodPeg(CMDFILA->CODPEG)
        self:setNumGui(CMDFILA->NUMGUI)
        self:setSequen(CMDFILA->SEQUEN)
        if !empty(CMDFILA->TOKEN) .and. self:setStatus(CMDFILA->TOKEN, self:cTableE,/*cStatus*/, self:cNumGui, CMDFILA->SEQUEN)
            nRet := 0
        endif
    endif
    self:lock(self:cTableE, .t.)
endif

self:closeArea()


return nRet == 0

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} newToken
Gera um token

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method newToken() class filaPContas
local nLen      := 64
local nChar     := 0
local cChars    := LOWERCASE+UPPERCASE+NUMBERS+HEX
local cToken    := ""

for nChar := 1 to nLen
    cToken += SubStr(cChars,Randomize( 1,65 ),1)
next nChar

return cToken

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setStatus
Controle de status da fila

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method setStatus(cToken,cTable,cStatus,cNumGui,cSequen) class filaPContas
local nRet := -1
local cSql as char

default cToken  := ""
default cTable  := self:cTableP
default cStatus := PROCESSING
default cNumGui := ""
default cSequen := ""

cSql := "UPDATE " + cTable + " SET STATUS = '" + cStatus + "' "
if !empty(cSequen)
    cSql += ", EXPIRETIME = " + Alltrim(str(val(FWTimeStamp(4)) + 50))
endif

cSql += " WHERE TOKEN = '" + cToken + "' "
if !empty(cNumGui)
    cSql += " AND NUMGUI = '" + cNumGui + "' "
    if !empty(cSequen)
         cSql += " AND SEQUEN = '" + cSequen + "' "
    endif
endif

if self:commit(cSql)
    nRet := 0
endif

if nRet != 0
    self:cError := "### ERRO ### " + "Erro ao colocar a mensagem em processamento" + " Erro: " + AllTrim(Str(nRet))
endif

return nRet == 0

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} dropMsg
Dropa a tabela

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method dropMsg() class filaPContas
local nRet := -3
local cSql := ""

cSql := "DROP TABLE " + self:cTableP
if self:commit(cSql)
    nRet += 1
endif

cSql := "DROP TABLE " + self:cTableG
if self:commit(cSql)
    nRet += 1
endif

cSql := "DROP TABLE " + self:cTableE
if self:commit(cSql)
    nRet += 1
endif

if nRet != 0
    self:cError := "### ERRO ### " + "Erro ao remover mensagem" + " Erro: " + AllTrim(Str(nRet))
endif

return nRet == 0

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fimEvento
Finaliza o evento

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method fimEvento() class filaPContas
local cSql as char
local nRet as numeric
nRet := -1

cSql := "UPDATE " + self:cTableG + " SET QTD = QTD - 1 WHERE TOKEN = '" + self:cToken + "' AND NUMGUI = '" + self:cNumGui +"'"

if self:commit(cSql)
    nRet := 0
endif

cSql := "UPDATE " + self:cTableE + " SET STATUS = '" + FINISHED + "' WHERE TOKEN = '" + self:cToken + "' AND NUMGUI = '" + self:cNumGui +"' AND SEQUEN = '" + self:cSequen + "'"

if self:commit(cSql)
    nRet := 0
endif

if nRet != 0
    self:cError := "### ERRO ### " + "Erro ao colocar a mensagem em processamento" + " Erro: " + AllTrim(Str(nRet))
endif   

return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fimGuia
Finaliza a guia

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method fimGuia() class filaPContas
local cSql as char
local nRet as numeric

cSql := "UPDATE " + self:cTableG + " SET STATUS = '" + FINISHED + "' WHERE TOKEN = '" + self:cToken + "' AND NUMGUI = '" + self:cNumGui +"'"

if self:commit(cSql)
    nRet := 0
endif

cSql := "UPDATE " + self:cTableP + " SET QTD = QTD - 1 WHERE TOKEN = '" + self:cToken + "'"

if self:commit(cSql)
    nRet := 0
endif

if nRet != 0
    self:cError := "### ERRO ### " + "Erro ao colocar a mensagem em processamento" + " Erro: " + AllTrim(Str(nRet))
endif

return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} close
Finaliza todo o processo(PEG, Guia e Evento)

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method close() class filaPContas
local nRet := -3
local cSql := ""

cSql := "DELETE FROM " + self:cTableP + " WHERE TOKEN = '" + self:cToken + "' "
if self:commit(cSql)
    nRet += 1
endif

cSql := "DELETE FROM " + self:cTableG + " WHERE TOKEN = '" + self:cToken + "' "
if self:commit(cSql)
    nRet += 1
endif

cSql := "DELETE FROM " + self:cTableE + " WHERE TOKEN = '" + self:cToken + "' "
if self:commit(cSql)
    nRet += 1
endif

if nRet != 0
    self:cError := "### ERRO ### " + "Erro ao remover mensagem" + " Erro: " + AllTrim(Str(nRet))
endif

return nRet == 0

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} lock
Controle de semaforo

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
method lock(cName, lLibera ) class filaPContas
local lOk as logical
default lLibera := .f.

lOk := .t.
/*
if lLibera
	varEndT("abc",cName)
else
	varBeginT("abc",cName)
endif*/

if !lLibera
	while lOk 
		if LockByName(cName, .T., .T.)
			lOk := .f.
		endif
	enddo
else
	UnlockByName(cName, .T., .T.)
endif

return .t.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getExpiredEve
Controle de tempo

@author    Lucas Nonato
@version   V12
@since     19/04/2019
/*/
method getExpiredEve() class filaPContas
local lRet as logical
local cSql as char
lRet := .f.

cSql := " SELECT * FROM " + self:cTableE
cSql += " WHERE STATUS = '" + PROCESSING + "' AND EXPIRETIME <= " + Alltrim(STR(VAL(FWTimeStamp(4))))

self:lock('EXPIRETIME')

if self:executaQuery(cSql)
    if !empty(CMDFILA->TOKEN)
        lRet := .t.
        cSql := " UPDATE " + self:cTableE + " SET STATUS = '" + WAITING + "',  EXPIREQTD = EXPIREQTD + 1 "
        cSql += " WHERE STATUS = '" + PROCESSING + "' AND EXPIRETIME <= " + Alltrim(STR(VAL(FWTimeStamp(4))))
        if !self:commit(cSql) 
            self:cError := "### ERRO ### " + "Erro ao atualizar evento vencido" + " Erro: " + alltrim(str(1))
        endif
    endif    
endif

self:closeArea()
self:lock('EXPIRETIME', .t.)

return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} chkFimFila

@author    PLS TEAM
@version   V12
@since     19/04/2019
/*/
method chkFimFila() class filaPContas
local cSql as char
local lRet := .T.

cSql := " SELECT 1 FROM " + self:cTableG 
cSql += " WHERE CODPEG = '" + self:cCodPeg + "' "
if !(empty(self:cNumGui))
    cSql += " AND NUMGUI = '"   + self:cNumGui + "' "
endif

if self:executaQuery(cSql)    
    lRet := .F.     
endif

self:closeArea()

return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} guiaNaoProc

@author    PLS TEAM
@version   V12
@since     19/04/2019
/*/
method guiaNaoProc() class filaPContas

Local cSql := ""
Local nRet := -9

cSql := "UPDATE " + self:cTableG + " SET QTD = 0 WHERE TOKEN = '" + self:cToken + "' AND NUMGUI = '" + self:cNumGui +"'"

if self:commit(cSql)
    nRet := 0
endif

return nRet == 0

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getEveError
Pega registros que deram erro e tira da fila

@author    Lucas Nonato
@version   V12
@since     10/09/2019
/*/
method getEveError() class filaPContas
local lRet as logical
local cSql as char
lRet := .f.

cSql := " SELECT * FROM " + self:cTableE
cSql += " WHERE EXPIREQTD >= '5' " 

self:lock('EXPIREQTD')

if self:executaQuery(cSql)
    self:setToken(CMDFILA->TOKEN)  
    self:close() 
endif

self:closeArea()
self:lock('EXPIREQTD', .t.)

return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getGuiError
Remove erros de integridade onde uma guia não possuia eventos(Sul Capixaba)

@author    Lucas Nonato
@version   V12
@since     17/10/2019
/*/
method getGuiError() class filaPContas
local lRet as logical
local cSql as char
lRet := .f.

cSql := " SELECT G.* FROM " + self:cTableG + " G "
cSql += " LEFT JOIN " + self:cTableE + " E "
cSql += " ON G.TOKEN = E.TOKEN "
cSql += " AND G.CODPEG = E.CODPEG "
cSql += " AND G.NUMGUI = E.NUMGUI "
cSql += " WHERE E.TOKEN IS NULL "
cSql += " AND G.STATUS = '2' "
cSql += " AND G.EXPIRETIME+100 <= " + alltrim(str(val(FWTimeStamp(4))))

if lockByName('EXPIREQTDG', .T., .T.)//Aqui uso direto pois não quero que os outros jobs fiquem aguardando...
    if self:executaQuery(cSql)
        while !CMDFILA->(eof())
            cSql := " UPDATE " + self:cTableG
            cSql += " SET QTD = 0 "
            cSql += " WHERE TOKEN = '" + CMDFILA->TOKEN + "'"
            cSql += " AND CODLDP = '" + CMDFILA->CODLDP + "'"
            cSql += " AND CODPEG = '" + CMDFILA->CODPEG + "'"
            cSql += " AND NUMGUI = '" + CMDFILA->NUMGUI + "'"
            self:commit(cSql)

            cSql := "UPDATE " + self:cTableP + " SET QTD = QTD - 1 WHERE TOKEN = '" + CMDFILA->TOKEN + "'"
            self:commit(cSql)

            CMDFILA->(dbskip())
        enddo
    endif

    self:closeArea()
    self:lock('EXPIREQTDG', .t.)
endif

return lRet
