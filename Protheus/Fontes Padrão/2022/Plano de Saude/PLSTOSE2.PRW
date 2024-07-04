#INCLUDE "plstose2.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH" 

/*/{Protheus.doc} PLStoSe2
Gera titulos a partir de um pagamento 

@author  Francisco Edcarlo
@version P11
@since   04/08/17
/*/
function PLStoSe2(aCampos,NoUtilizado,aImpostos,lVlrNeg,cCopCre,cOrigem,cCondPag,lUltCalc)
LOCAL aArea 	:= GetArea()
LOCAL cParcSE2 	:= GetMv("MV_1DUP")
LOCAL cCodSA2	:= ''
LOCAL cLojSA2	:= ''
LOCAL cCodSED	:= ''
LOCAL cDiaVen	:= ''
LOCAL cChaSE2	:= ''
local cCodRda	:= ''
local cLote		:= ''
local cOpeLote 	:= ''
LOCAL cStrTit1	:= ''
LOCAL cStrTit2	:= ''
LOCAL dVencto	:= ctod("")
LOCAL nx		:= 0
LOCAL i 		:= 0
LOCAL nRecTitOri:= 0
LOCAL nVlrSE2	:= 0
LOCAL nPosSA2	:= 0
LOCAL nPosSED	:= 0
LOCAL nVlrIns	:= 0
local nRecSE2	:= 0
LOCAL nPar		:= 0
LOCAL nDecre  	:= 0
LOCAL nTamParc 	:= TAMSX3("E2_PARCELA")[1]
LOCAL nOldVal 	:= 0
LOCAL nOldIrf	:= 0
LOCAL nOldIns	:= 0
LOCAL nOldPis	:= 0
LOCAL nOldCof	:= 0
LOCAL nOldCsl	:= 0
LOCAL nVez		:= 0
LOCAL nRndPrec	:= GetNewPar( "MV_RNDPREC", 2 )
LOCAL lRndISS	:= GetNewPar( "MV_RNDISS", .T. )
LOCAL lRndINS	:= GetNewPar( "MV_RNDINS", .T. )
LOCAL lRndCSL	:= GetNewPar( "MV_RNDCSL", .T. )
LOCAL lRndPIS	:= GetNewPar( "MV_RNDPIS", .T. )
LOCAL lRndCOF	:= GetNewPar( "MV_RNDCOF", .T. )
LOCAL lRndIRF	:= ( GetNewPar( "MV_RNDIRF", .T. ) .AND. GetNewPar( "MV_RNDIRRF", .T. ) )
LOCAL lRetorno	:= .T.
LOCAL lCalIr	:= .T.
LOCAL lCalIss	:= .T.
LOCAL lCalPis	:= .T.
LOCAL lCalCof	:= .T.
LOCAL lCalCsl	:= .T.
Local aMvPars	:= {}
LOCAL aRetPtoEnt:= {}
LOCAL aParcelas := {}
LOCAL aParcTit 	:= {}
LOCAL aRecTitOri:= {}

Default cCopCre  := ""
Default cOrigem  := "PLSMPAG"
Default cCondPag := ""
Default lUltCalc := .F.

PRIVATE nIndexSE2  	:= ""
PRIVATE cModRetPIS 	:= GetNewPar( "MV_RT10925", "1" )
PRIVATE cIndexSE2  	:= ""
PRIVATE cChequeAdt 	:= " "
PRIVATE cHistDsd	:= CRIAVAR("E2_HIST",.F.)  // Historico p/ Desdobramento
PRIVATE nVlRetPis	:= 0
PRIVATE nVlRetCof  	:= 0
PRIVATE nVlRetCsl	:= 0
PRIVATE nMoeda     	:= 1
Private aDadosRef  	:= Array(7)
Private aDadosRet  	:= Array(7)
PRIVATE aDadosImp  	:= Array(3)
PRIVATE lAltValor  	:= .F.
PRIVATE lIntegracao	:= IF(GetMV("MV_EASY")=="S",.T.,.F.)
PRIVATE lF050Auto  	:= .f.
Private lMsHelpAuto	:= .f.
Private lMsErroAuto	:= .f.

