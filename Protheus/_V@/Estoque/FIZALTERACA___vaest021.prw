#include "protheus.ch"

#IFNDEF _ENTER_
	#DEFINE _ENTER_ (Chr(13)+Chr(10))
	// Alert("miguel")
#ENDIF 

//##########################################################################################
// Projeto: AVA1000002 - AVA- APONTAMENTOS CUSTO RACAO E ANIMAIS 
// Modulo : Estoque/Custos
// Fonte  : vaest021
//----------+------------------------------+------------------------------------------------
// Data     | Autor                        | Descricao
//----------+------------------------------+------------------------------------------------
// 20170310 | jrscatolon informatica       | Criação do apontamento de alimentação de lotes
//          |                              | 
//          |                              | 
//----------+-------------------------------------------------------------------------------

/*
 * CRIAR PARAMETROS
 * ----------------
 * Parametro:     VA_MOVTRAT
 * Tipo:          C
 * Descrição:     Parametro customizado usado pela rotina vaest004. Tipo de movimento (SF5) utilizado para apontamento automatizado de trato.
 *
 * Parametro:     VA_CCPRDTR
 * Tipo:          C
 * Descrição:     Parametro customizado usado pela rotina vaest004. Centro de custo utilizado para apontamento automatizado da Alimentação.
 *
 * Parametro:     VA_ICPRDTR
 * Tipo:          C
 * Descrição:     Parâmetro customizado usado pela rotina vaest004. Item contabil utilizado para apontamento automatizado da batida. 
 * 
 * Parametro:     VA_CLPRDTR()
 * Tipo:          C
 * Descrição:     Parâmetro customizado usado pela rotina vaest004. Classe de valor utilizado para apontamento automatizado da batida. 
 */
/*/{Protheus.doc} vesta021

Apontamento de alimentação de animais

@type function
@author JRScatolon Informatica

@param cIndividuo, Caractere, Código do produto do animal envolvido
@param cRacao, Caractere, Código do produto ração usado na alimentação
@param nQuant, Numérico, quantidade de ração usada na alimentação

@return numero da ordem de produção

@obs Caso seja criada a variável cNumOP como privada essa função irá preencher o numero da ordem de produção no momento de sua criação
@obs A função lançará uma excessão em caso de erro.
/*/

user function vaest021(cIndividuo, nQtdIndiv, aRacao /* cArmz, cRacao, cArmzRac , nQuant*/,  cLoteCTL )
local aArea 	    := GetArea()
local cMovTrat      := GetMV("VA_MOVTRAT")
local cCC 	 	    := GetMV("VA_CCPRDTR")
local cIC		    := GetMV("VA_ICPRDBA")
local cClvl		    := GetMV("VA_CLPRDBA")
Local lContinua     := .F.
Local lProssiga     := .T.
Local nI            := 0
Local cAlias        := "", _cQry  := ""
Local aCampos		:= {}, aDados := {}


private lMsErroAuto := .f.
private lMsHelpAuto := .t.
private lAutoErrNoFile := .t.

Default cArmz 		:= ""
Default cArmzRac 	:= ""
Default cLoteCTL	:= ""

If Type("__DATA") == "U"
	Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsDate(), dDataBase)
EndIf
If Type("cFile") == "U"
	Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".TXT"
EndIf

cIndividuo := PadR(cIndividuo, TamSX3("B1_COD")[1])
cRacao := PadR(cRacao, TamSX3("B1_COD")[1])	/* !!!!!!!!!!!!!!!!!!!! */

DbSelectArea("SC2")
DbSetorder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

DbSelectArea("SB1")
DbSetOrder(1) // B1_FILIAL+B1_COD

DbSelectArea("SB8")
DbSetOrder(1) // B8_FILIAL+B8_COD+B8_LOCAL

