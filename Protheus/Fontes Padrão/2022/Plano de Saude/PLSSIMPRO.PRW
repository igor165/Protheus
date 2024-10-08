#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'Totvs.CH'
#Include 'topconn.ch'
#include 'PLSSIMPRO.ch'

static cTxtTmp	:= "CALTTXTSIN"
static aOperLog	:= {}
static cOperad	:= ""
static cDataLog	:= dtoc(msdate())

//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSSIMPRO
Tela inicial de Importa��es da Simpro
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSSIMPRO(lAutoma, aDadAuto)
local oBrowse   := nil
local cCodOpe	:= PlsIntpad()
lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )

cOperad	:= upper( alltrim(UsrRetName(RetCodUsr())) )
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B6F')
oBrowse:SetFilterDefault("@(B6F_FILIAL = '" + xFilial("B6F") + "' AND B6F_CODOPE = '" + cCodOpe + "') AND B6F_TPARQ = '2' ")
oBrowse:SetDescription(STR0001)  //Importa��es Tabela Simpro�
iif( !lAutoma, oBrowse:Activate(), "")

Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  STR0002 	Action 'PLSBRASIN2(.f.)' 	    Operation 3 Access 0  //Configurar
Add Option aRotina Title  STR0003   Action 'staticCall(PLSSIMPRO, PergIniImport, .f.,{})'  Operation 3 Access 0  //Importar
Add Option aRotina Title  STR0004	Action 'VIEWDEF.PLSBRASIN1' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0036	Action 'staticCall(PLSBRASIN1, ExcBrasindice, .f.)'     Operation 9 Access 0  //Excluir

Return aRotina



//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados.
@since 04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel := FWLoadModel("PLSBRASIN1")
Return oModel

//removido, n�o h� interface desse fonte.

//-------------------------------------------------------------------
/*/ {Protheus.doc} PergIniImport
Pergunte inicial da importa��o da Simpro
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function PergIniImport(lAuto, aDadAuto)
local aPergs 		:= {}
local aRetPerg		:= {}
local aCabec 		:= {} 
local aRetAut		:= {.t., {}}
local cRodape		:= ""
local cMensLog		:= ""
local cNomeLog		:= ""
local lExecuta		:= .t.
local aTamJan		:= FwGetDialogSize()

default lAuto		:= .f.
default aDadAuto	:= {}

aadd(aPergs,{ 6, STR0006 , Space(100) , "@!","","",80,.t., STR0011 + " |*.*",,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ), .t.}) //Diret�rio dos arquivos?
aadd(aPergs,{ 1, STR0007 , Space(6)   , "@!",'.T.',,nil,40,.t. } )  //"C�digo da mensagem"
aadd(aPergs,{ 1, STR0008 , dDatabase  , "99/99/9999",'.T.',,'.t.',60,.t. } ) //"Data da mensagem"

if lAuto
	aRetPerg := aDadAuto     
elseIf !paramBox( aPergs,STR0034,aRetPerg,{|| bOKaRetP(aRetPerg)},,.t.,,,,'PLSIMPRO',.t.,.t. ) //"Importa��o Simpro -
	lExecuta := .f.
endIf


if lExecuta
    ImpTabSimpro(aRetPerg, lAuto) //Rotina de importa��o da Simpro
	
	if ( len(aOperLog) > 0 .and. !lAuto)

		aAdd(aCabec, {'Data',        {|| aOperLog[oBrowse:nAt,1] }, "C", "@!", 1, 007, 0, .f. , , .F., , "DATA" , , .F., .T., , "DATA"  }) //data
		aAdd(aCabec, {'Tipo Erro',   {|| aOperLog[oBrowse:nAt,2] }, "C", "@!", 1, 001, 0, .f. , , .F., , "ERRO" , , .F., .T., , "ERRO"  }) //"Descri��o"
		aAdd(aCabec, {'Erro',        {|| aOperLog[oBrowse:nAt,3] }, "C", "@!", 1, 400, 0, .f. , , .F., , "CERRO", , .F., .T., , "CERRO" }) //"Lote Gerado?"
		aAdd(aCabec, {'Usu�rio',     {|| aOperLog[oBrowse:nAt,4] }, "C", "@!", 1, 010, 0, .f. , , .F., , "USUAR", , .F., .T., , "USUAR" }) //"Descri��o"

	//Montagem da Modal Dialog
		oPrinWnd := PlMObjFwDial(oPrinWnd, .t., {aTamJan[4] * 0.4, aTamJan[3] * 0.3 }, STR0037, .t., .t.)	

		oFwCamada := FwLayer():New()
		oFwCamada:init(oPrinWnd:getPanelMain(), .F.) 
		oFwCamada:AddLine("LINSUP", 100, .f.)
		oLINSUP  := oFwCamada:GetLinePanel("LINSUP")

        oBrowse := PlMObjFwBrow("2", oBrowse, '', oLINSUP, cRodape, {}, {.f., .f., aCabec, aOperLog} )

        oBrowse:activate()
		oPrinWnd:activate() 

		//Grava log
		if oPrinWnd:getButtonSelected() == 1 // Se clicou em Sim vai salvar o log
			cMensLog := STR0038 + cDataLog + STR0039 + cOperad + CRLF //"Importa��o realizada no dia: /, pelo usu�rio: "
			cNomeLog := "erros_importacao_Simpro_" + strtran(cDataLog, "/", "_") + "_" + strtran(time(), ":","_")
			GrvLogPc(alltrim(aRetPerg[1]), cNomeLog, cMensLog, ".log", .t., len(aCabec) )
		endif 

	elseif lAuto .and. len(aOperLog) > 0
		aRetAut[1] := .f.
		aRetAut[2] := aclone(aOperLog)	
	endif 
endif 

LimpaArray(aOperLog)
LimpaArray(aRetPerg)

return aRetAut


//----------------------------------------------------------------
/*/ {Protheus.doc} OprLogSist
Armazenar no array aOperLog informa��es do sistema
Deve ter a seguinte estrutura: Data / N�vel Log* / Informa��o / Usu�rio
*N�vel Log: 0=Arquivo duplicado regras / 1=Info Arquivos Orf�os / 2=Erro Importa��o /
3=Registro n�o importado
@since 04/2020
@version P12 
/*/
//----------------------------------------------------------------
static function OprLogSist(cNivLog, cMsgErro)
aadd(aOperLog, {cDataLog, cNivLog, cMsgErro, cOperad})
return 


//-------------------------------------------------------------------
/*/ {Protheus.doc} LimpaArray
Fun��o para limpar arrays
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function LimpaArray (aLmpArray)
default aLmpArray   := {}

