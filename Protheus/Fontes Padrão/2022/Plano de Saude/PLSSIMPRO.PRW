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
Tela inicial de Importações da Simpro
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
oBrowse:SetDescription(STR0001)  //Importações Tabela Simpro®
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
Definição do modelo de Dados.
@since 04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel := FWLoadModel("PLSBRASIN1")
Return oModel

//removido, não há interface desse fonte.

//-------------------------------------------------------------------
/*/ {Protheus.doc} PergIniImport
Pergunte inicial da importação da Simpro
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

aadd(aPergs,{ 6, STR0006 , Space(100) , "@!","","",80,.t., STR0011 + " |*.*",,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ), .t.}) //Diretório dos arquivos?
aadd(aPergs,{ 1, STR0007 , Space(6)   , "@!",'.T.',,nil,40,.t. } )  //"Código da mensagem"
aadd(aPergs,{ 1, STR0008 , dDatabase  , "99/99/9999",'.T.',,'.t.',60,.t. } ) //"Data da mensagem"

if lAuto
	aRetPerg := aDadAuto     
elseIf !paramBox( aPergs,STR0034,aRetPerg,{|| bOKaRetP(aRetPerg)},,.t.,,,,'PLSIMPRO',.t.,.t. ) //"Importação Simpro -
	lExecuta := .f.
endIf


if lExecuta
    ImpTabSimpro(aRetPerg, lAuto) //Rotina de importação da Simpro
	
	if ( len(aOperLog) > 0 .and. !lAuto)

		aAdd(aCabec, {'Data',        {|| aOperLog[oBrowse:nAt,1] }, "C", "@!", 1, 007, 0, .f. , , .F., , "DATA" , , .F., .T., , "DATA"  }) //data
		aAdd(aCabec, {'Tipo Erro',   {|| aOperLog[oBrowse:nAt,2] }, "C", "@!", 1, 001, 0, .f. , , .F., , "ERRO" , , .F., .T., , "ERRO"  }) //"Descrição"
		aAdd(aCabec, {'Erro',        {|| aOperLog[oBrowse:nAt,3] }, "C", "@!", 1, 400, 0, .f. , , .F., , "CERRO", , .F., .T., , "CERRO" }) //"Lote Gerado?"
		aAdd(aCabec, {'Usuário',     {|| aOperLog[oBrowse:nAt,4] }, "C", "@!", 1, 010, 0, .f. , , .F., , "USUAR", , .F., .T., , "USUAR" }) //"Descrição"

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
			cMensLog := STR0038 + cDataLog + STR0039 + cOperad + CRLF //"Importação realizada no dia: /, pelo usuário: "
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
Armazenar no array aOperLog informações do sistema
Deve ter a seguinte estrutura: Data / Nível Log* / Informação / Usuário
*Nível Log: 0=Arquivo duplicado regras / 1=Info Arquivos Orfãos / 2=Erro Importação /
3=Registro não importado
@since 04/2020
@version P12 
/*/
//----------------------------------------------------------------
static function OprLogSist(cNivLog, cMsgErro)
aadd(aOperLog, {cDataLog, cNivLog, cMsgErro, cOperad})
return 


//-------------------------------------------------------------------
/*/ {Protheus.doc} LimpaArray
Função para limpar arrays
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
Rotina de Importação dos arquivos Simpro
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

/*ATENÇÃO 
O array aDadImp contêm as informações da tabela B6G de configuração, bem como irá armazenar as regras de importação e os arquivos
que deram 'match' com as regras. Abaixo, a estrutura desse array, usado em todas as operações:
aDadImp = {lRet, aDadRet}, onde: 
	1ª) lRet é o retorno lógico, usado na rotina SIMPRO
	2ª) aDadRet, contêm o array com os dados para a rotina de importação.
	* aDadRet = {B6G_TIPPRO, B6G_TIPO, B6G_REGIMP, REC, {}, {}}
		1ª) B6G_TIPPRO - Tipo do Item: ""1=Materiais/2=Medicamentos/4=Perfumaria/5=Saneantes/6=Reagentes""
		2ª) B6G_TIPO - Tipo de Preço: 1=PMC;2=PFB;3=PUSU
		3ª) B6G_REGIMP - Regras de Importação, para validação do nome do arquivo
		4ª) REC - RECNO da regra de importação da B6G
		5ª) Array preenchido na função ChkRegImport, que gera array com o desmembramento das regras de importação: {MATERIAL, PMC}, {MATERIAIS, PMC}
		6ª) Array que armazena os arquivos que deram match com a regra, ou seja, válidos.
*/
if empty(aDadImp[2])
	Help(nil, nil , STR0012, nil, STR0013, 1, 0, nil, nil, nil, nil, nil, {STR0014} ) //Não Existe Configuração de importação de Arquivos da Simpro válidos para a Operadora
	lContinua := .f.
else
	//Preenche a partir da 5ª posição do array de configuração com as strings de pesquisa
	ChkRegImport(@aDadImp[2])
endif

if lContinua

	aArquivos := directory(cCaminho+cExtArq)
	
	if len(aArquivos) > 0
		//Só aceito CSV e XML os demais serão ignorados
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

		//Exibir janela de Desambiguação de Arquivos X Cadastros, pois temos arquivos orfãos :-(
		if len(aArqOrf) > 0  
			Telaorfaos(aArqOrf, @aDadImp[2], aTFrmOrf, lAuto)
		endif

		//Começa a importação
		if !lAuto
			oRegua := MsNewProcess():New( { || PLSIMPSIM(cCaminho, aDadImp[2], lAuto, @oRegua,cVersao, aRetPerg[3]) } , STR0015 , STR0016 , .f. )//"Processando Configurações e arquivos / Espere..."
			oRegua:Activate()
		else
			PLSIMPSIM(cCaminho, aDadImp[2], lAuto, @oRegua,aRetPerg[2], aRetPerg[3])
		endif
	else
		Help(nil, nil , STR0012, nil, STR0032, 1, 0, nil, nil, nil, nil, nil, {""} ) //"Não existe arquivos com extensão .txt ou csv na pasta indicada no Pergunte."
		lRet := .f.
	endif

