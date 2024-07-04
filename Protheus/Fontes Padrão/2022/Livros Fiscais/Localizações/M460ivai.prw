#include "SIGAWIN.CH"

//Constantes utilizadas nas localizacoes
#DEFINE _NOMEIMPOS 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _RATEODESP 13
#DEFINE _IVAGASTOS 14
#DEFINE _IVAFLETE  12
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  º   M460IVAI º Autor º     Lucas       º Data º   02/12/99  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                 Programa que calcula o IVA                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   º M100IVAI                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametrosº                                         			      º±±
±±º         1 º cCalculo                                                  º±±
±±º         2 º nItem                                                     º±±
±±º         3 º aInfo                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   º aImposto                                                  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       º MATA10x, LOJA010 e LOJA220, chamado pelo ponto de entrada º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º         Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramadorº Data   º BOPS º  Motivo da Alteracao                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºFernando M.º02/11/00ºxxxxxxº Tratamento para FEPP, que afeta base do   º±±
±±º           º        º      º IVA se for negativo (Loc. Chile)          º±±
±±º           º        º      º                                           º±±
±±ºFernando M.º26/03/01ºxxxxxxº Arredondamento de acordo com a moeda, va- º±±
±±º           º        º      º lidar o tipo de cliente para o SigaLoja   º±±
±±º           º        º      º                                           º±±
±±º Nava      º18/07/01º      º Reescrito pela funcao GetCountryList.     º±±
±±º           º        º      º                                           º±± 
±±º Julio     º21/10/02º      º Tratamento para impostos "dependentes".   º±±
±±º           º        º      º Verifica se existem impostos que mesmo    º±± 
±±º           º        º      º calculados separadamente tem que ter a    º±± 
±±º           º        º      º mesma base de calculo.                    º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460IVAI(cCalculo,nItem,aInfo)

LOCAL cFunct
LOCAL aRet
LOCAL lXFis
LOCAL aCountry // Array de Paises nesta forma : // { { "BRA" , "Brasil", "BR" } , { "ARG" , "Argentina","AR"} ,
LOCAL aArea 	:= GetArea()

lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
// .T. - metodo de calculo utilizando a matxfis
// .F. - metodo antigo de calculo

aCountry := GetCountryList()
cFunct	:= "M460IVAI" + aCountry[Ascan( aCountry, { |x| x[1] == cPaisLoc } )][3] // retorna pais com 2 letras
aRet	:= &( cFunct )(cCalculo,nItem,aInfo,lXFis)

RestArea( aArea )

RETURN aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³¦¦Funçào    ³M460IVAICH³ Autor ³ Gilson da Silva        ³ Data ³ 03/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³¦¦Descriçào ³ Programa que Calcula o IVA (Chile)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³¦¦Uso       ³ MATA468/mata467, chamado pela tes                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Fernando M.   ³28/06/01³xxxxxx³Adaptacao para o novo modo de calculo de   ³±±
±±³              ³        ³      ³impostos variaveis                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460IVAICH(cCalculo,nItem,aInfo,lXFis)

local aImp,aItem,cImp,xRet,nOrdSFC,nRegSFC,nImp
Local nBase:=0, nAliq:=0
Local nDecs
LOCAL nCols := 0
LOCAL nPosCod, nPosSbLote, nPosLote, nPosLoc
LOCAL cProd, cSbLote, cLote, cLocal, cSeekB8


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - SIGALOJA/SIGAFRT  - F1CHI    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lLocR5	:=	GetRpoRelease ("R5") .AND. ;
					SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
					cPaisLoc$"CHI" .AND. ;
					!lFiscal								
					
					
Local cSigEspFo := 	""	                            							//Sigla da especie de documebnto fiscal escolhida no inicio da venda
Local nRecnoFo	:= Iif (cModulo$"LOJA",LjGRecFo(),;
						Iif (cModulo$"FRT",FaGetRecFo(),;
						Iif (cModulo$"FAT",LjxRecnoFo(SL1->L1_SERIE),0))) 		//RECNO do lote/controle de formulario escolhido no inicio da venda
				

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                  ³
³                                                               ³
³ a variavel ParamIxb tem como conteudo um Array[2], contendo : ³
³ [1,1] > Quantidade Vendida                                    ³
³ [1,2] > Preco Unitario                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...             ³
³ [1,4] > Valor do Frete rateado para este Item ...             ³
³ [1,5] > Valor das Despesas rateado para este Item...          ³
³ [1,6] > Array Contendo os Impostos já calculados, no caso de  ³
³        incidência de outros impostos.                         ³
³ [2,1] > Array aImposto, Contendo as Informações do Imposto que³
³         será calculado.                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

lCalc1 := .F.
If !lXfis
	aItem  := ParamIxb[1]
	aImp   := ParamIxb[2]
	cImp   := aImp[1]
	nCols  := ParamIxb[3]
	xRet   := aImp
Else
	cImp   := aInfo[1]
	nCols  := nItem
	xRet   := 0
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - SIGALOJA/SIGAFRT  - F1CHI 	³
//³Isencao de impostos quando a escpecie 		³
//³formulario de venda for do tipo:             ³
//³FCX - FACTURA EXENTA                         ³
//³BLX - BOLETA EXENTA                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLocR5 .AND. nRecnoFo > 0	
	LjxDadosFo (nRecnoFo,NIL,@cSigEspFo)
EndIf

If cSigEspFo == "FCX" .OR. cSigEspFo == "BLX"
	lCalc1 := .F.
Else	
	//+---------------------------------------------------------------+
	//¦ Verificar o tipo do Fornecedor.                               ¦
	//+---------------------------------------------------------------+	
	If cModulo$"FAT|LOJA|FRT|TMK"
		dbSelectArea( "SA1" )
		If A1_TIPO <>"N"
			lCalc1 := .T.
		Endif
	Else
		dbSelectArea( "SA2" )
		If A2_TIPO <>"N"
			lCalc1 := .T.
		Endif
	Endif
EndIf

If lCalc1
	DbSelectArea("SFB")    // busca a aliquota padrao
	DbSetOrder(1)
	If Dbseek(xfilial()+cImp)
		nAliq:=SFB->FB_ALIQ
	Endif
	If !lXFis
		nBase:=aItem[3]+aItem[4]+aItem[5]  //valor total + frete + outros impostos
	Else
		nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		If GetNewPar('MV_DESCSAI','1')=='1' 
			nBase	+= MaFisRet(nItem,"IT_DESCONTO")
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Nao e uma chamada dos programas MATA415 e MATA416 - Presupuestos de Venta ³
	//³ Sergio Camurca                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If !(cModulo$"LOJA|FRT|TMK") .And. !(Upper(FunName()) $ "MATA415|MATA416|MATR700") .And. Type("aHeader")#"U"
		If (Upper(FunName())=="MATA410")
			nPosCod    := Ascan(aHeader,{|x|Trim(x[2])=="C6_PRODUTO"})
			cProd      := aCols[nCols][nPosCod]
			nPosLote   := Ascan(aHeader,{|x|Trim(x[2])=="C6_LOTECTL"})
			cLote      := aCols[nCols][nPosLote]
			nPosSbLote := Ascan(aHeader,{|x|Trim(x[2])=="C6_NUMLOTE"})
			cSbLote    := aCols[nCols][nPosSbLote]
			nPosLoc    := Ascan(aHeader,{|x|Trim(x[2])=="C6_LOCAL"})
			cLocal     := aCols[nCols][nPosLoc]		
		ElseIf (Upper(FunName())<>"MATA468N")
			nPosCod    := Ascan(aHeader,{|x|Trim(x[2])=="D2_COD"})
			cProd      := aCols[nCols][nPosCod]
			nPosLote   := Ascan(aHeader,{|x|Trim(x[2])=="D2_LOTECTL"})
			cLote      := aCols[nCols][nPosLote]
			nPosSbLote := Ascan(aHeader,{|x|Trim(x[2])=="D2_NUMLOTE"})
			cSbLote    := aCols[nCols][nPosSbLote]
			nPosLoc    := Ascan(aHeader,{|x|Trim(x[2])=="D2_LOCAL"})
			cLocal     := aCols[nCols][nPosLoc]
		Else
			If lPedidos
				cProd   := SC6->C6_PRODUTO
				cLocal  := SC6->C6_LOCAL
			Else
			    // Modificado para pegar direto do Arquivo temporario - Sergio Camurca
				cProd   := SCN->CN_PRODUTO
				If SCN->CN_TIPOREM $ "1"
					cLocal  := SCN->CN_LOCDEST
				Else
					cLocal  := SCN->CN_LOCAL
				EndIf
			EndIf
			cLote   := SC9->C9_LOTECTL
			cSbLote := SC9->C9_NUMLOTE
		EndIf
		If Rastro(cProd)
			//Se FEPP eh negativo,tira da base do IVA
			If !Empty(cSbLote)
				cSeekB8 := xfilial("SB8")+cProd+cLocal+cLote+cSbLote
			Else
				cSeekB8 := xfilial("SB8")+cProd+cLocal+cLote
			EndIf
			SB8->(dbSetorder(3))
			If SB8->(DbSeek(cSeekB8))
				If SB8->(FieldPos("B8_FEPP")) = 0 .Or. SB8->(FieldPos("B8_IE")) = 0 
          	 		MsgAlert("Los Campos IE y FEPP de la Tabla SB8 no fueron encontrados")
    			Else
			    	If !lXFis
				    	If SB8->B8_FEPP < 0
					    	nBase -= SB8->B8_IE * aItem[1]
					    Else
						    nBase -= ((SB8->B8_IE * aItem[1])+ (SB8->B8_FEPP * aItem[1]))
					    EndIf
					Else   
					    If SB8->B8_FEPP < 0
						    nBase -= SB8->B8_IE * MaFisRet(nItem,"IT_QUANT")
					    Else
						    nBase -= (SB8->B8_IE + SB8->B8_FEPP) * MaFisRet(nItem,"IT_QUANT")
					    EndIf
					Endif    
				Endif
			EndIf
		EndIf
	EndIf
	
	nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))
	
	If !lXFis
		aImp[02]:=nAliq
		aImp[03]:=nBase
		
		//Tira os descontos se for pelo liquido .Bruno
		If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
			aImp[3]	-=aImp[18]
			nBase	:=aImp[3]
		Endif
		
		//+---------------------------------------------------------------+
		//¦ Efetua o Calculo do Imposto                                   ¦
		//+---------------------------------------------------------------+
		aImp[4] := Round(aImp[3] - (aImp[3] /(1+(aImp[2]/100))),nDecs)
		aImp[03]:= aImp[03]- aImp[04]
		
		xRet:=aImp
	Else
		//Tira os descontos se for pelo liquido
		nOrdSFC:=(SFC->(IndexOrd()))
		nRegSFC:=(SFC->(Recno()))
		
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
			If SFC->FC_LIQUIDO=="S"
				nBase-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
			Endif
		Endif
		
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
		
		nImp:=nBase-(nBase /(1+(nAliq/100)))
		nBase-=nImp
		
		Do Case
			Case cCalculo=="B"
				xRet:=nBase
			Case cCalculo=="A"
				xRet:=nALiq
			Case cCalculo=="V"
				xRet:=nImp
		EndCase
	EndIf