if len(aLmpArray) > 0
	while Len(aLmpArray) > 0
		aDel(aLmpArray, len(aLmpArray))
		aSize(aLmpArray, len(aLmpArray)-1)	
	enddo
	aLmpArray := {}
endif

return

//-------------------------------------------------------------------
/*/ {Protheus.doc} ImpTabSimpro
Rotina de Importa��o dos arquivos Simpro
@since 01/2021
@version P12 
/*/
//-------------------------------------------------------------------
static function ImpTabSimpro(aRetPerg, lAuto)
local aArqDir	:= {} 
local aRetFun	:= {}
local aArqOrf	:= {}
Local cCodOpe	:= PlsIntpad()
local aDadImp	:= staticCall(PLSBRASIN2, ChkVlrDup, "1", nil, cCodOpe)
local cCaminho	:= alltrim(aRetPerg[1])
local cVersao	:= alltrim(aRetPerg[2])
local cExtArq	:= "*.*"
local lRet		:= .t.
local lContinua	:= .t.
local nFor		:= 0
local nFor2     := 0
local aArquivos := 0
local aTFrmOrf 	:= {}
local oRegua	:= nil
default lAuto	:= .f.

/*ATEN��O 
O array aDadImp cont�m as informa��es da tabela B6G de configura��o, bem como ir� armazenar as regras de importa��o e os arquivos
que deram 'match' com as regras. Abaixo, a estrutura desse array, usado em todas as opera��es:
aDadImp = {lRet, aDadRet}, onde: 
	1�) lRet � o retorno l�gico, usado na rotina SIMPRO
	2�) aDadRet, cont�m o array com os dados para a rotina de importa��o.
	* aDadRet = {B6G_TIPPRO, B6G_TIPO, B6G_REGIMP, REC, {}, {}}
		1�) B6G_TIPPRO - Tipo do Item: ""1=Materiais/2=Medicamentos/4=Perfumaria/5=Saneantes/6=Reagentes""
		2�) B6G_TIPO - Tipo de Pre�o: 1=PMC;2=PFB;3=PUSU
		3�) B6G_REGIMP - Regras de Importa��o, para valida��o do nome do arquivo
		4�) REC - RECNO da regra de importa��o da B6G
		5�) Array preenchido na fun��o ChkRegImport, que gera array com o desmembramento das regras de importa��o: {MATERIAL, PMC}, {MATERIAIS, PMC}
		6�) Array que armazena os arquivos que deram match com a regra, ou seja, v�lidos.
*/
if empty(aDadImp[2])
	Help(nil, nil , STR0012, nil, STR0013, 1, 0, nil, nil, nil, nil, nil, {STR0014} ) //N�o Existe Configura��o de importa��o de Arquivos da Simpro v�lidos para a Operadora
	lContinua := .f.