endif

LimpaArray(aDadImp)
LimpaArray(aArqOrf)

return ( {lRet, aRetFun} )


//-------------------------------------------------------------------
/*/ {Protheus.doc} ChkRegImport
Executa a montagem dinâmica das regras
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
	cMensagem := STR0017 + cNome + STR0018 + cVersao + "). " + CRLF //" não possui a mesma versão Simpro informada no pergunte ("
	cMensagem += STR0019 + cVersao + STR0020 + CRLF //" Caso continue a importação, será gravada a versão" # " - na chave de referência, na tabela BD4."
	cMensagem += STR0021 //" Se tiver certeza que deseja importar, clique no botão Sim. Caso não, o arquivo será ignorado."
elseif cTipo == "2"
	cMensagem := STR0017 + cNome + STR0022 + alltrim(RetcBox("B6G_TIPPRO", aDadosGer[1])) +; //" possui as regras da configuração: "
				 STR0023 + alltrim(aDadosGer[3]) + STR0024 + aDadosGer[6,1] //"Regra(s): " / ", mas a presente regra já possui arquivo herdado, de nome"
endif
return cMensagem



//-------------------------------------------------------------------
/*/ {Protheus.doc} ExecRegImp
Executa segunda parte da checagem dos nomes nos arquivos encontrados no diretório
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
Tela para definir arquivo vs configuração Simpro
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

//Criar a opção em branco
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
		DEFINE MSDIALOG oPanelOrf TITLE STR0026 FROM 0,0 TO 300,700 PIXEL //"Arquivos sem correspondência"
	endif
	oGrdOrf := fwBrowse():New()
	oGrdOrf:setDataArray()
	oGrdOrf:setArray( aArquivos )
	oGrdOrf:disableConfig()
	oGrdOrf:disableReport()
	oGrdOrf:setOwner( oPanelOrf )
	oGrdOrf:SetDescription(STR0026) //"Arquivos sem correspondência"

	oGrdOrf:addColumn({STR0027, {||aArquivos[oGrdOrf:nAt,1]}, "C", "@!", 1, 30, 0 , .f. , , .F., , "CARQ", , .F., .T., , "CARQ" }) //"Nome Arquivo"
	oGrdOrf:addColumn({STR0028, {||aArquivos[oGrdOrf:nAt,2]}, "C", "@!", 1, 1, 0, .t. , , .F., , "CCONFIG" , , .F., .T., aTFrmOrf, "CCONFIG" }) //"Configuração Simpro"

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
				OprLogSist("1", STR0029 + aArquivos[nFor,1] + STR0030) //"Arquivo: " / " não foi dado 'match' manual"
			else 
				nPos := val(aArquivos[nFor,2])
				if ( empty(aDadImp[nPos,6]) )
					aadd(aDadImp[nPos,6], aArquivos[nFor,1])
				else
					OprLogSist("1", STR0029 + aArquivos[nFor,1] + STR0031) //"Arquivo: " / " não será processado, por já existir arquivo atríbuido."
				endif
			endif  
		next
	endif
endif
return .t.


//----------------------------------------------------------------
/*/ {Protheus.doc} AjustaDados
Ajusta dados do array, após edição pelo usuário
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
Faz a montagem básica e inicial de um FwmBrowse ou FwBrowse, para evitar repetir o código diversas vezes.
cTipBrowse -> "1" Se FWMBROWSE, "2" se FwBrowse
oObjMont -> Objeto onde deve ser criado a dialog / cAlias -> Alias do Browse (quando aplicável)
cFiltro -> Filtro do browser, se houver (se sim, usa direto o SetUseFilter) / cOwner -> Dono do browse criado
cDescricao -> Descrição do browse / cMenuDef -> MenuDef dos botões do grid / 
lEditCell -> Se FWBROWSE, indica se as células são editáveis / lInsLine -> Se FWBROWSE, indica se pode inserir nova linha
lWalThru -> Ativa Walk-Thru browse / lSetAmb -> disponibiliza opção Ambiente / lUseFilt -> Utilização do filtro no Browse

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
    oObjMont    := "Informações erradas de montagem: Se FWMBROWSE, informe o 6º parâmetro da Função com o array no formato esperado."
    lProcessa   := .f.
elseif cTipBrowse == "2" .and. empty(aDadFBrow)
    oObjMont    := "Informações erradas de montagem: Se FWBROWSE, informe o 7º parâmetro da Função com o array no formato esperado."
    lProcessa   := .f.
elseif !cTipBrowse $ "1/2"
    oObjMont    := "Valor errado do parâmetro"
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
Faz a montagem básica e inicial de um FwDialogModal, para evitar repetir o código diversas vezes
oObjDial -> Objeto onde deve ser criado a dialog / lEscurece -> se o fundo da modal deve escurecer /
aTamanho -> Indica o tamanho da modal (largura x altura) / cDescricao -> Descrição do topo da Dialog
lFormBar -> Se habilita a FormBar / lFechESC -> Se a dialog pode ser fechada com o botão ESC
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
Função que executa o processo de gravar em arquivo os erros/observações encontrados no processo de importação
e exclusão das tabelas Brasíndice, na pasta determinada pelo usuário.
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
não deixa informar uma data futura no campo Data mensagem
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