Endif

Return( xRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³¦¦Funçào    ³M460IVAIME³ Autor ³ Fernando Machima       ³ Data ³ 09/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³¦¦Descriçào ³ Programa que Calcula o IVA Incluido (Mexico)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³¦¦Uso       ³ MATA468/MATA467/MATA466                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Fernando M.   ³09/05/01³xxxxxx³Desenvolvimento inicial                    ³±±
±±³Fernando M.   ³28/06/01³xxxxxx³Adaptacao para o novo modo de calculo de   ³±±
±±³              ³        ³      ³impostos variaveis                         ³±±
±±³              ³        ³      ³                                           ³±±
±±³ Julio        ³21/10/02³      ³ Tratamento para impostos "dependentes".   ³±±
±±³              ³        ³      ³ Verifica se existem impostos que mesmo    ³±± 
±±³              ³        ³      ³ calculados separadamente tem que ter a    ³±± 
±±³              ³        ³      ³ mesma base de calculo.                    ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460IVAIME(cCalculo,nItem,aInfo,lXFis)

Local aImp,aItem,cImp,xRet,nOrdSFC,nRegSFC,nImp,cTes
Local nBase:=0, nAliq:=0, lAliq:=.F., lIsento:=.F., cFil, cAux, cGrp
Local nDecs
Local nAliqAux:=0
Local lImpDep:=.F.,lCalcLiq:=.F.

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                  ³
³                                                               ³
³ a variavel ParamIxb tem como conteudo um Array[2], contendo : ³
³ [1,1] > Quantidade Vendida                                    ³
³ [1,2] > Preco Unitario                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...             ³
³ [1,4] > Valor do Frete rateado para este Item ...             ³
³ [1,5] > Valor das Despesas rateado para este Item...          ³
³ [1,6] > Array Contendo os Impostos já calculados, no caso de  ³
³        incidência de outros impostos.                         ³
³ [2,1] > Array aImposto, Contendo as Informações do Imposto que³
³         será calculado.                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
dbSelectArea("SFF")     // verificando as excecoes fiscais
dbSetOrder(3)

cFil:=xfilial()

If !lXfis
	aItem:=ParamIxb[1]
	aImp:=ParamIxb[2]
	cImp:=aImp[1]
	cTes:=SF4->F4_CODIGO
Else
	cImp:=aInfo[1]
    If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
       SBI->(DbSeek(xFilial("SBI")+MaFisRet(nItem,"IT_PRODUTO")))
    Else   
        SB1->(DbSeek(xFilial("SB1")+MaFisRet(nItem,"IT_PRODUTO")))
    Endif    
  	cTes:=MaFisRet(nItem,"IT_TES")
Endif            

If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
   cGrp:=Alltrim(SBI->BI_GRUPO)
Else
    cGrp:=Alltrim(SB1->B1_GRUPO)
Endif

If dbseek(cFil+cImp)
	While FF_IMPOSTO == cImp .and. FF_FILIAL == cFil .and. !lAliq
		cAux:=Alltrim(FF_GRUPO)
		If cAux!=""
			lAliq:=(cAux==cGrp)
		Endif
		cAux:=Alltrim(FF_ATIVIDA)
		If cAux!=""
			lAliq:=(cAux==Alltrim(SA1->A1_ATIVIDA))
		Endif
		If lAliq
			If !(lIsento:=(FF_TIPO=="S"))
				nAliq:=FF_ALIQ
			Endif
		Endif
		dbskip()
	Enddo
Endif

If !lIsento
	If !lAliq
		DbSelectArea("SFB")    // busca a aliquota padrao
		DbSetOrder(1)
		If Dbseek(xfilial()+cImp)
			nAliq:=SFB->FB_ALIQ
		Endif
	Endif
	If !lXFis
		nBase:=aItem[3]+aItem[4]+aItem[5]  //valor total + frete + outros impostos
	Else
		nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		If cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0
			nBase-=MaFisRet(nItem,"IT_ADIANT")
		EndIf		
		If GetNewPar('MV_DESCSAI','1')=='1' 
			nBase	+= MaFisRet(nItem,"IT_DESCONTO")
		Endif
	Endif
Endif

nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))

//Verifica se eh um imposto "dependente" de outro, pois caso seja eh necessario
//acertar o valor da base para que os impostos da amarracao possuam a mesma
//base de calculo.	
If cImp $ GetMV("MV_IMPSDEP",,"")
	nOrdSFC:=(SFC->(IndexOrd()))
	nRegSFC:=(SFC->(Recno()))
	SFC->(DbSetOrder(2))
	If (SFC->(DbSeek(xFilial("SFC")+cTes)))
		While !Eof() .And. (xFilial("SFC")+cTes == SFC->FC_FILIAL+SFC->FC_TES)
			If (SFC->FC_IMPOSTO <> cImp) .And. (SFC->FC_IMPOSTO $ GetMV("MV_IMPSDEP",,"")) .And.;
			   (SFC->FC_INCNOTA == "3") 
				lImpDep := .T.
   				dbSelectArea("SFB")    // busca a aliquota padrao
   				dbSetOrder(1)
				If dbSeek(xFilial("SFB")+SFC->FC_IMPOSTO)
					nAliqAux += SFB->FB_ALIQ
				Endif	   
			ElseIf (SFC->FC_IMPOSTO == cImp)
				lCalcLiq := .T.
				//Tira os descontos se for pelo liquido
				If !lXFis .And. Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
					nBase -= aImp[18]
				ElseIf lXFis .And. SFC->FC_LIQUIDO=="S"
					nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				EndIf
			EndIf
			SFC->(dbSkip())
		End
	EndIf
	SFC->(DbSetOrder(nOrdSFC))
	SFC->(DbGoto(nRegSFC))

	If lImpDep
		nAliqAux += nAliq
    	nBase    := Round(nBase /(1+(nAliqAux/100)),nDecs)		
  	EndIf
EndIf

If !lXFis
	aImp[02]:=nAliq
	aImp[03]:=nBase
		
	//Caso seja um imposto "dependente" o tratamento de desconto ja foi realizado.	
	If !lCalcLiq
		//Tira os descontos se for pelo liquido .Bruno
		If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
			aImp[3]	-= aImp[18]
			nBase	:= aImp[3]
		Endif
	EndIf
	
	//+---------------------------------------------------------------+
	//¦ Efetua o Calculo do Imposto                                   ¦
	//+---------------------------------------------------------------+
	If !lImpDep
		aImp[4]:= aImp[3] - Round(aImp[3] /(1+(aImp[2]/100)),nDecs)
		aImp[3]:= aImp[3] - aImp[4]
	Else
		aImp[4]:=Round(aImp[3] * (aImp[02]/100),nDecs)	
	EndIf
	
	xRet:=aImp