else
	//Preenche a partir da 5� posi��o do array de configura��o com as strings de pesquisa
	ChkRegImport(@aDadImp[2])
endif

if lContinua

	aArquivos := directory(cCaminho+cExtArq)
	
	if len(aArquivos) > 0
		//S� aceito CSV e XML os demais ser�o ignorados
		For nFor2 := 1 to len(aArquivos)
			cExtensao := SubStr(aArquivos[nFor2,1],Rat(".",aArquivos[nFor2,1])+1)
			If !cExtensao  $ 'CSV,TXT'
				Loop
			EndIf   
			aadd(aArqDir,aClone(aArquivos[nFor2]))
		Next

	endif


	if len(aArqDir) > 0

		for nFor := 1 to len(aArqDir)	

			if ( !(cVersao $ aArqDir[nFor,1]) ) .and. (!lAuto .and. !msgyesno( ExibeMensagem("1", alltrim(aArqDir[nFor,1]), cVersao), STR0012 ) )
				lContinua := .f.	
			endif

			if lContinua
				ExecRegImp(aArqDir[nFor,1], @aDadImp[2], @aArqOrf)					
			endif
			lContinua := .t.
		next

		//Exibir janela de Desambigua��o de Arquivos X Cadastros, pois temos arquivos orf�os :-(
		if len(aArqOrf) > 0  
			Telaorfaos(aArqOrf, @aDadImp[2], aTFrmOrf, lAuto)
		endif

		//Come�a a importa��o
		if !lAuto
			oRegua := MsNewProcess():New( { || PLSIMPSIM(cCaminho, aDadImp[2], lAuto, @oRegua,cVersao, aRetPerg[3]) } , STR0015 , STR0016 , .f. )//"Processando Configura��es e arquivos / Espere..."
			oRegua:Activate()
		else
			PLSIMPSIM(cCaminho, aDadImp[2], lAuto, @oRegua,aRetPerg[2], aRetPerg[3])
		endif
	else
		Help(nil, nil , STR0012, nil, STR0032, 1, 0, nil, nil, nil, nil, nil, {""} ) //"N�o existe arquivos com extens�o .txt ou csv na pasta indicada no Pergunte."
		lRet := .f.
	endif

endif

LimpaArray(aDadImp)
LimpaArray(aArqOrf)

return ( {lRet, aRetFun} )


//-------------------------------------------------------------------
/*/ {Protheus.doc} ChkRegImport
Executa a montagem din�mica das regras
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function ChkRegImport (aDadB6G, aTFrmOrf)
local aDadSep	:= {}
local aDadBusc	:= {}
local nFor 		:= 0
local nFor2		:= 0
local nFor3		:= 0
local cRet		:= ''
default aTFrmOrf:= {}

for nFor := 1 to len(aDadB6G)
	aDadSep := StrTokArr(aDadB6G[nFor,3], ";")
	for nFor2 := 1 to len(aDadSep)
		cRet := ''
		aDadBusc := StrTokArr(aDadSep[nFor2], "+")
		for nFor3 := 1 to len(aDadBusc)
			cRet += "'" + alltrim(aDadBusc[nFor3]) + "'" + " $ '" + cTxtTmp + "' .AND. "
		next
		cRet := SUBSTR(cRet, 1, Len(cRet) - 7)
		aadd(aDadB6G[nFor,5], cRet)
	next	 
next 

return 

//-------------------------------------------------------------------
/*/ {Protheus.doc} ExibeMensagem
Montagem das mensagens exibidas
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function ExibeMensagem(cTipo, cNome, cVersao, aDadosGer)
local cMensagem	:= ""