if SB1->(DbSeek(xFilial("SB1")+cIndividuo))

    if Empty(cArmz)
        cArmz := SB1->B1_LOCPAD
    endif
	
	SB8->(DbSetOrder(3)) // B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
    if SB8->(DbSeek(xFilial("SB8")+SB1->B1_COD+cArmz+cLoteCTL )) 
		While SB8->(B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL) == xFilial("SB8")+SB1->B1_COD+cArmz+cLoteCTL 
			If SB8->B8_SALDO > 0
				lContinua := .T.
				exit
			EndIf
			SB8->(DbSkip())
		EndDo
	EndIf
	
	If lContinua
        if Empty(nQtdIndiv)
            nQtdIndiv := SB8->B8_SALDO
        endif
		
		aEmpenho := {{{ cIndividuo, cArmz, nQtdIndiv, cLoteCTL},{} }}

		For nI := 1 to len(aRacao)
			if SB1->(DbSeek(xFilial("SB1")+aRacao[nI][1]))
				if Empty(aRacao[nI][3])
					aRacao[nI][3] := SB1->B1_LOCPAD
				endif

				if SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+aRacao[nI][3])) ;
					.and. ( aRacao[nI][2] <= SB2->B2_QATU .or. (aRacao[nI][2]-SB2->B2_QATU)<=GetMV("VA_DIFTRAT",,1) )

					// [nQuant > SB2->B2_QATU] Alt. MJ: 08.02.2018 : Tratar diferenca dos 0,0001 que acontecia e deixava o Ricardo Zampieri doido;
					// [ABS(nQuant-SB2->B2_QATU)<=GetMV("VA_DIFTRAT",,1)] Alt. MJ : 31.07.18 => Toshio Pediu para acertar estoque qdo diferenca pequena, tratada por parametro: VA_DIFTRAT				
					If aRacao[nI][2] > SB2->B2_QATU .or. ABS(aRacao[nI][2]-SB2->B2_QATU)<=GetMV("VA_DIFTRAT",,1)
						aRacao[nI][2] := SB2->B2_QATU
					EndIf
					
					aAdd(aEmpenho[1][2], { SB1->B1_COD, aRacao[ni][03], aRacao[nI][02], "" } )
				else
					lProssiga := .F.
					MsgStop("Não existe saldo suficiente para apontar a alimentação [" + AllTrim(aRacao[nI][1]) + "] do animal [" + AllTrim(cIndividuo) + "]." )
					exit
				EndIf
			else
            	MsgStop("Racao [" + AllTrim(cRacao) + "] não foi encontrada no cadastro de produtos." )
			endif
		next nI

		if lProssiga
			aDados  := {}
			aCampos := U_LoadCustomCpo("SB8")

			For nI := 1 to Len(aCampos)
				aAdd( aDados, { aCampos[nI], SB8->&(aCampos[nI]) } )
			Next nI

			U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
							cMsg := "[VAEST021] Cria OP: " + AllTrim(cIndividuo),;
							.T./* lConOut */,;
							/* lAlert */ )
			cNumOP := ""
			FWMsgRun(, {|| cNumOP := u_CriaOp(cIndividuo, nQtdIndiv, cArmz) },;
							"Processando [VAEST003]",;
							cMsg )
			ClearEmp(cNumOP)
			AjustEmp(cNumOP, aEmpenho)
			
			U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
						cMsg := "Processando [VAEST003]"+_ENTER_+"Apontamento OP: " + AllTrim(cNumOp),;
						.T./* lConOut */,;
						/* lAlert */ )
			FWMsgRun(, {|| u_ApontaOP(cNumOp, cMovTrat, cCC, cIC, cClvl, cLoteCTL, SB8->B8_X_CURRA ) },;
							"Processando [VAEST003]",;
							"Apontamento OP: " + AllTrim(cNumOp) )
			
			// MJ : 09.02.2018 : atualizar os campos customizados do NOVO registro SB8 gerado a partir do processamento do lote;
			_cQry := " SELECT MAX(R_E_C_N_O_) RECNO
			_cQry += " FROM "+ RetSqlName('SB8')
			_cQry += " WHERE B8_FILIAL ='"+xFilial("SB8")+"' 
			_cQry += " 	 AND B8_PRODUTO='"+cIndividuo+"'
			_cQry += " 	 AND B8_LOTECTL='"+cLoteCTL+"'
			_cQry += " 	 AND D_E_L_E_T_=' '
			
			cAlias        := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(_cQry)),(cAlias),.T.,.T.)
			If !(cAlias)->(Eof())
				SB8->(DbGoTo((cAlias)->RECNO))
				
				RecLock("SB8", .F.)
					For nI := 1 to Len(aDados)
						SB8->&(aDados[nI,1]) := aDados[nI, 2]
					Next nI
				SB8->(MsUnLock())
			EndIf
			(cAlias)->(DbCloseArea())
		endif 
    else
        MsgStop("O Animal [" + AllTrim(cIndividuo) + "] no lote [" + AllTrim(cLoteCTL) + "] não possui saldo em estoque no armazém [" + cArmz + "] para a filial [" + xFilial("SB8") + "]. Por favor verifique." )
    endif
	lContinua 	:= .F.
	