Else           
	//Caso seja um imposto "dependente" o tratamento de desconto ja foi realizado.	
	If !lCalcLiq
		nOrdSFC:=(SFC->(IndexOrd()))
		nRegSFC:=(SFC->(Recno()))

		//Tira os descontos se for pelo liquido
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+cTes+cImp)))
			If SFC->FC_LIQUIDO=="S"
				nBase-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
			Endif
		Endif
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
	EndIf
       
	//Caso seja um imposto "dependente" a forma de calculo eh diferente, nao sendo
	//feita pela diferenca...	                  
	If !lImpDep
		nImp:=nBase-Round(nBase /(1+(nAliq/100)),nDecs)
		nBase-=nImp
	Else
		nImp:=Round(nBase * (nAliq/100),nDecs)	
	EndIf
	
	Do Case
		Case cCalculo=="B"
			xRet:=nBase
		Case cCalculo=="A"
			xRet:=nALiq
		Case cCalculo=="V"
			xRet:=nImp
	EndCase
	
Endif

Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³¦¦Funçào    ³M460IVAIVE³ Autor ³ William Yong           ³ Data ³ 04/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³¦¦Descriçào ³ Programa que Calcula o IVA (Venezuela)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³¦¦Uso       ³ MATA468/mata467, chamado pela tes                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ William Yong ³04/06/01³xxxxxx³ Desenvolvimento inicial                   ³±±
±±³Fernando M.   ³28/06/01³xxxxxx³Adaptacao para o novo modo de calculo de   ³±±
±±³              ³        ³      ³impostos variaveis                         ³±±
±±³Tiago Bizan	 ³13/07/10³xxxxxx³Mudanças no calculo do imposto IVA 	     ³±±
±±³				 ³		  ³		 ³(Alíquota, Base de Calculo e Valor)        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460IVAIVE(cCalculo,nItem,aInfo,lXFis)

local aImp,aItem,cImp,xRet,nImp
Local nBase:=0, nAliq:=0
		
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                  ³
³                                                               ³
³ a variavel ParamIxb tem como conteudo um Array[2], contendo : ³
³ [1,1] > Quantidade Vendida                                    ³
³ [1,2] > Preco Unitario                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...             ³
³ [1,4] > Valor do Frete rateado para este Item ...             ³
³ [1,5] > Valor das Despesas rateado para este Item...          ³
³ [1,6] > Array Contendo os Impostos já calculados, no caso de  ³
³        incidência de outros impostos.                         ³
³ [2,1] > Array aImposto, Contendo as Informações do Imposto que³
³         será calculado.                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

If !lXfis
	aItem  := ParamIxb[1]
	aImp   := ParamIxb[2]
	cImp   := aImp[1]
	xRet   := aImp
Else
	cImp   := aInfo[1]
	xRet   := 0
Endif
	
	//BUSCA A ALÍQUOTA
	DbSelectArea("SFB")    
	DbSetOrder(1)	
	If SFB->(DbSeek(xfilial("SFB")+cImp))
		If SB1->B1_ALQIVA > 0	 
			nAliq:=SB1->B1_ALQIVA
		Else 
			If SF4->F4_CALCIVA == "4" .OR. SF4->F4_CALCIVA == "3"  
				nAliq:=0
			ElseIF SF4->F4_TPALIQ == "G" .OR. SF4->F4_TPALIQ == " "				 
				nAliq:=SFB->FB_ALIQ
			ElseIF SF4->F4_TPALIQ == "R"					
				nAliq:=SFB->FB_ALIQRD				
			ElseIF SF4->F4_TPALIQ == "A"
				nAliq:=SFB->FB_ALIQAD
			EndIF
    	EndIF
	Endif	
	
	//BUSCA A BASE DE CALCULO
	If !lXFis
	    If SF4->F4_CALCIVA == "3"
			nBase := 0
		Else
			nBase:=aItem[3]
		EndIF
	Else
		If SF4->F4_CALCIVA == "3"
			nBase := 0
		Else
			nBase:=MaFisRet(nItem,"IT_VALMERC")
		EndIF
	Endif
		
	//CALCULO DO IMPOSTO
	If !lXFis
		If SF4->F4_CALCIVA == "3"
			aImp[03] := 0
		Else
			aImp[02]:=nAliq
			aImp[03]:=nBase 
		EndIF
		If SF4->F4_CALCIVA == "4"		
			aImp[4] := aImp[3] - Round(aImp[3] /(1+(aImp[2]/100)),2)
		Else 
			aImp[4] := aImp[3] - Round(aImp[3] /(1+(aImp[2]/100)),2)
			aImp[03]:= aImp[03]- aImp[04]
		EndIF
		xRet:=aImp
	Else
		If SF4->F4_CALCIVA == "3"
			nImp := 0
		Else
			nImp:=nBase - (nBase /(1+(nAliq/100)))
			nBase-=nImp
		EndIF
		
		Do Case
			Case cCalculo=="B"
				xRet:=nBase
			Case cCalculo=="A"
				xRet:=nALiq
			Case cCalculo=="V"
				xRet:=nImp
		EndCase
	Endif

Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  º M460IVAICR º Autor º      Nava       º Data º   17/07/01  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º        Programa que calcula o IVA Incluido ( Costa Rica [CR] )        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   º M460IVAICR                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametrosº Nenhum                                  			      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   º aImposto                                                  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       º Chamado neste programa por M460IVAI			   			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º         Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador    º Data       º Motivo da Alteracao                      º±±
±±ºCamila Januárioº 07/10/11   º Localização Costa Rica 2011              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ºxx/xx/xxºxxxxxxº                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460IVAICR(cCalculo,nItem,aInfo,lXFis)

LOCAL aImp,aItem,cImp,xRet,nOrdSFC,nRegSFC,nImp
LOCAL nBase:=0, nAliq:=0
LOCAL nDecs
Local cConcept := ""
Local lCalcIVA := .F.
Local cProduto := ""
//Local cImp     := "" 
Local cImpIncid := ""
Local nPos
LOCAL nI
LOCAL nEE
//Local nDecs := 0
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os decimais da moeda para arredondamento do valor  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                  ³
³                                                               ³
³ a variavel ParamIxb tem como conteudo um Array[2], contendo : ³
³ [1,1] > Quantidade Vendida                                    ³
³ [1,2] > Preco Unitario                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...             ³
³ [1,4] > Valor do Frete rateado para este Item ...             ³
³ [1,5] > Valor das Despesas rateado para este Item...          ³
³ [1,6] > Array Contendo os Impostos já calculados, no caso de  ³
³        incidência de outros impostos.                         ³
³ [2,1] > Array aImposto, Contendo as Informações do Imposto que³
³         será calculado.                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/


If !lXFis
	aItem    := ParamIxb[1]
	xRet     := ParamIxb[2]
	cImp     := xRet[1]
	cProduto := xRet[16]
	cImpIncid := xRet[10]
Else
	xRet     := 0
	cProduto := MaFisRet(nItem,"IT_PRODUTO")
	cImp     := aInfo[X_IMPOSTO]
EndIf

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+cProduto))
	cConcept := SB1->B1_CONIVA
	lCalcIVA := IIF(SB1->B1_CALCIVA=="1",.T.,.F.)
EndIf

dbSelectArea("SFB")
SFB->(dbSetOrder(1))
If SFB->(dbSeek(xFilial("SFB")+cImp))
	nAliq := SFB->FB_ALIQ
Endif
	                                                   
dbSelectArea("CCR")
CCR->(dbSetOrder(1))//CCR_FILIAL+CCR_CONCEP+CCR_PAIS
If CCR->(dbSeek(xFilial("CCR")+cConcept))		
	nAliq := CCR->CCR_ALIQ		
EndIf   
 

	If !lXFis
		nBase:=aItem[3]//+aItem[4]+aItem[5]  //valor total + frete + outros impostos
	Else
		nBase:=MaFisRet(nItem,"IT_VALMERC")//+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		If GetNewPar('MV_DESCSAI','1')=='1' 
			nBase	+= MaFisRet(nItem,"IT_DESCONTO")
		Endif
	Endif