aFill(aDadosRef,0)
aFill(aDadosRet,0)
aFill(aDadosImp,0) 

//Tipo 4 - Varios Pagamentos Mes com calculo Impostos - LA 20100619   
If GetNewPar("MV_PLPGUNI","1") == "4" .And. !lUltCalc 
	lUltCalc := .T.
Endif

If  valtype(aImpostos) == "A" .and. Len(aImpostos) >= 6
	nVlrIns := aImpostos[6]
Endif

aFill(aDadosRef,0)
aFill(aDadosRet,0)

//Carrega as variaveis de memoria
For nx := 1 TO Len( aCampos )
	Do Case
		Case aCampos[nx][1] == "E2_FORNECE" 
			cCodSA2 := aCampos[nx][2]
		Case aCampos[nx][1] == "E2_LOJA"
			cLojSA2 := aCampos[nx][2]
		Case aCampos[nx][1] == "E2_NATUREZ"
			cCodSED := aCampos[nx][2]
		Case aCampos[nx][1] == "E2_PREFIXO"
			cPrefixo := aCampos[nx][2]
		Case aCampos[nx][1] == "E2_NUM"
			cNumero := aCampos[nx][2]
		Case aCampos[nx][1] == "E2_PARCELA"
			cParcela := aCampos[nx][2]
		Case aCampos[nx][1] == "E2_TIPO"
			cTipo := aCampos[nx][2]
		Case aCampos[nx][1] == "E2_PLLOTE"
			cLote := aCampos[nx][2]
		Case aCampos[nx][1] == "E2_PLOPELT"
			cOpeLote := aCampos[nx][2]
		Case aCampos[nx][1] == "E2_CODRDA"
			cCodRda := aCampos[nx][2]
	EndCase
Next nx

DbSelectArea("SA2")

SA2->(dbSetOrder(1))
SA2->(dbSeek(xFilial("SA2")+cCodSA2+cLojSA2))
nPosSA2 := SA2->(RecNo())
SED->(dbSetOrder(1))
SED->(dbSeek(xFilial("SED")+cCodSED))
nPosSED := SED->(RecNo())

//Chama ponto de entrada para usuario poder atualizar campos no SE2      
If  ExistBlock("PLSE2AGR")
	ExecBlock("PLSE2AGR",.F.,.F.)
	SA2->(dbGoTo(nPosSA2))
	SED->(dbGoTo(nPosSED))
Endif

//Calcula impostos                                                       
aGets   := {}
lAltera := .F.
lInclui := .T.

If ExistBlock("PLSE2BVL")
	aRetPtoEnt	:= ExecBlock("PLSE2BVL",.F.,.F.,{aCampos,BAU->BAU_CODIGO,{},aImpostos,lVlrNeg})
	aCampos 	:= aRetPtoEnt[1]
	If Len(aRetPtoEnt) >= 3
		aImpostos := aRetPtoEnt[3]
	EndIf
	SA2->(dbGoTo(nPosSA2))
	SED->(dbGoTo(nPosSED))
Endif

