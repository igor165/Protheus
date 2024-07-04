#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "FILEIO.CH"
#DEFINE CRLF chr( 13 ) + chr( 10 )
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP580
Tela MVC com FWMarkBrowse no PTU A580
@author Lucas Nonato
@since  22/05/2019
@version P12
/*/
function PLSP580() 
local cFilMaster as char
private oBrwPrinc as object

setKey(VK_F2 ,{|| PLSP580FIL(.t.) })

cFilMaster := "@R_E_C_N_O_ in (" + PLSP580FIL() + ") "
                              
oBrwPrinc:= FWMarkBrowse():New()
oBrwPrinc:SetAlias("BGQ")
oBrwPrinc:SetDescription("PTU A580" )
oBrwPrinc:SetMenuDef("PLSP580")
oBrwPrinc:AddLegend("empty(BGQ->BGQ_NUMLOT)"   , "GREEN",	"Importado" )
oBrwPrinc:AddLegend("!empty(BGQ->BGQ_NUMLOT)"  , "RED",     "Faturado" )
oBrwPrinc:SetFieldMark( 'BGQ_OK' )	
oBrwPrinc:SetAllMark( { || A270Inverte(oBrwPrinc, "BGQ") } )
oBrwPrinc:SetWalkThru(.F.)
oBrwPrinc:SetFilterDefault(cFilMaster)
oBrwPrinc:SetAmbiente(.F.)
oBrwPrinc:ForceQuitButton()
oBrwPrinc:Activate()

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP520FIL
Filtro de tela

@author    Lucas Nonato
@version   V12
@since     26/01/2017
/*/
//------------------------------------------------------------------------------------------
function PLSP580FIL(lF2)

local aPergs	:= {}
local aFilter	:= {}
local cFilter   as char
local cCodOpe   as char
default lF2  	:= .f.

aadd( aPergs,{ 1, "Operadora Credora ", space(4), "@!",'.T.','B39PLS',,40,.f. } )
aAdd( aPergs,{ 1, "Ano:",               space(4), "@R 9999", "", ""		, "", 40, .f.})
aAdd( aPergs,{ 1, "Mes:",               space(2), "@R 99", "", ""		, "", 40, .f.})
aadd( aPergs,{ 2, "Status:", 	        space(1),{ "0=Todas","1=Pendentes","2=Faturadas"},100,/*'.T.'*/,.t. } )

cFilter := " SELECT BGQ.R_E_C_N_O_ FROM " + RetSqlName("BAU") + " BAU "  
cFilter += " INNER JOIN " + RetSqlName("BGQ") + " BGQ "            
cFilter += " ON  BGQ_FILIAL = '" + xFilial("BGQ") + "' "
cFilter += " AND BGQ_CODIGO = BAU_CODIGO "

if( paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSP580',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
	if !empty(aFilter[2])
        cFilter += " AND BGQ_ANO = '" + aFilter[2] + "' "
    endif
    if !empty(aFilter[3])
        cFilter += " AND BGQ_MES = '" + aFilter[3] + "' "
    endif
    if aFilter[4] <> "0"
		if aFilter[4] == "1"
			cFilter += " AND BGQ_NUMLOT = ' ' "
		else
			cFilter += " AND BGQ_NUMLOT <> ' ' "
		endif
	endif
    cCodOpe := aFilter[1]
endif

cFilter += " AND BGQ_ST580 = '2' "
cFilter += " AND BGQ_TIPO = '2' "
cFilter += " AND BGQ.D_E_L_E_T_ = ' ' " 
cFilter += " WHERE BAU_FILIAL = '" + xFilial("BAU") + "' "

if !empty(cCodOpe)
    cFilter += " AND BAU_CODOPE = '" + cCodOpe + "' "  
endif

cFilter += " AND BAU_TIPPRE = '" + GetNewPar("MV_PLSTPIN","OPE") + "' "  
cFilter += " AND BAU.D_E_L_E_T_ = ' ' " 

if lF2
	oBrwPrinc:SetFilterDefault("@R_E_C_N_O_ in (" + cFilter + ") ")
	oBrwPrinc:Refresh()
endif

return cFilter

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef - MVC

@author    Lucas Nonato
@version   12.1.17
@since     22/05/2019
/*/
//------------------------------------------------------------------------------------------
static function MenuDef()
local aRotina := {}
	
ADD OPTION aRotina Title 'Importar' Action 'Processa({||PLSP580IMP()},"PTU A580","Processando...",.T.)' OPERATION MODEL_OPERATION_INSERT ACCESS 0
ADD OPTION aRotina Title 'Excluir'  Action 'Processa({||PLSP580DEL()},"PTU A580","Excluindo...",.T.)'   OPERATION MODEL_OPERATION_DELETE ACCESS 0
ADD OPTION aRotina Title "<F2> - Filtrar" 		Action 'PLSP580FIL(.t.)'    						    OPERATION MODEL_OPERATION_VIEW ACCESS 0 

return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP580IMP
Importação do PTU A580

@author    Lucas Nonato
@version   12.1.17
@since     22/05/2019
/*/
function PLSP580IMP()
local nFor		:= 0   		// Contador para loop
local cDirOri 	:= ""  		// Recebe diretório dos arquivos
local aArquivos	:= {}  		// Array para receber arquivos do dir.
local aLista	:= {}		// Array para listar arquivos
local lOk		:= .F.		// Flag de ausência de erros - T-sem erros F-com erros
local lRet		:= .T.    	// Variavel de retorno para verificar se foram selecionados os arquivos ou não
local cExtensao	:= "*.*" 	// Aux para extenção do arquivo
local cFile 	:= "" 		// Arquivo, incluso seu endereço
local cPath		:= getNewPar( "MV_TISSDIR","\TISS\" ) + "TEMP\" // Dir. do servidor para arquivo temporário
local aResumo   := {} 		// Registra informações do processamento para o resumo
local aErros	:= {}		// Registra o número de processamentos com problema
local cMascara	:= "Todos os Arquivos|*.*|"	
local cTitulo	:= "Selecione o diretorio dos arquivos "
local cRootPath	:= ""
local lSalvar	:= .T.		//.F. = Salva || .T. = Abre
local cArqTmp	:= "" 		// Arquivo para enviar de argumento para function de processamento
local aMatCol	:= {}		// Aux para montar a tela
local cTitulo2	:= "Selecione o(s) arquivos(s) a serem importados"
local cDesc		:= "Marca e Desmarca todos"
local aRet      := {}
local aPergs    := {}

aadd(aPergs,{ 6,"Diretório",space(100),"@!","","",85,.t.,,,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY  )})
aadd(aPergs,{ 1,"Lançamento",space(3),"@!",'.T.','BBBPLS',/*'.T.'*/,40,.t. } )
if( paramBox( aPergs,"Parâmetros - PTU A580",aRet,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosY*/,/*oDlgWizard*/,/*cLoad*/'P580P2',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
   cDirOri := alltrim(aRet[1])
   cCodLan := alltrim(aRet[2])
endif

if empty(cDirOri) // cancelou a janela de selecao do diretorio
	return
endif

// Busca por arquivos com a extenção .XTR
aArquivos := directory(cDirOri+cExtensao)

if Len(aArquivos) > 0 // Se houver algum arquivo .XTR
	
	// Monta lista de arquivos
	For nFor := 1 to len(aArquivos)
		aAdd(aLista,{aArquivos[nFor][1],DtoC(aArquivos[nFor][3]),aArquivos[nFor][4],AllTrim(transform(aArquivos[nFor][2]/1000,"@E 999,999,999.99"))+" KB",.F.})
	Next
	
	aLista := aSort(aLista,,, { |x,y| DTOS(CTOD(x[2])) < DTOS(CTOD(y[2])) })
	
	// Colunas do browse
	aAdd( aMatCol,{"Arquivo"	,'@!',200} )
	aAdd( aMatCol,{"Data"		,'@!',040} )
	aAdd( aMatCol,{"Hora"		,'@!',040} )
	aAdd( aMatCol,{"Tamanho"	,'@!',040} )
		
	// Browse para selecionar
	lOk := PLSSELOPT ( cTitulo2, cDesc, aLista, aMatCol, MODEL_OPERATION_INSERT,.T.,.T.,.F.)
	
	// Verifica se algum arquivo foi selecionado
	if lOk
		lOk := aScan(aLista,{|x| x[len(aLista[1])] == .T.}) > 0
	endif

	// Processando arquivos
	if lOk    
        for nFor := 1 To Len(aLista) 
	    	If aLista[nFor][05] .and. !empty(aLista[nFor][01]) 
                if !fileExist(aLista[nFor][01]) 
                    oFileRead := FWFileReader():New( cDirOri + aLista[nFor][01] )	
                    if oFileRead:Open()
                        gravaBGQ(oFileRead:GetAllLines(),aLista[nFor][01],cCodLan,@aResumo)
                    endif
                else
                    aadd(aResumo,{aLista[nFor][01], "Arquivo já importado anteriormente."})
                endif	
	    	endif
	    next nFor    
	
    elseif !empty(cDirOri)
    	msgAlert('Pasta não contém arquivos conforme parâmetros ou operação cancelada')
    	lRet := .F.
    endif
    if len(aResumo) > 0
        PLSCRIGEN(aResumo,{{"Nome do arquivo","@C",80},{"Descrição","@C",80}},"Resumo do processamento")
    endif
endif
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} gravaBGQ
Grava BGQ

@author    Lucas Nonato
@version   12.1.17
@since     22/05/2019
/*/
static function gravaBGQ(aLine, cFile, cCodLan, aResumo)
local cLine     := aLine[1]
local lOk       := .t.
default aResumo := {}

if substr(cLine,9,3) <> "581"
    aadd(aResumo,{cFile, "Arquivo não suportado"})
    lOk := .f.
endif

if lOk .and. plsintpad() <> substr(cLine,12,4)
    aadd(aResumo,{cFile, "Operadora destino não é a operadora padrão."})
    lOk := .f.
endif

if lOk
    cSql := " SELECT BAU_CODIGO, BAU_NOME FROM " + RetSqlName("BAU") + " BAU "
    cSql += " WHERE BAU_FILIAL = '" + xFilial("BAU") + "' "
    cSql += " AND BAU_CODOPE = '" + substr(cLine,16,4)  + "' " 
	cSql += " AND BAU.D_E_L_E_T_ = ' ' "
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBAU",.F.,.T.)

    if TrbBAU->(!eof())
        BGQ->(RecLock("BGQ",.T.))
	    BGQ->BGQ_FILIAL := xFilial("BGQ")
	    BGQ->BGQ_CODSEQ := GetSX8Num("BGQ","BGQ_CODSEQ")
	    BGQ->BGQ_CODIGO := TrbBAU->BAU_CODIGO
	    BGQ->BGQ_NOME   := TrbBAU->BAU_NOME
	    BGQ->BGQ_ANO    := cvaltochar(year(date()))
	    BGQ->BGQ_MES    := strzero(month(date()),2)
	    BGQ->BGQ_CODLAN := cCodLan
	    BGQ->BGQ_VALOR  := val(substr(cLine,59,14))/100
	    BGQ->BGQ_TIPO   := "2"
	    BGQ->BGQ_INCIR  := "0"
	    BGQ->BGQ_INCCSL := "0"
	    BGQ->BGQ_INCCOF := "0"
	    BGQ->BGQ_INCPIS := "0"
	    BGQ->BGQ_INCINS := "0"
	    BGQ->BGQ_INCIR  := "0"
        BGQ->BGQ_INCISS := "0"
	    BGQ->BGQ_CODOPE := substr(cLine,12,4)
	    BGQ->BGQ_OBS    := upper(cFile)
	    BGQ->BGQ_LANAUT := "1"
        BGQ->BGQ_TIPOCT := "2"           
	    BGQ->BGQ_INTERC := "0"
        BGQ->BGQ_ATIVO  := "1"
	    BGQ->BGQ_CONMFT := "0"
        BGQ->BGQ_ST580  := "2" 
        BGQ->BGQ_ID580  := cvaltochar(val(substr(cLine,130,2)))
	    BGQ->(MsUnLock())
        aadd(aResumo,{cFile, "Importado com sucesso!"})
    else
        aadd(aResumo,{cFile, "RDA da operadora ["+substr(cLine,16,4)+"] não encontrado"})
    endif

    TrbBAU->(dbclosearea())
endif

return aResumo

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fileExist
Verifica se o arquivo ja foi importado antes

@author    Lucas Nonato
@version   12.1.17
@since     22/05/2019
/*/
static function fileExist(cArq)
local cSql as char
local lRet as logical

cSql := " SELECT 1 FROM " + RetSqlName("BGQ") + " BGQ WHERE BGQ_OBS = '" + upper(cArq) + "' AND D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbQtd",.F.,.T.)

if TrbQtd->(eof())
    lRet := .f.
else
    lRet := .t.
endif

TrbQtd->(dbclosearea())

return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP580DEL
Exclui lotes importados

@author    Lucas Nonato
@version   12.1.17
@since     22/05/2019
/*/
function PLSP580DEL
local aResumo := {}
cSql := " SELECT BGQ.R_E_C_N_O_ Recno, BGQ_NUMLOT, BGQ_CODSEQ " 
cSql += " FROM " + RetSqlName("BGQ") + " BGQ "
cSql += " WHERE BGQ_FILIAL = '" + xfilial("BGQ") + "' "
cSql += " AND BGQ_OK = '" + oBrwPrinc:cMark + "' "
cSql += " AND BGQ_ST580 = '2' "
cSql += " AND BGQ.D_E_L_E_T_ = ' '  "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMP580",.F.,.T.)

while TMP580->(!eof())
    if empty(TMP580->BGQ_NUMLOT)
        BGQ->(dbgoto(TMP580->Recno))
        BGQ->(reclock("BGQ",.f.))
        BGQ->(DbDelete())
        BGQ->(msunlock())
        aadd(aResumo,{TMP580->BGQ_CODSEQ, "Excluido com sucesso!"})
    else
        aadd(aResumo,{TMP580->BGQ_CODSEQ, "Registro já pago não pode ser excluido!"})
    endif
    TMP580->(dbskip())
enddo
TMP580->(dbclosearea())

if len(aResumo) > 0
    PLSCRIGEN(aResumo,{{"Código","@C",80},{"Descrição","@C",80}},"Resumo do processamento")
endif

return 