If lCalcIVA 
	
	If !lXFis
		xRet[02]:=nAliq
		xRet[11] := aItem[4]								// Rateio do Frete
		xRet[13] := aIteM[5]     							// Rateio de Despesas
		xRet[03] := nBase	
		
		//Tira os descontos se for pelo liquido .Bruno
		If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
			xRet[3]	-=xRet[18]
			nBase	:=xRet[3]
		Endif
		
		//+---------------------------------------------------------------+
		//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
		//+----------------------------------------------------------Lucas+
		nI := At( cImpIncid,";" )
		nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
		While nI > 1
			nEE:= AScan( aItem[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
			If nEE> 0
				xRet[3] := xRet[3]+aItem[6,nEE,4]
			Endif
			cImpIncid := Stuff( cImpIncid,1,nI,"" )
			nI := At( cImpIncid,";" )
			nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
		Enddo
		
		//+---------------------------------------------------------------+
		//¦ Efetua o Calculo do Imposto                                   ¦
		//+---------------------------------------------------------------+
		xRet[4] := xRet[3] - Round(xRet[3] /(1+(xRet[2]/100)),nDecs)				
		
	Else
	
		Do Case
			Case cCalculo=="B"
				//Tira os descontos se for pelo liquido
				nOrdSFC:=(SFC->(IndexOrd()))
				nRegSFC:=(SFC->(Recno()))
				
				SFC->(DbSetOrder(2))
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
					cImpIncid := Alltrim(SFC->FC_INCIMP)
					If SFC->FC_LIQUIDO=="S"
						nBase-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
					Endif
				Endif
				
				SFC->(DbSetOrder(nOrdSFC))
				SFC->(DbGoto(nRegSFC))
				
			   //+---------------------------------------------------------------+
			   //¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
			   //+---------------------------------------------------------------+
			   If !Empty(cImpIncid)
			 	   aImpRef:=MaFisRet(nItem,"IT_DESCIV")
				   aImpVal:=MaFisRet(nItem,"IT_VALIMP")
				   For nI:=1 to Len(aImpRef)
				       If !Empty(aImpRef[nI])
					      If AllTrim(aImpRef[nI][1])$cImpIncid
						     nBase += aImpVal[nI]
					      EndIf
					   EndIf   
				   Next	nI
			   EndIf
		    
		      xRet:=nBase
			  
		   Case cCalculo=="A"
				xRet:=nALiq
		   Case cCalculo=="V"
				//xRet:=nImp
				nAliq := MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
				nBase := MaFisRet(nItem,"IT_BASEIV"+aInfo[2])
				xRet  := nBase-(nBase /(1+(nAliq/100)))
				xRet  := Round(xRet,nDecs)	
		EndCase
	EndIf
EndIf

Return( xRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  º M460IVAIUR º Autor º      Nava       º Data º   17/07/01  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º        Programa que calcula o IVA Incluido ( URUGUAI    [UR] )        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   º M460IVAUR                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametrosº Nenhum                                  			           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   º aImposto                                                  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       º Chamado neste programa por M460IVAI			   			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º         Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramadorº Data   º BOPS º  Motivo da Alteracao                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ºxx/xx/xxºxxxxxxº                                           º±±
±±º           º        º      º                                           º±±
±±º           º        º      º                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460IvaiUR(cCalculo,nItem,aInfo,lXFis)  // URUGUAI

LOCAL xRet
LOCAL aItem
LOCAL cImp
LOCAL nOrdSFC
LOCAL nRegSFC
LOCAL nImp
LOCAL nBase:=0
LOCAL nAliq:=0
LOCAL nDecs := 2
LOCAL lCalc1 := .F.
LOCAL cImpIncid:="",nI:=0,nE:=0,nAliqI:=0

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                  ³
³                                                               ³
³ a variavel ParamIxb tem como conteudo um Array[2], contendo : ³
³ [1,1] > Quantidade Vendida                                    ³
³ [1,2] > Preco Unitario                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...             ³
³ [1,4] > Valor do Frete rateado para este Item ...             ³
³ [1,5] > Valor das Despesas rateado para este Item...          ³
³ [1,6] > Array Contendo os Impostos já calculados, no caso de  ³
³        incidência de outros impostos.                         ³
³ [2,1] > Array aImposto, Contendo as Informações do Imposto que³
³         será calculado.                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

If !lXfis
   aItem := ParamIxb[1]
   xRet	:= ParamIxb[2]
   cImp	:= xRet[1]
   cImpIncid:=xRet[10]
	If cModulo $ "FAT|LOJA|FRT|TMK"
		If !(SA1->A1_TIPO $ "456")  //ISENTOS
			lCalc1 := .T.
		Endif
	Else
		If !(SA2->A2_TIPO $ "456")  //ISENTOS
			lCalc1 := .T.
		Endif
	Endif
Else
	cImp:= aInfo[1]
	xRet:=0
	If MaFisRet(,"NF_CLIFOR")=="C"
		If !(SA1->A1_TIPO $ "456")  //ISENTOS
			lCalc1 := .T.
		Endif
	Else
		If !(SA2->A2_TIPO $ "456")  //ISENTOS
			lCalc1 := .T.
		Endif
	Endif
Endif           

//+---------------------------------------------------------------+
//¦ Verificar o tipo do Fornecedor.                               ¦
//+---------------------------------------------------------------+
   
If lCalc1
   DbSelectArea("SFB")    //Busca a aliquota padrao
   DbSetOrder(1)   
   If Dbseek(xFilial()+cImp)
      nAliq := SFB->FB_ALIQ
   Endif
   If !lXFis
      nBase:=aItem[3] //+aItem[4]+aItem[5]  //valor total + frete + outros impostos
   Else
   	nBase:=MaFisRet(nItem,"IT_VALMERC") //+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")
		If GetNewPar('MV_DESCSAI','1')=='1' 
			nBase	+= MaFisRet(nItem,"IT_DESCONTO")
		Endif
   Endif

   nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))

   If !lXFis
      xRet[02]:=nAliq
      xRet[03]:=nBase

      //Tira os descontos se for pelo liquido .Bruno
      If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
	      xRet[3]	-=xRet[18]
      Endif
	//+---------------------------------------------------------------+
	//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
	//+---------------------------------------------------------Lucas-+
 	  nI := At( ";",cImpIncid)
	  nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
	  While nI>1
	  		nE:=AScan(aItem[6],{|x| x[1]==Left(cImpIncid,nI-1)})
			If nE>0
				xret[3]-=aItem[6,nE,4]
			End
			cImpIncid:=Stuff(cImpIncid,1,nI,"")
			nI := At( ";",cImpIncid)
			nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
	  Enddo

      //+---------------------------------------------------------------+
      //¦ Efetua o Calculo do Imposto                                   ¦
      //+---------------------------------------------------------------+
      xRet[4] := xRet[3] - Round(xRet[3] /(1+(xRet[2]/100)),nDecs)
      xRet[03]:= xRet[03]- xRet[04]
   
   Else
      //Tira os descontos se for pelo liquido
      nOrdSFC:=(SFC->(IndexOrd()))
      nRegSFC:=(SFC->(Recno()))
    
      SFC->(DbSetOrder(2))
      If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
         If SFC->FC_LIQUIDO=="S"
            nBase-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
         Endif
		 cImpIncid:=Alltrim(SFC->FC_INCIMP)
      Endif   
    
      SFC->(DbSetOrder(nOrdSFC))
      SFC->(DbGoto(nRegSFC))
	  //+---------------------------------------------------------------+
	  //¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
	  //+----------------------------------------------------------Lucas+
	  aImpRef:=MaFisRet(nItem,"IT_DESCIV")
	  aImpVal:=MaFisRet(nItem,"IT_VALIMP")
	  nI := At( ";",cImpIncid)
	  nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	  While nI > 1
			nE:= AScan( aImpRef,{|x| x[1] == Left(cImpIncid,nI-1) } )
			If nE> 0
				nBase-=aImpVal[nE]
			Endif
			cImpIncid := Stuff( cImpIncid,1,nI,'' )
		    nI := At( ";",cImpIncid)
			nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	  EndDo       
      
      nImp:=nBase-(nBase /(1+(nAliq/100)))
      nBase-=nImp
    
      Do Case
         Case cCalculo=="B"
            xRet:=nBase
         Case cCalculo=="A"
            xRet:=nALiq
         Case cCalculo=="V"
            xRet:=nImp
      EndCase    
   EndIf   
Endif
	
Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³¦¦Funcao    ³M460IVAIES³ Autor ³ Fernando Machima       ³ Data ³ 24/11/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³¦¦Descricao ³ Programa que Calcula o IVA incluido (El Salvador)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³¦¦Uso       ³ Documentos de entrada/saida                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Fernando M.  ³24/11/03³xxxxxx³ Desenvolvimento inicial                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460IVAIES(cCalculo,nItem,aInfo,lXFis)

Local aImp
Local aItem
Local cImp
Local xRet
Local nOrdSFC
Local nRegSFC
Local nImp
Local nBase := 0
Local nAliq := 0
Local nDecs
Local lLocxNF  := Type("aCfgNF")=="A"
Local lCalcImp := .F.

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                  ³
³                                                               ³
³ a variavel ParamIxb tem como conteudo um Array[2], contendo : ³
³ [1,1] > Quantidade Vendida                                    ³
³ [1,2] > Preco Unitario                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...             ³
³ [1,4] > Valor do Frete rateado para este Item ...             ³
³ [1,5] > Valor das Despesas rateado para este Item...          ³
³ [1,6] > Array Contendo os Impostos já calculados, no caso de  ³
³        incidência de outros impostos.                         ³
³ [2,1] > Array aImposto, Contendo as Informações do Imposto que³
³         será calculado.                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
If !lXFis
	aItem  := ParamIxb[1]
	aImp   := ParamIxb[2]
	cImp   := aImp[1]
	xRet   := aImp
Else
	cImp   := aInfo[1]
	xRet   := 0
Endif

//Para as rotinas de Nota de Credito(NCP) deve verificar o fornecedor
//Deve calcular IVA para Contribuintes(1) e Naturais(2)
If IIf(lLocxNF,aCfgNf[2]=="SA2",.F.)
   //Contribuintes e Naturais
   If cImp == "IVA"
      lCalcImp := SA2->A2_TIPO $ "1|2"
   //IVA Zero   
   ElseIf cImp == "IV0"
      lCalcImp := SA2->A2_TIPO == "4"      
   EndIf   
Else
   If cImp == "IVA"
      lCalcImp := SA1->A1_TIPO $ "1|2"
   ElseIf cImp == "IV0"
      lCalcImp := SA1->A1_TIPO == "4"      
   EndIf         
Endif

If lCalcImp
	DbSelectArea("SFB")    // busca a aliquota padrao
	DbSetOrder(1)
	If DbSeek(xFilial()+cImp)
		nAliq := SFB->FB_ALIQ
	Endif
	
	If !lXFis
		nBase := aItem[3]+aItem[4]+aItem[5]  //valor total + frete + outros impostos
	Else
		nBase := MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		If GetNewPar('MV_DESCSAI','1')=='1' 
			nBase	+= MaFisRet(nItem,"IT_DESCONTO")
		Endif
	Endif
	
    nDecs := IIf(Type("nMoedaNf")#"U",MsDecimais(nMoedaNf),IIf(Type("nMoedaCor")#"U",MsDecimais(nMoedaCor),MsDecimais(1)))
	
	If !lXFis
		aImp[02] := nAliq
		aImp[03] := nBase
		
		//Tira os descontos se for pelo liquido .Bruno
		If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
			aImp[3]	-= aImp[18]
			nBase	:= aImp[3]
		Endif
		
		aImp[4]  := aImp[3] - Round(aImp[3] /(1+(aImp[2]/100)),nDecs)

		// Caso o imposto seja diferente de IV0 e o valor do imposto eh igual a zero
		// eh necessario tambem "zerar" o valor da base de imposto.
		If (cImp <> "IV0") .And. (aImp[04] == 0)                 
			aImp[03] := 0
		Else
			aImp[03] := aImp[03]- aImp[04]
		EndIf
		
		xRet := aImp
	Else
		//Tira os descontos se for pelo liquido
		nOrdSFC := (SFC->(IndexOrd()))
		nRegSFC := (SFC->(Recno()))
		
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
			If SFC->FC_LIQUIDO=="S"
				nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
			Endif
		Endif
		
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
		
		nImp  := nBase-(nBase /(1+(nAliq/100)))
		nBase -= nImp
		
		Do Case
			Case cCalculo=="B"
				xRet := nBase
			Case cCalculo=="A"
				xRet := nALiq
			Case cCalculo=="V"
				xRet := nImp
		EndCase
	EndIf
EndIf

Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Funcao    ³M460IVAIGU³ Autor ³ Fernando Machima       ³ Data ³ 07/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Descricao ³ Programa que Calcula o IVA incluido (Loc. Guatemala)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso       ³ Documentos de entrada/saida                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Fernando M.  ³07/06/04³xxxxxx³ Desenvolvimento inicial                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460IVAIGU(cCalculo,nItem,aInfo,lXFis)

Local aImp
Local aItem
Local cImp
Local xRet
Local nOrdSFC
Local nRegSFC
Local nImp
Local nBase := 0
Local nAliq := 0
Local nDecs
Local lLocxNF  := Type("aCfgNF")=="A"
Local lCalcImp := .F.

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                  ³
³                                                               ³
³ a variavel ParamIxb tem como conteudo um Array[2], contendo : ³
³ [1,1] > Quantidade Vendida                                    ³
³ [1,2] > Preco Unitario                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...             ³
³ [1,4] > Valor do Frete rateado para este Item ...             ³
³ [1,5] > Valor das Despesas rateado para este Item...          ³
³ [1,6] > Array Contendo os Impostos já calculados, no caso de  ³
³        incidência de outros impostos.                         ³
³ [2,1] > Array aImposto, Contendo as Informações do Imposto que³
³         será calculado.                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
If !lXFis
	aItem  := ParamIxb[1]
	aImp   := ParamIxb[2]
	cImp   := aImp[1]
Else
	cImp   := aInfo[1]
Endif

//Para as rotinas de Nota de Credito(NCP) deve verificar o fornecedor
//Deve calcular IVA para Contribuintes(1), Isentos(2) e Agentes de Retencao(3)
If IIf(lLocxNF,aCfgNf[2]=="SA2",.F.)
   lCalcImp := SA2->A2_TIPO $ "1|2|3"
Else
   lCalcImp := SA1->A1_TIPO $ "1|2|3"
Endif

If lCalcImp
	DbSelectArea("SFB")    // busca a aliquota padrao
	DbSetOrder(1)
	If DbSeek(xFilial()+cImp)
		nAliq := SFB->FB_ALIQ
	Endif
	
	If !lXFis
		nBase := aItem[3]+aItem[4]+aItem[5]  //valor total + frete + outros impostos
	Else
		nBase := MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		If GetNewPar('MV_DESCSAI','1')=='1' 
			nBase	+= MaFisRet(nItem,"IT_DESCONTO")
		Endif
	Endif
	
    nDecs := IIf(Type("nMoedaNf")#"U",MsDecimais(nMoedaNf),IIf(Type("nMoedaCor")#"U",MsDecimais(nMoedaCor),MsDecimais(1)))
	
	If !lXFis
		aImp[02] := nAliq
		aImp[03] := nBase
		
		//Tira os descontos se for pelo liquido .Bruno
		If Subs(aImp[5],4,1) == "S"
			aImp[3]	-= aImp[18]
			nBase	:= aImp[3]
		Endif
		
		aImp[4]  := aImp[3] - Round(aImp[3] /(1+(aImp[2]/100)),nDecs)

		// Caso o valor do imposto seja igual a zeroe mesmo que a aliquota do imposto seja
		//maior que zero, eh necessario tambem zerar o valor da base de imposto.
		If aImp[04] == 0 .And. nAliq > 0                
			aImp[03] := 0
		Else
			aImp[03] := aImp[03]- aImp[04]
		EndIf
		
		xRet := aImp
	Else
		//Tira os descontos se for pelo liquido
		nOrdSFC := (SFC->(IndexOrd()))
		nRegSFC := (SFC->(Recno()))
		
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
			If SFC->FC_LIQUIDO=="S"
				nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
			Endif
		Endif
		
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
		
		nImp  := nBase-(nBase /(1+(nAliq/100)))
		nBase -= nImp
		
		Do Case
			Case cCalculo=="B"
				xRet := nBase
			Case cCalculo=="A"
				xRet := nALiq
			Case cCalculo=="V"
				xRet := nImp
		EndCase
	EndIf
Else	
   xRet  := IIf(!lXFis,ParamIxb[2],0)		
EndIf

Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³¦¦Funçào    ³M460IVAIPA³ Autor ³ Marcio Nunes	       ³ Data ³ 09/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³¦¦Descriçào ³ Programa que Calcula o IVA (Paraguai)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³¦¦Uso       ³ Documentos de entrada e saida.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  ANALISTA    ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Danilo Calil  ³08/12/06³111601³Tratamento para quando o campo A1_TIPO for ³±±
±±³              ³        ³      ³"N".                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460IVAIPA(cCalculo,nItem,aInfo,lXFis)

Local aImp		:= {}			// Impostos
Local aItem		:= {}			// Item
Local cImp		:= ""			// Descricao Imposto
Local xRet						// Retorno
Local nOrdSFC	:= 0			// Ordem no SFC
Local nRegSFC	:= 0			// Registro no SFC
Local nImp		:= 0			// Imposto
Local nBase		:= 0			// Base
Local nAliq		:= 0			// Aliquota
Local nDecs		:= 0			// Decimais
Local lCalc1 	:= .F.			// Se efetua calculo
Local nMoeda	:= 1           
Local cConcProd	:= ""
Local cProd		:= "" 
Local cImpIncid	:= ""
Local nBaseAnt 	:= 0 
Local nAliqAg	:= 0
Local lLiqui	:= .F.
Local lTotal	:= .F. 
  
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                  ³
³                                                               ³
³ a variavel ParamIxb tem como conteudo um Array[2], contendo : ³
³ [1,1] > Quantidade Vendida                                    ³
³ [1,2] > Preco Unitario                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...             ³
³ [1,4] > Valor do Frete rateado para este Item ...             ³
³ [1,5] > Valor das Despesas rateado para este Item...          ³
³ [1,6] > Array Contendo os Impostos já calculados, no caso de  ³
³        incidência de outros impostos.                         ³
³ [2,1] > Array aImposto, Contendo as Informações do Imposto que³
³         será calculado.                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

If !lXfis
   aItem:=ParamIxb[1]
   aImp	:=ParamIxb[2]
   cImp	:=aImp[1]
   xRet := aImp 
   cTes	:= SF4->F4_CODIGO
   cProd:= SB1->B1_COD
Else
	cImp:=aInfo[1]   
   cTes			:= MaFisRet(nItem,"IT_TES")
   cProd		:= MaFisRet(nItem,"IT_PRODUTO")
   nValMerc		:= MaFisRet(nItem,"IT_VALMERC")
Endif           

If cModulo $ "FAT|LOJA|FRT|TMK"
	dbSelectArea( "SA1" )
	If A1_TIPO <> "N"
		lCalc1 := .T.
	Endif
Else
	dbSelectArea( "SA2" )
	If A2_TIPO <> "N"
		lCalc1 := .T.
	Endif
Endif    
If SB1->(FieldPos("B1_CONISC"))>0 .And. SB1->(dbseek(xfilial("SB1")+Alltrim(cProd)))
	cConcProd := SB1->B1_CONISC
EndIf  

DbSelectArea("SFB")    
   	SFB->(DbSetOrder(1))
   	If SFB->(Dbseek(xFilial("SFB")+cImp))
	nAliq := SFB->FB_ALIQ
Endif 

DbSelectArea("SFB")    
   	SFB->(DbSetOrder(1))
   	If SFB->(Dbseek(xFilial("SFB")+cImpIncid))
	nAliqAg := SFB->FB_ALIQ
Endif

If lCalc1
	
	If Type("M->F1_MOEDA")<>"U" 
		nMoeda:= M->F1_MOEDA      
	ElseIf Type("M->C7_MOEDA")<>"U"
		nMoeda:= M->C7_MOEDA    
	ElseIf Type("M->F2_MOEDA")<>"U" 
		nMoeda:= M->F2_MOEDA    
	ElseIf Type("M->C5_MOEDA")<>"U"
		nMoeda:= M->C5_MOEDA      
	ElseIf Type("nMoedaPed")<>"U"	 
		nMoeda:= nMoedaPed           
	ElseIf Type("nMoedaNf")<> "U"
		nMoeda:= nMoedaNf    
	ElseIf Type("nMoedaCor")<> "U"
		nMoeda:= nMoedaCor    		      	
    ElseIf lXFis
		nMoeda 		:= MAFISRET(,'NF_MOEDA')   
	EndIf
	If Type("nTipoGer")<> "U" .And.	Type("nMoedSel")<> "U"	
		nMoeda:= If(nTipoGer==2,nMoedSel,SC5->C5_MOEDA)	
	EndIf		
	
	nDecs := MsDecimais(nMoeda)
		
	If !lXFis
	
		If Empty(cConcProd)
			nBase:=aItem[3]+aItem[4]+aItem[5]  //valor total + frete + outros impostos
	   		If aImp[4]>0
		   		nBase:=nBase+aImp[4]
	   		EndIf
	   		nBase:=Round(nBase,nDecs)
	   		aImp[02]:=nAliq
	   		aImp[03]:=nBase
	
	   		//Tira os descontos se for pelo liquido .Bruno
	   		If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
		    	aImp[3]	-=aImp[18]
		    	nBase	:=aImp[3]
	   		Endif
	
	   		//+---------------------------------------------------------------+
	   		//¦ Efetua o Calculo do Imposto                                   ¦
	   		//+---------------------------------------------------------------+
	   		aImp[4] := aImp[3] - Round(aImp[3] /(1+(aImp[2]/100)),nDecs)
	   		aImp[03]:= aImp[03]- aImp[04]
	   			   
	   		xRet:=aImp
		Else 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Base de calculo composta pelo valor da mercadoria + frete + seguro  ³
			//³Observacao Importante: em Angola nao ha a figura de frete e seguro, ³
			//³porem o sistema deve estar preparado para utilizar esses valores no ³
			//³calculo do imposto.                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nBase := aItem[3]+aItem[4]+aItem[5]      
			
			nOrdSFC:=(SFC->(IndexOrd()))
			nRegSFC:=(SFC->(Recno()))
		
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+cTes+cImp)))
				cImpIncid:=Alltrim(SFC->FC_INCIMP)
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Reduz os descontos concedidos da base de calculo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18]) == "N"
				nBase -= aImp[18]
			Endif
	   		If !Empty(cImpIncid)
		   		DbSelectArea("SFB")
	           	If DbSeek(xFilial() + cImpIncid )
		        	nAliqAg := FB_ALIQ
			    Endif				
		    EndIf                                               
		
			DbSelectArea("SFF")
			SFF->(DbSetOrder(15))
			If SFF->(DbSeek(xFilial("SFF")+cImp+cConcProd)) .And. SFF->FF_ALIQ>0
				nAliq:=SFF->FF_ALIQ
			EndIf 
			If SFF->(DbSeek(xFilial("SFF")+cImpIncid+cConcProd)) .And. SFF->FF_ALIQ>0
				nAliqAg:=SFF->FF_ALIQ
			EndIf
				//Calculo por dentro - Incluido			                    	   	   
		  	xRet:= Round((nBase/(1+(nAliq/100))/(1+(nAliqAg/100))),nDecs)
		   	aImp[03]:= NoRound(xRet* (1+(nAliqAg/100)),nDecs)
		   	aImp[04]:= Round((aImp[03] * nAliq)/100,nDecs)
		   	xRet:=aImp    
			   	   	   	   
		 	SFC->(DbSetOrder(nOrdSFC))                               
			SFC->(DbGoto(nRegSFC))
		EndIf	   	      	   	                              
	Else
   	
		nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		If GetNewPar('MV_DESCSAI','1')=='1'
			nBase	+= MaFisRet(nItem,"IT_DESCONTO")
		Endif
		nBase:=Round(nBase,nDecs)
		nBaseAnt := nBase

   		nOrdSFC:=(SFC->(IndexOrd()))
		nRegSFC:=(SFC->(Recno()))
	
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
			lTotal := (SFC->FC_CALCULO=="T")
			lLiqui := (SFC->FC_LIQUIDO=="S")
		EndIf
   	
	   	//Tira os descontos se for pelo liquido
       	If lLiqui
			nBase-=MaFisRet(nItem,"IT_DESCONTO")
	   	Endif
	   
	   	If Empty(cConcProd)
   	   		//Imposto incluido (IVC) tem um tratamento especifico para obtencao da base
	   		nImp:=nBase-(nBase /(1+(nAliq/100)))
	   		nBase -= nImp
	   	EndIf	    
	    
	   	Do Case
	      	Case cCalculo=="B"      
				cImpIncid:=Alltrim(SFC->FC_INCIMP)
				If Empty(cConcProd)
	            	xRet:=nBase
	   			Else
		   			If SFC->FC_LIQUIDO=="S"
						nBase-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
					Endif   
	   				//+---------------------------------------------------------------+
					//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
					//+---------------------------------------------------------------+
			   		nAliqAg:=0
			   		If !Empty(cImpIncid)
				   		DbSelectArea("SFB")
		            	If DbSeek(xFilial() + cImpIncid )
	  			        	nAliqAg := FB_ALIQ
	     			    Endif				
				    EndIf
				    dbSelectArea("SFF")			
					SFF->(DbSetOrder(15))
					If SFF->(DbSeek(xFilial("SFF")+cImpIncid+cConcProd)) .And. SFF->FF_ALIQ>0
						nAliqAg	:=SFF->FF_ALIQ
					EndIf       									
					If SFF->(DbSeek(xFilial("SFF")+cImp+cConcProd)) .And. SFF->FF_ALIQ>0
						nAliq:=SFF->FF_ALIQ
					EndIf 					
					
   					xRet:= Round(nBase/(1+(nAliq/100))/(1+(nAliqAg/100)),nDecs)  
					xRet:= NoRound(xRet* (1+(nAliqAg/100)),nDecs)
										
	            EndIf
	      	Case cCalculo=="A"                
	      		If Empty(cConcProd)
		      	 	xRet:=nALiq 
		      	Else
		      		dbSelectArea("SFF")
					SFF->(DbSetOrder(15))		      	
		      		If SFF->(DbSeek(xFilial("SFF")+cImp+cConcProd)) .And. SFF->FF_ALIQ>0
						nAliq	:=SFF->FF_ALIQ
						xRet:=nALiq
					Else    
			      		DbSelectArea("SFB")
			            If DbSeek(xFilial() + aInfo[X_IMPOSTO] )
				           xRet := FB_ALIQ
	    	    	    Endif                                           
	    	    	EndIf
	    	    EndIf	      
	       
	      	Case cCalculo=="V"
	      		If Empty(cConcProd)
		      		If lTotal
						//Se o calculo eh pelo total, somo os valores ja lancados para a NF (relativo aos itens anteriores)
						nBase := nBaseAnt + MaFisRet(,"NF_VALMERC")+MaFisRet(,"NF_FRETE")+MaFisRet(,"NF_DESPESA")+MaFisRet(,"NF_SEGURO")
						If lLiqui
							nBase-=MaFisRet(nItem,"NF_DESCONTO")
						EndIf
						nImp:=nBase-(nBase /(1+(nAliq/100)))
					EndIf
					xRet:=nImp
	      		Else
		      		If lTotal
	   	       			nBase:=MaRetBasT(aInfo[X_NUMIMP],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[X_NUMIMP]))        	   		
						If lLiqui              
							nBase-=MaFisRet(nItem,"NF_DESCONTO")
		     			EndIf	
		        	 Else       	
	        	        nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
						If lLiqui              
							nBase-=MaFisRet(nItem,"IT_DESCONTO")
						EndIf	                                                   
					EndIf
	               	nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
	                
	                //Aplica o valor do ISC(Imposto Seletivo ao Consumo) ao IVA
	               	xRet := Round((nBase * nAliq)/100,nDecs)
               	EndIf
                                           	
	   EndCase
   	   SFC->(DbSetOrder(nOrdSFC))
	   SFC->(DbGoto(nRegSFC))
	Endif