if cTipo == "1"
	cMensagem := STR0017 + cNome + STR0018 + cVersao + "). " + CRLF //" n�o possui a mesma vers�o Simpro informada no pergunte ("
	cMensagem += STR0019 + cVersao + STR0020 + CRLF //" Caso continue a importa��o, ser� gravada a vers�o" # " - na chave de refer�ncia, na tabela BD4."
	cMensagem += STR0021 //" Se tiver certeza que deseja importar, clique no bot�o Sim. Caso n�o, o arquivo ser� ignorado."
elseif cTipo == "2"
	cMensagem := STR0017 + cNome + STR0022 + alltrim(RetcBox("B6G_TIPPRO", aDadosGer[1])) +; //" possui as regras da configura��o: "
				 STR0023 + alltrim(aDadosGer[3]) + STR0024 + aDadosGer[6,1] //"Regra(s): " / ", mas a presente regra j� possui arquivo herdado, de nome"
endif
return cMensagem



//-------------------------------------------------------------------
/*/ {Protheus.doc} ExecRegImp
Executa segunda parte da checagem dos nomes nos arquivos encontrados no diret�rio
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function ExecRegImp(cNomeArq, aDadPesq, aArqOrf)	
local nFor 		:= 0
local nFor2		:= 0
local lRet 		:= .f.

for nFor := 1 to len(aDadPesq)
	for nFor2 := 1 to len(aDadPesq[nFor,5])
		if ( &( strtran(aDadPesq[nFor, 5, nFor2], cTxtTmp, cNomeArq) ) )
			if (empty(aDadPesq[nFor,6]))
				aadd(aDadPesq[nFor,6], cNomeArq)
				lRet := .t.
				exit
			else
				OprLogSist("0", ExibeMensagem("2", cNomeArq, '', aDadPesq[nFor]))	
			endif	
		endif	
	next
next

if !lRet
	aadd(aArqOrf, {cNomeArq,''})
endif

return 


//-------------------------------------------------------------------
/*/ {Protheus.doc} Telaorfaos
Tela para definir arquivo vs configura��o Simpro
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function TelaOrfaos (aArqOrf, aDadImp, aTFrmOrf, lAuto)
local aArquivos := aclone(aArqOrf)
local oPanelOrf	:= nil
local btnOK		:= { ||oPanelOrf:End(), nOpca := 1  }
local bCanc		:= { ||oPanelOrf:End()}  
local nFor 		:= 0   
local nPos		:= 0
local nOpca     := 0
local lRetExb	:= .t.
local oGrdOrf	:= nil   
default lAuto	:= .f.      

//Criar a op��o em branco
aadd(aTFrmOrf,'')
for nFor := 1 to len(aDadImp)
	if ( empty(aDadImp[nFor,6]) )
		aadd(aTFrmOrf, cValtochar(nFor) + "=" + alltrim(RetcBox("B6G_TIPPRO",aDadImp[nFor,1])) + " e " + alltrim(RetcBox("B6G_TIPO",aDadImp[nFor,2])) +;
	         STR0025 + alltrim( strtran(aDadImp[nFor,3], ";", " | " ) ) ) // - Regra Imp: 
	endif
next

if len(aTFrmOrf) <= 1
	lRetExb := .f.
endif 