else
    MsgStop("O Animal [" + AllTrim(cIndividuo) + "] não cadastrado. Por favor verifique." )
endif
RestArea(aArea)
return cNumOp

/*
User function A250ETRAN()
	ConOut('Testando PE na rotina A250ETRAN')
Return nil

User function M250BUT()
	ConOut('.')
	ConOut('Testando PE na rotina M250BUT')
	ConOut('.')
Return nil

User Function MT250TOK()
	ConOut('.')
	ConOut('Testando PE na rotina MT250TOK')
	ConOut('.')
Return .T.
*/
/*/{Protheus.doc} LimpaEmp
    Atualiza os dados das tabelas de suporte e remove registro de empenho na tabela SD4.

@type function
@author JRScatolon Informatica 

@param cOP, Numero da Ordem de produção (sem item e sequencia)
@return nil

@obs A função lançará uma excessão em caso de erro.
/*/
Static Function ClearEmp(cOP)
local aArea := GetArea( )
local lRet := .t.
local lLocaliza := Localiza(SD4->D4_COD)

Local aCab   := {}
Local aItens := {}
lMsErroAuto := .F.

DbSelectArea("SD4")
DbSetOrder(2) // D4_FILIAL + D4_OP + D4_COD + D4_LOCAL

while SD4->(DbSeek(xFilial("SD4")+PadR(cOP+"01001", TamSX3("D4_OP")[1])))

	if Select("SD4") == 0
		MsgStop("A tabela SD4 não está aberta. Não existe registro posicionado para cancelar seu empenho.")
	elseif SD4->(Eof())
		MsgStop("A tabela SD4 está posicionada no fim de arquivo. Não existe registro posicionado para cancelar seu empenho.")
	endif

	DbSelectArea("SC2")
	DbSetOrder(1) // C2_FILIAL + C2_NUM + C2_ITEM + `C2_SEQUEN + C2_ITEMGRD

	if !SC2->(DbSeek(xFilial("SC2")+SD4->D4_OP))
		MsgStop("Não é possivel remover o empenho [" + AllTrim((SD4->(&(IndexKey())))) + "] pois a ordem de produção a que o empenho se refere não foi encontrada.")
	endif

	if !Empty(SC2->C2_DATRF)
		MsgStop("Não é possivel remover o empenho [" + AllTrim((SD4->(&(IndexKey())))) + "] pois a ordem de produção foi finalizada.")
	endif

	if (SD4->D4_QUANT < SD4->D4_QTDEORI)
		MsgStop("Não é possivel remover o empenho [" + AllTrim((SD4->(&(IndexKey())))) + "] pois ele foi parcialmente baixado.")
	endif

	if lLocaliza
		DbSelectArea("SDC")
		DbSetOrder(2) // DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
		
		SDC->(DbSeek(xFilial("SDC")+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOTECTL+SD4->D4_NUMLOTE))
		while xFilial("SDC")+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOTECTL+SD4->D4_NUMLOTE == DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE
			if SDC->DC_QUANT < SDC->DC_QTDORIG
				MsgStop("Não é possivel remover o empenho [" + AllTrim(&(SD4->(IndexKey()))) + "] pois ele foi parcialmente baixado.")
			endif
			SDC->(DbSkip())
		end

		//Monta o cabeçalho com a informação da Ordem de produção que terá os empenhos excluídos.
		aCab := {{"D4_OP",cOP,NIL},;
				{"INDEX",2,Nil}}
	
		//Executa o MATA381 para exclusão dos empenhos.
		MSExecAuto({|x,y,z| mata381(x,y,z)},aCab,aItens,5)
		If lMsErroAuto
			MostraErro()
		Else
			ConOut("Excluído com sucesso.")
		EndIf
	endif
 