ElseIf Empty(cImpIncid)
	xRet  :=  IIf(!lXFis,ParamIxb[2],0)
Endif
	
Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460IVAIPTºAutor  ³Mary C. Hergert     º Data ³ 24/05/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o IVA incluido para Portugal                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaFis                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460IVAIPT(cCalculo,nItem,aInfo,lXFis)

Local aImp 		:= {}
Local aItem 	:= {}
Local aArea		:= GetArea()

Local cImp		:= ""
Local cTes   	:= ""
Local cRegiao	:= ""
Local cGrpAces	:= GetNewPar("MV_GRPACES","FR=004;SE=005;DT=006;DN=007;TA=008")
Local cGrupo	:= ""                      
Local cProd		:= ""
Local cImpDesp	:= "IVF|IVD|IVS|IVT"

Local nOrdSFC   := 0    
Local nRegSFC   := 0
Local nImp   	:= 0
Local nBase		:= 0
Local nAliq 	:= 0
Local nDecs 	:= 0  
Local nPos	 	:= 0
Local lIsento	:= .F.
Local lImpDep	:= .F.
Local lCalcLiq	:= .F.
Local cChave    := ""
Local dEmissao

Local xRet
Local nMoeda	:= 1

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                                  ³
³                                                                               ³
³ A variavel ParamIxb tem como conteudo um Array[2], contendo :                 ³
³ [1,1] > Quantidade Vendida                                                    ³
³ [1,2] > Preco Unitario                                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...                             ³
³ [1,4] > Valor do Frete rateado para este Item                                 ³
³         Para Portugal, o imposto do frete e calculado em separado do item     ³
³ [1,5] > Valor das Despesas rateado para este Item                             ³
³         Para Portugal, o imposto das despesas e calculado em separado do item ³
³ [1,6] > Array Contendo os Impostos já calculados, no caso de incidência de    ³
³         outros impostos.                                                      ³
³ [2,1] > Array aImposto, contendo as Informações do Imposto que será calculado.³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
If !lXfis
   aItem	:= ParamIxb[1]
   aImp		:= ParamIxb[2]
   cImp		:= aImp[1]
   cTes		:= SF4->F4_CODIGO
   cProd 	:= SB1->B1_COD