//Atualiza SE2 com impostos calculados                                   
//Grava SE2 - Contas a Pagar                                             
//Inicializa variaveis de memoria                                        
If !Empty(cCondPag)
	
	SE4->(DbSetOrder(1))
	
	If SE4->(MsSeek(xFilial('SE4')+cCondPag))
		
		If (nPos := ascan(acampos,{|x| x[1]="E2_VALOR"})) > 0
			nVlrSe2 := aCampos[nPos,2]
		EndIf
		
		If (nPos := ascan(acampos,{|x| x[1]="E2_VENCTO"})) > 0
			dVencto := aCampos[nPos,2]
		EndIf
		
		aParcelas := Condicao (nVlrSe2, cCondPag,,dVencto)
		
	Else
		
		MsgAlert(STR0001) //"Não Encontrada Condição de pagamento!!"
		Return
		
	EndIf
	
	If Len(aParcelas) > 0
		
		cParcSE2 := Right("000"+cParcSE2,nTamParc)
		
		For i := 1 to Len(aParcelas)
			
			If (nPos := ascan(acampos,{|x| x[1]="E2_VENCTO"})) > 0
				aCampos[nPos,2] := aParcelas[i,1]
			EndIf
			
			If (nPos := ascan(acampos,{|x| x[1]="E2_VALOR"})) > 0
				aCampos[nPos,2] := aParcelas[i,2]
			EndIf
			
			If (nPos := ascan(acampos,{|x| x[1]="E2_PARCELA"})) > 0
				aCampos[nPos,2] := cParcSE2
			EndIf
			
			If (nPos := ascan(acampos,{|x| x[1]="E2_DESDOBR"})) > 0
				aCampos[nPos,2] := "S"
			Else
				AADD(aCampos,{"E2_DESDOBR","S",NIL})
			EndIf
			
			If (nPos := ascan(acampos,{|x| x[1]="E2_VENCORI"})) > 0
				aCampos[nPos,2] := aParcelas[i,1]
			EndIf
			
			If (nPos := ascan(acampos,{|x| x[1]="E2_SALDO"})) > 0
				aCampos[nPos,2] := aParcelas[i,2]
			EndIF
			
			If (nPos := ascan(acampos,{|x| x[1]="E2_VENCREA"})) > 0
				aCampos[nPos,2] := DataValida(aParcelas[i,1],.T.)
			EndIF
			
			If (nPos := ascan(acampos,{|x| x[1]="E2_VLCRUZ"})) > 0
				aCampos[nPos,2] := aParcelas[i,2]
			EndIF

			MsExecAuto({ | a,b,c | Fina050(a,b,c) }, aCampos,3, 3)
			 			
			cParcSE2 := Soma1(cParcSE2,nTamParc,.T.)
		Next
	EndIf

Else

    if (nPos := ascan(acampos,{|x| x[1]="E2_FLUXO"})) > 0
   	  if aCampos[nPos,2] == nil
   	     aCampos[nPos,2] := "S"
   	  endif   
   	  if aCampos[nPos,3] == nil
   	     aCampos[nPos,3] := "S"
   	  endif   
    endIf

    If (nPos := ascan(acampos,{|x| x[1]="E2_DESDOBR"})) > 0
   	  If aCampos[nPos,2] == nil
   	     aCampos[nPos,2] := "S"
   	  Endif   
   	  If aCampos[nPos,3] == nil
   	     aCampos[nPos,3] := "S"
   	  Endif   
    EndIf

  	MsExecAuto({ | a,b,c | Fina050(a,b,c) }, aCampos,3, 3)
	
	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
		lRetorno := .F.
	Else
		cPrefixo	:= SE2->E2_PREFIXO
		cNumero	    := SE2->E2_NUM
		cParcela	:= SE2->E2_PARCELA
		cTipo		:= SE2->E2_TIPO
		lRetorno 	:= .T.	
	Endif
EndIf

//Salva posicao SE2                                                      

aRecTitOri	:= SE2->(GetArea())
	