end

if !Empty(aArea)
    RestArea( aArea )
endif
return lRet


/*/{Protheus.doc} AjustEmp 
    Cria registro de empenho na tabela SD4 e atualiza os dados das tabelas de suporte.
@type function
@author JRScatolon Informatica 

@param cOP, Caractere, Numero da ordem de produção
@param aEmpenho, Matriz, Matriz bidimensional no formato { {<Cod Produto>, <Armazem>, <Quantidade empenhada>} '[', {<Cod Produto>, <Local>, <Quantidade>}']' }
@return nil

@obs A função lançará uma excessão em caso de erro.
@obs O produto será empenhado mesmo não havendo saldo em estoque. A rotina de produção, através do parametro MV_ESTNEG será responsavel pelo tratamento das movimentações de estoque. 
/*/
static function AjustEmp(cOP, aEmpenho)
local aArea 	:= GetArea( )
local i, nLen 
local lRet 		:= .t.
Local aCab      := {}
local aEmp 		:= {}
Local aItens    := {}
Local nJ 
Local lGrava 	:= .t. 
Local nPEmpCod := 1
Local nPEmpLoc := 2
Local nPEmpQtd := 3
Local nPEmpCtl := 4

lMsErroAuto := .f.
lMsHelpAuto := .t.
lAutoErrNoFile := .t.

DbSelectArea("SC2")
DbSetOrder(1) // C2_FILIAL + C2_NUM + C2_ITEM + `C2_SEQUEN + C2_ITEMGRD

if SC2->(DbSeek(xFilial("SC2")+cOP+"01001"))

    DbSelectArea("SB1")
    DbSetOrder(1) // B1_FILIAL + B1_COD

    DbSelectArea("SD4")
    DbSetOrder(1) // D4_FILIAL + D4_OP + D4_COD + D4_LOCAL
    
    nLen := Len(aEmpenho)
    for i := 1 to nLen

		For nJ := 1 to Len(aEmpenho[i][2])
			if !SB1->(DbSeek(xFilial("SB1")+aEmpenho[i][2][nJ][nPEmpCod]))
				MsgStop("Produto [" + aEmpenho[i][nPEmpCod] + "] não encontrado. Não é possivel efetuar o empenho.")
				lGrava := .F.
				exit
			endif	

				aCab := {{"D4_OP",cOp,NIL}}
				aEmp := {}
				
				aAdd( aEmp, {"D4_FILIAL" , xFilial("SD4")		  		, nil} )
				aAdd( aEmp, {"D4_COD"    , aEmpenho[i][2][nJ][nPEmpCod]	, nil} )
				aAdd( aEmp, {"D4_LOCAL"  , aEmpenho[i][2][nJ][nPEmpLoc]	, nil} )
				aAdd( aEmp, {"D4_OP"     , cOP+"01001"		  			, nil} )
				aAdd( aEmp, {"D4_DATA"   , dDataBase		      		, nil} )
				aAdd( aEmp, {"D4_QTDEORI", aEmpenho[i][2][nJ][nPEmpQtd]	, nil} )
				aAdd( aEmp, {"D4_QUANT"  , aEmpenho[i][2][nJ][nPEmpQtd]	, nil} )
			
				if Len(aEmpenho[i][2]) > 3
					aAdd( aEmp, {"D4_LOTECTL", aEmpenho[i][2][nJ][nPEmpCtl], nil} )
					aAdd( aEmp, {"D4_DTVALID", Iif(Empty(aEmpenho[i][2][nJ][nPEmpCtl]),stoD(""),SB8->B8_DTVALID), nil} )
				EndIf

				aAdd(aItens, aEmp)
		next nJ
    next
		if lGrava
			MSExecAuto({|x,y,z| mata381(x,y,z)}, aCab, aItens, 3)
			If lMsErroAuto
				MostraErro()
			Else
				ConOut("Incluído com sucesso.")
			EndIf
		endif 
endif
if !Empty(aArea)
    RestArea( aArea )
endif
return lRet