Else
   cImp		:= aInfo[1]
   cTes		:= MaFisRet(nItem,"IT_TES")
   cProd	:= MaFisRet(nItem,"IT_PRODUTO")   
Endif           
               
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificando o cadastro do produto movimentado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Frontloja usa o arquivo SBI para cadastro de produtos
If cModulo == "FRT" 
	SBI->(DbSeek(xFilial("SBI")+cProd))
Else   
	SB1->(DbSeek(xFilial("SB1")+cProd))
Endif    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o cliente ou fornecedor sao isentos pelo cadastro:         ³
//³1 = SP IVA - Pessoa Singular (sujeito passivo de IVA, pessoa singular) ³
//³2 = SP IVA - Pessoa Colectiva (sujeito passivo de IVA, pessoa coletiva)³
//³3 = Isento IVA Pessoa Singular                                         ³
//³4 = Isento IVA Pessoa Colectiva                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModulo $ "FAT|LOJA|FRT|TMK"
	If SA1->A1_TIPO $ "34"
		lIsento := .T.
	Endif
	If SA1->(ColumnPos("A1_PAISEMP")) == 0 .or. SA1->A1_PAISEMP == "S"	 
		cRegiao := GetNewPar("MV_GRPTRIB","")
	Else
		cRegiao := SA1->A1_GRPTRIB                              
	Endif	