if lRetExb
	if !lAuto
		DEFINE MSDIALOG oPanelOrf TITLE STR0026 FROM 0,0 TO 300,700 PIXEL //"Arquivos sem correspond�ncia"
	endif
	oGrdOrf := fwBrowse():New()
	oGrdOrf:setDataArray()
	oGrdOrf:setArray( aArquivos )
	oGrdOrf:disableConfig()
	oGrdOrf:disableReport()
	oGrdOrf:setOwner( oPanelOrf )
	oGrdOrf:SetDescription(STR0026) //"Arquivos sem correspond�ncia"

	oGrdOrf:addColumn({STR0027, {||aArquivos[oGrdOrf:nAt,1]}, "C", "@!", 1, 30, 0 , .f. , , .F., , "CARQ", , .F., .T., , "CARQ" }) //"Nome Arquivo"
	oGrdOrf:addColumn({STR0028, {||aArquivos[oGrdOrf:nAt,2]}, "C", "@!", 1, 1, 0, .t. , , .F., , "CCONFIG" , , .F., .T., aTFrmOrf, "CCONFIG" }) //"Configura��o Simpro"

	oGrdOrf:setEditCell( .T., {|| AjustaDados(aArquivos, @oGrdOrf)} )
	oGrdOrf:aColumns[2]:setEdit(.t.)
	oGrdOrf:aColumns[2]:SetReadVar("CCONFIG")

	oGrdOrf:setInsert( .F. )

	if !lAuto
		oGrdOrf:activate()
	
		ACTIVATE MSDIALOG oPanelOrf CENTERED ON INIT Eval({ || EnChoiceBar(oPanelOrf,btnOK,bCanc,.F.) })
	endif
	
	if nOpca == 1
		for nFor := 1 to len(aArquivos)
			if ( empty(aArquivos[nFor,2]) )
				OprLogSist("1", STR0029 + aArquivos[nFor,1] + STR0030) //"Arquivo: " / " n�o foi dado 'match' manual"
			else 
				nPos := val(aArquivos[nFor,2])
				if ( empty(aDadImp[nPos,6]) )
					aadd(aDadImp[nPos,6], aArquivos[nFor,1])
				else
					OprLogSist("1", STR0029 + aArquivos[nFor,1] + STR0031) //"Arquivo: " / " n�o ser� processado, por j� existir arquivo atr�buido."
				endif
			endif  
		next
	endif
endif
return .t.


//----------------------------------------------------------------
/*/ {Protheus.doc} AjustaDados
Ajusta dados do array, ap�s edi��o pelo usu�rio
@since 04/2020
@version P12 
/*/
//----------------------------------------------------------------
static function AjustaDados(aArray, oGrdOrf)
local lRet	:= .t.

if upper(Readvar()) == "CCONFIG"
    aArray[oGrdOrf:nAt,2] := &(Readvar())
endif

return lRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} PlObjFwBrow
Faz a montagem b�sica e inicial de um FwmBrowse ou FwBrowse, para evitar repetir o c�digo diversas vezes.
cTipBrowse -> "1" Se FWMBROWSE, "2" se FwBrowse
oObjMont -> Objeto onde deve ser criado a dialog / cAlias -> Alias do Browse (quando aplic�vel)
cFiltro -> Filtro do browser, se houver (se sim, usa direto o SetUseFilter) / cOwner -> Dono do browse criado
cDescricao -> Descri��o do browse / cMenuDef -> MenuDef dos bot�es do grid / 
lEditCell -> Se FWBROWSE, indica se as c�lulas s�o edit�veis / lInsLine -> Se FWBROWSE, indica se pode inserir nova linha
lWalThru -> Ativa Walk-Thru browse / lSetAmb -> disponibiliza op��o Ambiente / lUseFilt -> Utiliza��o do filtro no Browse

1) Se for um FwMBrowse, o aDadFwMBrow deve estar preenchido, na seguitne ordem:
{cFiltro, cMenuDef, lWalThru, lSetAmb, lUseFilt, aCmpFields}

2) Se for um FwMBrowse, o aDadFWBrow deve estar preenchido, na seguitne ordem:
{lEditCell, lInsLine, aCabec, aDados}