If lRetorno
	
    nRecSE2 := SE2->(recno())

	while !SE2->(eof()) .and. SE2->(E2_PREFIXO+E2_NUM) == cPrefixo+cNumero
		
        SE2->(reclock("SE2",.F.))
		
        	SE2->E2_PLLOTE	:= cLote
			SE2->E2_PLOPELT := cOpeLote
			SE2->E2_CODRDA	:= cCodRda
            
            if empty(SE2->E2_TITPAI)
                SE2->E2_ORIGEM := cOrigem
            endIf

		SE2->(msUnLock())	

	SE2->(dbSkip())
	endDo 

	SE2->(dbGoto(nRecSE2))
	
	//Salva posicao SE2 - se criou novo titulo, regrava posicao              
	aRecTitOri	:= SE2->(GetArea())
	
	//Chama ponto de entrada para usuario poder atualizar campos no SE2      
	If ExistBlock("PLSE2GRV")
		ExecBlock("PLSE2GRV",.F.,.F.)
	EndIf
	
	//Restaura posicao do SE2                                                
	
	SE2->(RestArea(aRecTitOri))	
	
	//Recalcula vencimento do inss caso tenha recebido valor de inss ja      
	//calculado e tenha recebido o tipo de prestador                         
	//Cooperado PF - dia 15 do mes seguinte                                  
	//Demais PF    - dia 02 do mes seguinte                                  
	
	If !Empty(cCopCre) .and. nVlrIns > 0 .And. !GetNewPar("MV_MP447",.F.)
		If  cCopCre == "1" // Cooperado
			If  val(substr(dtos(SE2->E2_EMISSAO),7,2)) > 15
				dVencto := lastday(SE2->E2_EMISSAO) + 15
			Else
				dVencto := lastday(SE2->E2_EMISSAO - 16) + 15
			Endif
		Else
			dVencto := lastday(SE2->E2_EMISSAO) + 2
		Endif
		SE2->(dbSetOrder(1))
		
		cChaSE2 := cPrefixo+cNumero+cParcela+"INS"+GetMV("MV_FORINSS")
		
		If SE2->(dbSeek(xFilial("SE2")+cChaSE2,.F.))
		
			SE2->(RecLock("SE2",.F.))
				SE2->E2_VENCTO  := dVencto
				SE2->E2_VENCREA := DataValida(dVencto)
			SE2->(msUnLock())
				
		Endif
	Endif
	
    SE2->(RestArea(aRecTitOri))
EndIf

RestArea(aArea)

Return(lRetorno)


/*/{Protheus.doc} PLTITBXCR
Baixa titulo NDF via compensação
@author  Oscar Zanin
@version P12
@since   02/10/2019
/*/
function PLNDF103(nRecSE2)
local cSql	  	:= ""
local __lOracle := .f.
local aRecNDF 	:= {}
local aParam  	:= { .f., .f., .f., .f., .f., .f. }
Local ctipoCmp := GetNewPar("MV_PLTPCP", "1")
Local lfinDireto := .F.

If ctipoCmp <> "3"

	getTpDB(@__lOracle)

	SE2->(dbGoto(nRecSE2))
	lfinDireto := !(empty(SE2->E2_PLLOTE)) //só os SE2 gerados com o CALIMP 2 marcam esse campo.

	cSql := " SELECT SE2.R_E_C_N_O_ SE2REC "
	cSql += "   FROM " + retSqlName("SE2") + " SE2 "
	cSql += "  WHERE SE2.E2_FILIAL  = '" + xFilial('SE2')  + "' " 
	cSql += "    AND SE2.E2_FORNECE = '" + SE2->E2_FORNECE + "' "
	cSql += "    AND SE2.E2_LOJA 	= '" + SE2->E2_LOJA    + "' "
	cSql += "    AND SE2.E2_TIPO 	= 'NDF' "

	If lfinDireto .AND. ctipoCmp == "2"
		cSql += " AND SE2.E2_PLLOTE = '" + SE2->E2_PLLOTE + "' "
	endIf

	if __lOracle
		cSql += " AND SE2.E2_ANOBASE || SE2.E2_MESBASE <= '" + SE2->(E2_ANOBASE+E2_MESBASE) + "' "
	else
		cSql += " AND SE2.E2_ANOBASE + SE2.E2_MESBASE <= '" + SE2->(E2_ANOBASE+E2_MESBASE) + "' "
	endIf	

	cSql += "    AND SE2.E2_SALDO   > 0 "
	cSql += "    AND SE2.D_E_L_E_T_ = ' ' "

	dbUseArea( .t., "TOPCONN", TCGENQRY(,, cSql ), "TRBSE2", .f., .t. )

	while ! TRBSE2->(eof())

		aadd(aRecNDF, TRBSE2->SE2REC)

	TRBSE2->(dbSkip())
	endDo

	TRBSE2->(dbClosearea())

	if len(aRecNDF) > 0

		MaIntBxCP(2,{nRecSE2},,aRecNDF,,aParam,,,,/*SE2->E2_VALOR*/)

	endIf
endIf

return