Else 
	If SA2->A2_TIPO $ "34"
		lIsento := .T.
	Endif
	If SA2->(ColumnPos("A2_PAISEMP")) == 0 .or. SA2->A2_PAISEMP == "S"
		cRegiao := GetNewPar("MV_GRPTRIB","")
	Else
		cRegiao := SA2->A2_GRPTRIB
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o grupo de tributacao das despesas acessorias:³
//³IVA - IVA das mercadorias                              ³
//³IVF - IVA frete                                        ³
//³IVD - IVA despesas                                     ³
//³IVS - IVA seguro                                       ³
//³IVT - IVA tara                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
Case cImp == "IVF"
	nPos := At("FR",cGrpAces) 	
Case cImp == "IVD"
	nPos := At("DT",cGrpAces) 	
Case cImp == "IVS"
	nPos := At("SE",cGrpAces) 	
Case cImp == "IVT"
	nPos := At("TA",cGrpAces) 	
EndCase

If cImp $ cImpDesp
	If nPos > 0
		cGrupo := Padr(SubStr(cGrpAces,nPos+3,3),TamSx3("B1_GRTRIB")[1])
	Endif
Else
	//Frontloja usa o arquivo SBI para cadastro de produtos
	If cModulo=="FRT"
		cGrupo := SBI->BI_GRTRIB
	Else
		cGrupo := SB1->B1_GRTRIB
	Endif
Endif

If Empty(cRegiao)
	cRegiao := GetNewPar("MV_GRPTRIB","")
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a existencia do Plano IVA  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SFF")
SFF->(dbSetOrder(14))
If SFF->(dbseek(xFilial("SFF")+cImp+cRegiao+cGrupo))

	If !lIsento		
		//Busca a aliquota na tabela de plano IVA
		If SFF->FF_TIPO == "S" .or. SFF->FF_TIPO == "I"
			lIsento := .T.
		Endif
		nAliq := SFF->FF_ALIQ		
	EndIf	
	cChave := xFilial("CE8")+SFF->FF_IMPOSTO+SFF->FF_REGIAO+SFF->FF_TIPO
		
Else

	//Busca a aliquota padrao para o imposto quando nao ha o plano IVA
   	DbSelectArea("SFB")    
   	SFB->(DbSetOrder(1))
   	If SFB->(Dbseek(xFilial("SFB")+cImp))
		nAliq := SFB->FB_ALIQ
	EndIf
	If FieldPos("FB_TIPALIQ") > 0
		cChave := xFilial("CE8")+SFB->FB_CODIGO+Space(TamSX3("CE8_EST")[1])+SFB->FB_TIPALIQ
	EndIf

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a existencia de aliquota na tabela de validade  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AliasInDic("CE8")
	//Busca data de emissao
	If Type("dDEmissao") == "D"
		dEmissao := dDEmissao
	Else
		dEmissao := dDataBase
	EndIf

	//Busca aliquota na tabela de aliquotas por periodo
	dbSelectArea("CE8")
	CE8->(dbSetOrder(2))
	If CE8->(dbSeek(cChave))		
		Do While cChave == CE8->CE8_FILIAL+CE8->CE8_CODIMP+CE8->CE8_EST+CE8->CE8_TIPO .and. CE8->(!EOF())
		
			If CE8->CE8_DATINI <= dEmissao  .and. CE8->CE8_DATFIN >= dEmissao 
				If CE8->CE8_ISEN == "1"
					lIsento := .T.
				Else
					nAliq := CE8->CE8_ALIQ
				EndIf
				Exit
			EndIf
			
			CE8->(dbSkip())
		EndDo		
	EndIf	
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a base de calculo do IVA do item. Somente sera somado ao total do        ³
//³item os valores referentes a outros impostos que incidem na base do IVA. As    ³
//³despesas acessorias (frete, seguro, despesas e tara) tem tributacao especifica ³
//³e nao devem ser somadas para compor a base de calculo do item.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual imposto vai calcular:³
//³IVA - IVA das mercadorias          ³
//³IVF - IVA frete                    ³
//³IVD - IVA despesas                 ³
//³IVS - IVA seguro                   ³
//³IVT - IVA tara                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lIsento
	If !lXFis 
		Do Case
		Case cImp == "IVF"
			nBase := aItem[4]
		Case cImp == "IVD"
			nBase := aItem[8]
		Case cImp == "IVS"
			nBase := aItem[9]
		Case cImp == "IVT"
			nBase := aItem[11]
		OtherWise
			nBase := aItem[3]
		EndCase
	Else           
  		Do Case
		Case cImp == "IVF"
			nBase := MaFisRet(nItem,"IT_FRETE")
		Case cImp == "IVD"
			nBase := MaFisRet(nItem,"IT_DESPESA")
		Case cImp == "IVS"
			nBase := MaFisRet(nItem,"IT_SEGURO")
		Case cImp == "IVT"
			nBase := MaFisRet(nItem,"IT_TARA")
  		OtherWise
			nBase := MaFisRet(nItem,"IT_VALMERC")
			If GetNewPar('MV_DESCSAI','1')=='1' 
				nBase	+= MaFisRet(nItem,"IT_DESCONTO")
			Endif
		EndCase
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os decimais da moeda para arredondamento do valor  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1)) 

   If Type("M->F1_MOEDA")<>"U" 
		nMoeda:= M->F1_MOEDA      
	ElseIf Type("M->C7_MOEDA")<>"U"
		nMoeda:= M->C7_MOEDA    
	ElseIf Type("M->F2_MOEDA")<>"U" 
		nMoeda:= M->F2_MOEDA    
	ElseIf Type("M->C5_MOEDA")<>"U"
		nMoeda:= M->C5_MOEDA      
	ElseIf Type("nMoedaPed")<>"U"	 
		nMoeda:= nMoedaPed           
	ElseIf Type("nMoedaNf")<> "U"
		nMoeda:= nMoedaNf    
	ElseIf Type("nMoedaCor")<> "U"
		nMoeda:= nMoedaCor    		      	
    ElseIf lXFis
		nMoeda 		:= MAFISRET(,'NF_MOEDA')   
	EndIf
	If Type("nTipoGer")<> "U" .And.	Type("nMoedSel")<> "U"	
		nMoeda:= If(nTipoGer==2,nMoedSel,SC5->C5_MOEDA)	
	EndIf		
	
	nDecs := MsDecimais(nMoeda)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se eh um imposto "dependente" de outro, pois caso seja eh necessario³