@since 07/2021
@version P12. 
/*/
//-------------------------------------------------------------------
function PlMObjFwBrow(cTipBrowse, oObjMont, cAlias, cOwner, cDescricao, aDadFwMBrow, aDadFBrow )
local nFor          := 0
local lProcessa     := .t.
default lFWmBrowse 	:= .f.
default lEditCell	:= .f.
default lInsLine	:= .f.	
default lWalThru	:= .f.	
default lSetAmb 	:= .f. 	
default lUseFilt 	:= .f.

if cTipBrowse == "1" .and. empty(aDadFwMBrow)
    oObjMont    := "Informa��es erradas de montagem: Se FWMBROWSE, informe o 6� par�metro da Fun��o com o array no formato esperado."
    lProcessa   := .f.
elseif cTipBrowse == "2" .and. empty(aDadFBrow)
    oObjMont    := "Informa��es erradas de montagem: Se FWBROWSE, informe o 7� par�metro da Fun��o com o array no formato esperado."
    lProcessa   := .f.
elseif !cTipBrowse $ "1/2"
    oObjMont    := "Valor errado do par�metro"
endif

if lProcessa
    oObjMont := iif( cTipBrowse == "1", FWmBrowse():New(), FWBrowse():New() )
    oObjMont:setOwner(cOwner)
	oObjMont:DisableReport()
	
    iif( !empty(cAlias), oObjMont:setAlias(cAlias), "")

    if lFWmBrowse
        oObjMont:SetMenuDef(cMenuDef) 
        oObjMont:SetWalkthru(lWalThru)
        oObjMont:SetAmbiente(lSetAmb)
        oObjMont:SetUseFilter(lUseFilt)
        oObjMont:setFields(aCmpFields)
        if !empty(cFiltro)  
            oObjMont:setFilterDefault(cFiltro)
        endif
    else
        oObjMont:setEditCell(aDadFBrow[1])
        oObjMont:setInsert(aDadFBrow[2])
        if len(aDadFBrow[3]) > 0 .and. len(aDadFBrow[4]) > 0
            oObjMont:setDataArray()
            oObjMont:setArray(aDadFBrow[4])
            for nFor := 1 to len(aDadFBrow[3])
                oObjMont:addColumn(aDadFBrow[3, nFor])    
            next
        endif
    endif
endif
return oObjMont


//-------------------------------------------------------------------
/*/ {Protheus.doc} PlMObjFwDial
Faz a montagem b�sica e inicial de um FwDialogModal, para evitar repetir o c�digo diversas vezes
oObjDial -> Objeto onde deve ser criado a dialog / lEscurece -> se o fundo da modal deve escurecer /
aTamanho -> Indica o tamanho da modal (largura x altura) / cDescricao -> Descri��o do topo da Dialog
lFormBar -> Se habilita a FormBar / lFechESC -> Se a dialog pode ser fechada com o bot�o ESC
@since 07/2021
@version P12
/*/
//-------------------------------------------------------------------
function PlMObjFwDial(oObjDial, lEscurece, aTamanho, cDescricao, lFormBar, lFechESC, aSetArray)
default aSetArray := {}

oObjDial := FWDialogModal():New()
oObjDial:SetBackground(lEscurece)
oObjDial:SetTitle(cDescricao)
oObjDial:setSubTitle(STR0005)
oObjDial:SetFreeArea(aTamanho[1], aTamanho[2])
oObjDial:SetEscClose(lFechESC)
oObjDial:EnableFormBar(lFormBar)

oObjDial:CreateDialog()
oObjDial:addCloseButton()
oObjDial:addYesNoButton()

return oObjDial

//-------------------------------------------------------------------
/*/ {Protheus.doc} GrvLogPc
Fun��o que executa o processo de gravar em arquivo os erros/observa��es encontrados no processo de importa��o
e exclus�o das tabelas Bras�ndice, na pasta determinada pelo usu�rio.
@since 05/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function GrvLogPc(cCaminho, cNomeLog, cMensagem, cExtensao, lBaseCab, nTamCab)
local oFileGrv		:= nil
local nFor1			:= 0
local nFor2			:= 0
local cTexto		:= ""
default cNomeLog 	:= "Arquivo_LOG_"
default cMensagem	:= ""
default cExtensao 	:= ".log"
default lBaseCab	:= .t.
default aDados		:= ""
default nTamCab		:= 4

cNomeLog := cNomeLog + cExtensao
oFileGrv := FWFileWriter():New( cCaminho + cNomeLog, .t.)
oFileGrv:setBufferSize(16384)
oFileGrv:create()
if !empty(cMensagem)
	oFileGrv:write(cMensagem + CRLF)
endif

for nFor1 := 1 to len(aOperLog)
	cTexto := ""
	for nFor2 := 1 to nTamCab
		cTexto += alltrim(aOperLog[nFor1, nFor2]) + " - "
	next
	oFileGrv:write(cTexto + CRLF)
next
oFileGrv:close()

return 

//-------------------------------------------------------------------
/*/ {Protheus.doc} bOKaRetP
n�o deixa informar uma data futura no campo Data mensagem
@since 09/2021
@version P12 
/*/
//-------------------------------------------------------------------

Static Function bOKaRetP(aRetPerg)
local lret := .t. 
DEFAULT aRetPerg := {}

if  aRetPerg[3] > DATE()
	Help(nil, nil , STR0012, nil, STR0040, 1, 0, nil, nil, nil, nil, nil, {""} )
	lret := .f.
endif
	
Return lret