//³acertar o valor da base para que os impostos da amarracao possuam a mesma    ³
//³base de calculo.	                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cImp $ GetMV("MV_IMPSDEP",,"")

	nOrdSFC:=(SFC->(IndexOrd()))
	nRegSFC:=(SFC->(Recno()))
	SFC->(DbSetOrder(2))
	
	If (SFC->(DbSeek(xFilial("SFC")+cTes)))
	
		While !Eof() .And. (xFilial("SFC")+cTes == SFC->FC_FILIAL+SFC->FC_TES)
		
			If (SFC->FC_IMPOSTO <> cImp) .And. (SFC->FC_IMPOSTO $ GetMV("MV_IMPSDEP",,"")) .And.;
			   (SFC->FC_INCNOTA == "3")         
			   
				lImpDep := .T.    
				
   				dbSelectArea("SFB")
   				SFB->(dbSetOrder(1))
				If SFB->(dbSeek(xFilial("SFB")+SFC->FC_IMPOSTO))
					nAliqAux += SFB->FB_ALIQ
				Endif	                                
				
			ElseIf (SFC->FC_IMPOSTO == cImp)
				lCalcLiq := .T.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Reduz os descontos, quando a configuração indica calculo pelo liquido.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Somente quando for IVA de mercadorias aplica o desconto³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(cImp $ cImpDesp)
					If !lXFis .And. Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
						If !lIsento
							nBase -= aImp[18]
						Endif	
					ElseIf lXFis .And. SFC->FC_LIQUIDO=="S"
						If !lIsento
							nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
						Endif	
					EndIf  
				Endif
			EndIf
			SFC->(dbSkip())
		End
	EndIf
	SFC->(DbSetOrder(nOrdSFC))
	SFC->(DbGoto(nRegSFC))

	If lImpDep
		nAliqAux += nAliq
    	nBase    := Round(nBase /(1+(nAliqAux/100)),nDecs)		
  	EndIf                      
  	
EndIf

If !lXFis

	aImp[02] := nAliq
	aImp[03] := nBase  
	
	If aImp[4]>0
		   nBase:=nBase+aImp[4]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Reduz os descontos, quando a configuração indica calculo pelo liquido.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente quando for IVA de mercadorias aplica o desconto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(cImp $ cImpDesp)
			If !lIsento
				aImp[3]	-= aImp[18]
			Endif	
			nBase	:= aImp[3]
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua o Calculo do Imposto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lImpDep
		aImp[4] := aImp[3] - Round(aImp[3] /(1+(aImp[2]/100)),nDecs)
		aImp[3] := aImp[3] - aImp[4]
	Else
		aImp[4] := Round(aImp[3] * (aImp[02]/100),nDecs)	
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna um array com base [3], aliquota [2] e valor [4]³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xRet := aImp
	
Else
           
	//Caso seja um imposto "dependente" o tratamento de desconto ja foi realizado.	
	If !lCalcLiq

		nOrdSFC := (SFC->(IndexOrd()))
		nRegSFC := (SFC->(Recno()))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reduz os descontos, quando a configuração indica calculo pelo liquido.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+cTes+cImp)))
			If SFC->FC_LIQUIDO == "S"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Somente quando for IVA de mercadorias aplica o desconto³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(cImp $ cImpDesp) 
					If !lIsento
						nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
					Endif 	
				Endif
			Endif
		Endif                                              
		
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
		
	EndIf
       
	//Caso seja um imposto "dependente" a forma de calculo eh diferente, nao sendo
	//feita pela diferenca...	                  
	If !lImpDep
		nImp := nBase-Round(nBase /(1+(nAliq/100)),nDecs)
		nBase -= nImp
	Else
		nImp := Round(nBase * (nAliq/100),nDecs)	
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna o valor solicitado pela MatxFis (parametro cCalculo):³
	//³A = Aliquota de calculo                                      ³
	//³B = Base de calculo                                          ³
	//³V = Valor do imposto                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case cCalculo=="B"
			xRet := nBase
		Case cCalculo=="A"
			xRet := nALiq
		Case cCalculo=="V"
			xRet := nImp
	EndCase
	
Endif

RestArea(aArea)
	
Return(xRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³¦¦Funçào    ³M460IVAIAR³ Autor ³ Ivan Haponczuk         ³ Data ³ 07/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³¦¦Descriçào ³ Programa que Calcula o IVA Incluido (Argentina)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³¦¦Uso       ³ MATA468/mata467, chamado pela tes                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460IVAIAR(cCalculo, nItem, aInfo, lXFis)

Local nOrdSFC	:= 0
Local nRegSFC	:= 0
Local nImp		:= 0
Local nBase		:= 0
Local nAliq		:= 0
Local nDecs		:= 0
Local nCols		:= 0
Local xRet		:= 0
Local cImp		:= ""
Local aImp      := {}
Local cImpIncid := ""

If !lXfis
	aItem := ParamIxb[1]
	aImp  := ParamIxb[2]
	cImp  := aImp[1]
	xRet  := aImp
Else
	cImp  := aInfo[1]
	nCols := nItem
	xRet  := 0
Endif

DbSelectArea("SFB")
DbSetOrder(1)
If Dbseek(xfilial()+cImp)
	nAliq:=SFB->FB_ALIQ
Endif	
	
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))

If !lXFis
	nBase    := aItem[3]+aItem[4]+aItem[5]
	aImp[02] := nAliq
	aImp[03] := nBase
	
	//Tira os descontos se for pelo liquido.
	If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
		aImp[3]	-= aImp[18]
		nBase	:= aImp[3]
	Endif
	
	aImp[4] := aImp[3] - Round(aImp[3] /(1+(aImp[2]/100)),nDecs)
	aImp[03]:= aImp[03]- aImp[04]
	   
	xRet:=aImp
Else
	nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
	
		SFC->(DbSetOrder(2))
	If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1])))
		cImpIncid:=Alltrim(SFC->FC_INCIMP)
    EndIF			 
    
    If !Empty(cImpIncid) 
        ALiq:=0
    	If (SFB->(DbSeek(xFilial("SFB")+cImpIncid)))
	   		nALiq+=SFB->FB_ALIQ    
	 	Endif
  	Endif
	
	//Tira os descontos se for pelo liquido
	nOrdSFC:=(SFC->(IndexOrd()))
	nRegSFC:=(SFC->(Recno()))
	
	SFC->(DbSetOrder(2))
	If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
		If SFC->FC_LIQUIDO=="S"
			nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
		Endif
	Endif
	
	SFC->(DbSetOrder(nOrdSFC))
	SFC->(DbGoto(nRegSFC))

	nImp:=nBase-(nBase /(1+(nAliq/100)))
	nBase-=nImp
	
	Do Case
	Case cCalculo=="B"
		xRet:=nBase
	Case cCalculo=="A"
		xRet:=nALiq
	Case cCalculo=="V"
		xRet:=nImp
	EndCase
EndIf

Return( xRet )
