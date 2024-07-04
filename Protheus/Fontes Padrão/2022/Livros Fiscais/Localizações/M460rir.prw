#INCLUDE "PROTHEUS.CH"
#INCLUDE "M460RIR.CH"

#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO  01 //Nome do imposto
#DEFINE X_NUMIMP   02 //Sufixo do imposto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ M460RIR   ³ Autor ³ Julio Cesar         ³ Data ³ 19.11.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Retencao de IR ( Imposto de Renda )                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Fiscal - Imposto IR                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M460RIR(cCalc,nIt,aInf)

	Local aRet    := {}
	Local cFunct  := ""
	Local lXFis   := .T.
	Local aPaises := {}
	Local aArea   := GetArea()
	
	lXFis := ( MafisFound() .And. ProcName(1)!="EXECBLOCK" )
	
	aPaises := GetCountryList()
	cFunct  := "M460RIR" + aPaises[aScan(aPaises,{|x| x[1] == cPaisLoc })][3] // Retorna pais com 2 letras
	aRet    := &(cFunct)(cCalc,nIt,aInf,lXFis)
	
	RestArea( aArea )

Return( aRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ M460RIRPA ³ Autor ³ Ivan Haponczuk      ³ Data ³ 15.09.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Calculo da Retencao de IR ( Imposto de Renda )              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Fiscal - Imposto IR - Paraguai                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M460RIRPA(cCalc,nIt,aInf,lXFis)

	Local xRet    
	Local nPos   := 0
	Local nBase  := 0
	Local nMoeda := IIf(Type("nMoedaCor")=="U",1,nMoedaCor)

	If lXFis
		xRet := 0
	Else
	    xRet := ParamIxb[2]
	Endif	
	
	//+--------------------------------------------+
	//| Verifica se o cliente e agente de retencao |
	//+--------------------------------------------+
	If SA1->A1_RETIR == "1"
		If lXFis
			xRet := M460RIRFPA(cCalc,nIt,aInf,nMoeda)
		Else
			aItemINFO   := ParamIxb[1]
			aImposto    := ParamIxb[2]
			
			//+--------------------------------------------------+
			//| A base do calculo e a mesma calculada pelos IVAs |
			//+--------------------------------------------------+
			nPos  := aScan(aItemINFO[6],{|x| SubStr(x[1],1,2) $ "IV" })
			If nPos > 0
				nBase := aItemINFO[6,nPos,3]
			EndIf
			
			//+---------------------------------------------------------------------+
			//| Se nao tiver base do IVA calcula a base a partir do valor dos itens |
			//+---------------------------------------------------------------------+
			If nBase <= 0
				nBase := aItemINFO[3]+aItemINFO[4]+aItemInfo[5]
				//+-----------------------------------+
				//| Tira desconto se for pelo liquido |
				//+-----------------------------------+
		      	If Subs(aImposto[5],4,1) == "S"
		        	nBase := nBase - aImposto[18]
				EndIf
				//+---------------------------------+
				//| Se houver utiliza base reduzida |
				//+---------------------------------+
				nBase := nBase * IIf(SFC->FC_BASE>0,SFC->FC_BASE / 100,1)
			EndIf
			nBase:=Round(nBase,MsDecimais(nMoeda))
			
			//+----------------------------------------------------------------------+
			//| Calcula o imposto somente se o valor da base for maior que o importe |
			//+----------------------------------------------------------------------+
			dbSelectArea("SFF")
			SFF->(dbSetOrder(5))
			If SFF->(dbSeek(xFilial("SFF")+aImposto[1])) .And. nBase > Round(SFF->FF_IMPORTE,MsDecimais(nMoeda))
	        	aImposto[_BASECALC] := nBase
		      	aImposto[_ALIQUOTA] := SFB->FB_ALIQ
				aImposto[_IMPUESTO] := Round(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,MsDecimais(nMoeda))
			Endif
			xRet := aImposto
		EndIf
	Endif
	
Return( xRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ M460RIRPA ³ Autor ³ Ivan Haponczuk      ³ Data ³ 15.09.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Calculo da Retencao do imposto x tes - Entrada              ³±±
±±³           ³ para o uso da funcao MATXFIS                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Fiscal - Imposto IR - Paraguai                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M460RIRFPA(cCalculo,nItem,aInfo,nMoeda)

	Local nI      := 0
	Local nRet    := 0
	Local nBase   := 0
	Local nAliq   := 0
	Local aImpRef := {}
	Local aImpBas := {}

	dbSelectArea("SFB")
	SFB->(dbSetOrder(1))
	SFB->(dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO]))
	
	Do Case
		Case cCalculo=="A"
		
			nRet := SFB->FB_ALIQ
			
		Case cCalculo=="B"

			//+--------------------------------------------------+
			//| A base do calculo e a mesma calculada pelos IVAs |
			//+--------------------------------------------------+		
			nBase   := 0
			aImpRef := MaFisRet(nItem,"IT_DESCIV")
		   	aImpBas := MaFisRet(nItem,"IT_BASEIMP")
			For nI:=1 to Len(aImpRef)
				If !Empty(aImpRef[nI])
					If SubStr(aImpRef[nI][1],1,2) $ "IV"
						nBase := aImpBas[nI]
					EndIf
				EndIf
			Next
			
			//+---------------------------------------------------------------------+
			//| Se nao tiver base do IVA calcula a base a partir do valor dos itens |
			//+---------------------------------------------------------------------+
			If nBase <= 0
				dbSelectArea("SFC")
				SFC->(dbSetOrder(2))
				SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO]))
				nBase := MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_SEGURO")+MaFisRet(nItem,"IT_DESPESA")
				If GetNewPar('MV_DESCSAI','1')=='1' 
					nBase += MaFisRet(nItem,"IT_DESCONTO")
				Endif
				//+-----------------------------------+
				//| Tira desconto se for pelo liquido |
				//+-----------------------------------+
				If SFC->FC_LIQUIDO=="S"
					nBase := nBase - MaFisRet(nItem,"IT_DESCONTO")
				Endif
				//+---------------------------------+
				//| Se houver utiliza base reduzida |
				//+---------------------------------+
				nBase := nBase * (If(SFC->FC_BASE>0,SFC->FC_BASE / 100,1))
			EndIf
			nBase:=Round(nBase,MsDecimais(nMoeda))
	
			//+----------------------------------------------------------------------+
			//| Calcula o imposto somente se o valor da base for maior que o importe |
			//+----------------------------------------------------------------------+
			dbSelectArea("SFF")
			SFF->(dbSetOrder(5))
			If SFF->(dbSeek(xFilial("SFF")+aInfo[X_IMPOSTO])) .And. nBase > Round(SFF->FF_IMPORTE,MsDecimais(nMoeda))
				nRet := nBase
			Endif
				
		Case cCalculo=="V"
		
			nAliq := MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
			nBase := MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
			
			//+----------------------------------------------------------------------+
			//| Calcula o imposto somente se o valor da base for maior que o importe |
			//+----------------------------------------------------------------------+
			dbSelectArea("SFF")
			SFF->(dbSetOrder(5))
			If SFF->(dbSeek(xFilial("SFF")+aInfo[X_IMPOSTO])) .And. nBase > Round(SFF->FF_IMPORTE,MsDecimais(nMoeda))
				nRet:= Round(nBase * nAliq/100,MsDecimais(nMoeda))
			EndIf
			
	EndCase

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460RIREQºAutor  ³Marcos Kato          º Data ³ 21/06/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao do Imposto X Tes - Entrada              º±±
±±º          ³Para o uso da funcao MATXFIS                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M460RIREQ(cCalculo,nItem,aInfo)
Local cAliasRot   := Alias()
Local cOrdemRot   := IndexOrd()
Local cQrySF3,cCfoSF4,cPais,xRet
Local nBase,nAliq,nVRet,nDesconto,nMoeda
Local aImposto,aItemInfo
Local lOk := .F.
Local lRet := .T.      
xRet   :=""
cQrySF3:=""
cCfoSF4:=""
cPais  :=""
nBase  :=0
nAliq  :=0
nVRet  :=0
nDesconto:= 0
nMoeda :=	IIf(Type("nMoedaCor")=="U",1,nMoedaCor)
If !FunName()$"MATA468N|MATA461"
	If cModulo == "COM" .Or. MaFisRet(,"NF_OPERNF")=="E"
		If cModulo=="FAT"
			cPais:=SA1->A1_PAIS
			If SA1->A1_RETFUEN=='S'	
				lOk:=.T.	
			Endif
		Else
			cPais:=SA2->A2_PAIS
			If Select("QTDMOV")>0           
				DbSelectArea("QTDMOV")	
				QTDMOV->(DbCloseArea())
			Endif
			If Substr(SuperGetMv("MV_AGENTE",.F.,"SS"),2,1)=="S"
				cQrySf3:="SELECT COUNT(*) QTD "
				cQrySf3+="FROM "+RetSqlName("SF3")+" SF3 "
				cQrySf3+="WHERE D_E_L_E_T_='' "
				cQrySf3+="AND F3_CLIEFOR='"+SA2->A2_COD+"' "
				cQrySf3+="AND F3_LOJA='"+SA2->A2_LOJA+"' "
				cQrySf3+="AND F3_TIPOMOV='C' "  
				cQrySf3+="AND SUBSTRING(F3_CFO,1,1) < 5 "
				cQrySf3+="AND SUBSTRING(F3_ENTRADA,1,6)='"+Substr(Dtos(dDataBase),1,6)+"' "	
			
				cQrySf3 := ChangeQuery(cQrySf3)
				dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQrySf3 ) ,"QTDMOV", .T., .F.)
			
				//A retencao sera feita quando a empresa calcula IR  e o valor do mercado for maior que o minimo ou se ja foi efetuado compra com o mesmo fornecedor no periodo 
				If (QTDMOV->(!Eof()) .And. QTDMOV->QTD>0).Or. MaFisRet(nItem,"IT_VALMERC")>SuperGetMv("MV_MINRIR",.F.,50) 
					lOk:=.T.	
				Endif	
			EndIf
		Endif	
	Else              
		cPais:=SA1->A1_PAIS
		If SA1->A1_RETFUEN=='S'	
			lOk:=.T.	
		Endif
	Endif
	
	If lOk
		DbSelectArea("SFB")
		SFB->(dbSetOrder(1))
		If SFB->(DbSeek(xFilial("SFB")+aInfo[X_IMPOSTO]))
			If cCalculo=="B"
				nRegSFB:=SFB->(Recno())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calcula a base do imposto         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SFC")
				SFC->(DbSetOrder(2)) 
				If SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO]))
					nBase := MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+;
				         MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
					//Tira os descontos se for pelo liquido
					If GetNewPar('MV_DESCSAI','1')=='1' 
						nBase	+= MaFisRet(nItem,"IT_DESCONTO")
					Endif
					If SFC->FC_LIQUIDO=="S"
						nDesconto := MaFisRet(nItem,"IT_DESCONTO")
						nBase     -= nDesconto
					Endif
				Endif         
				SFB->(DbGoto(nRegSFB))
			ElseIf cCalculo=="A"
				nAliq := SFB->FB_ALIQ				
				
				DbSelectArea("CCR")
				CCR->(DbSetOrder(1))
				If CCR->(DbSeek(xFilial("CCR")+MaFisRet(nItem,"IT_CONCEPT")+cPais))
					nAliq := CCR->CCR_ALIQ 
				ElseIf CCR->(DbSeek(xFilial("CCR")+MaFisRet(nItem,"IT_CONCEPT"))) .And. Alltrim(CCR->CCR_PAIS)==""
					nAliq := CCR->CCR_ALIQ 				
				Endif
			Endif		
		Endif       
		If lRet
			Do Case
				Case cCalculo=="A"
					nVRet:=nAliq
				Case cCalculo=="B"
					nVRet:=nBase
				Case cCalculo=="V"
					nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
					nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
					nVRet:= Round(nBase * nAliq/100,MsDecimais(nMoeda))
			EndCase
		Endif
	Endif         
	xRet:=nVRet
Else     
	aItemINFO   := ParamIxb[1]
	aImposto    := ParamIxb[2]
	If SA1->A1_RETFUEN=='S'	
	
		aImposto[_BASECALC] := (aItemINFO[3]+aItemINFO[4]+aItemInfo[5])
	   	//Tira os descontos se for pelo liquido
	   	If Subs(aImposto[5],4,1) == "S"  
	       	aImposto[_BASECALC] := (aItemINFO[3]+aItemINFO[4]+aItemInfo[5]-aImposto[18])
	   	Endif                                                                           
		DbSelectArea("SFC")
		SFC->(DbSetOrder(1))
		If SFC->(DbSeek(xFilial("SFC")+SF4->F4_CODIGO))		
			// Se houver utiliza base reduzida
			aImposto[_BASECALC] := aImposto[_BASECALC] * IIf(SFC->FC_BASE>0,SFC->FC_BASE / 100,1)
	   	Endif
	   	aImposto[_ALIQUOTA] := SFB->FB_ALIQ
		DbSelectArea("CCR")
		CCR->(DbSetOrder(1))
		If CCR->(DbSeek(xFilial("CCR")+SC6->C6_CONCEPT+SA1->A1_PAIS))
			aImposto[_ALIQUOTA] := CCR->CCR_ALIQ	
		ElseIf CCR->(DbSeek(xFilial("CCR")+SC6->C6_CONCEPT)) .And. Alltrim(CCR->CCR_PAIS)==""
			aImposto[_ALIQUOTA] := CCR->CCR_ALIQ								
		Endif
	   	
		aImposto[_IMPUESTO] := Round(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,MsDecimais(nMoeda))
		
	Endif	
	xRet:=aImposto	
Endif	
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  M460RIRVE ºAutor  ³Felipe C. Seolin     º Data ³  06/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao de IR (Imposto de Renda)                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Venezuela                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460RIRVE(cCalculo,nItem,aInfo)
	Local clAgente		:= GetMV("MV_AGENTE")
	Local nlRegSFB		:= 0
	Local nlBase		:= 0
	Local nlAliq		:= 0
	Local nlVRet		:= 0
	Local nlDesconto	:= 0
	Local nlMoeda		:= Iif(Type("nlMoedaCor") == "U",1,nlMoedaCor)
	Local llOk			:= .F.
	Local llRet			:= .T.
	
	Local cTipPer:='' 
	Local cGpoTri:=''
	Local cFilSFF:=xFilial("SFF")
	

	If cModulo $ "COM" .and. SubStr(clAgente,2,1) == "S"
		llOk := .T.
	EndIf

	If llOk
	    cTipPer:=SA2->A2_GRPTRIB  //Tipo de persona 
	    cGpoTri:=MaFisRet(nItem,"IT_CONCEPT") //Grupo tributario
		DBSelectArea("SFB")
		SFB->(DBSetOrder(1))
		If SFB->(DBSeek(xFilial("SFB") + aInfo[X_IMPOSTO]))
			If cCalculo == "B"
				nlRegSFB := SFB->(Recno())
				DBSelectArea("SFC")
				SFC->(DBSetOrder(2))
				If SFC->(DBSeek(xFilial("SFC") + MaFisRet(nItem,"IT_TES") + aInfo[X_IMPOSTO]))
					nlBase := MaFisRet(nItem,"IT_VALMERC")
					nlDesconto := MaFisRet(nItem,"IT_DESCONTO")
					nlBase -= nlDesconto
					
					DBSelectArea("SFF")
					SFF->(DBSetOrder(14))//FF_FILIAL+FF_IMPOSTO+FF_REGIAO+FF_GRPPRD+
					If SFF->(DBSeek(cFilSFF + SFB->FB_CODIGO + cTipPer+cGpoTri))
					    if nlBase > SFF->FF_IMPORTE
					     	nlBase:=nlBase* (SFF->FF_PERC/100)
					     else
					     	nlBase:=0	
						endif	
					EndIf
					
				EndIf
				SFB->(DBGoTo(nlRegSFB))
			ElseIf cCalculo == "A"
				nlAliq :=0
				nlRegSFB := SFB->(Recno())
				DBSelectArea("SFF")
				nlBase := MaFisRet(nItem,"IT_BASEIV" + aInfo[X_NUMIMP])
				if nlBase>0
					DBSelectArea("SFF")
					SFF->(DBSetOrder(14))//FF_FILIAL+FF_IMPOSTO+FF_REGIAO+FF_GRPPRD
					If SFF->(DBSeek(cFilSFF + SFB->FB_CODIGO + cTipPer +cGpoTri))
					     		nlAliq := SFF->FF_ALIQ
					EndIf
				endif	
				SFB->(DBGoTo(nlRegSFB))
			EndIf
		EndIf
		If llRet
			Do Case
				Case cCalculo == "A"
					nlVRet := nlAliq
				Case cCalculo == "B"
					nlVRet := nlBase
				Case cCalculo == "V"
					nlAliq := MaFisRet(nItem,"IT_ALIQIV" + aInfo[X_NUMIMP])
					nlBase := MaFisRet(nItem,"IT_BASEIV" + aInfo[X_NUMIMP])
					nlVRet := Round(nlBase * nlAliq / 100,MsDecimais(nlMoeda))
					nlVRet :=0
					if nlBase>0
						DBSelectArea("SFF")
						SFF->(DBSetOrder(14))//FF_FILIAL+FF_IMPOSTO+FF_REGIAO+FF_GRPPRD
						If SFF->(DBSeek(cFilSFF + SFB->FB_CODIGO + cTipPer +cGpoTri))
							nlVRet := Round(nlBase * (nlAliq / 100)-SFF->FF_EXCEDE,MsDecimais(nlMoeda))
						endif
					endif	
			EndCase
		EndIf
	EndIf
Return(nlVRet) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ M460RIRCR ³ Autor ³ Camila Januário     ³ Data ³ 18.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Calculo da Retencao de IR ( Imposto de Renda )              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Fiscal - Imposto IR - Costa Rica                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M460RIRCR(cCalculo,nItem,aInfo,lXFis)

Local aItem    := {}
Local xRet
Local cImp 	   := ""
Local cProduto := ""
Local lCalcRIR := .F.
Local cConcept := ""
Local nDecs := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica os decimais da moeda para arredondamento do valor  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1)) 


If !lXFis
	aItem    := ParamIxb[1]
	xRet     := ParamIxb[2]
	cImp     := xRet[1]
	cProduto := xRet[16]
   //	aImposto := ParamIxb[2]
Else
	xRet     := 0
	cProduto := MaFisRet(nItem,"IT_PRODUTO")
	cImp     := aInfo[X_IMPOSTO]
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ­
//³Verifica se calcula RIR e se tem conceito específico para o produto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ­

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+cProduto))
	cConcept := SB1->B1_CONRIR
	lCalcRIR := IIF(SB1->B1_CALCRIR=="1",.T.,.F.)
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a alíquota padrão da SFB³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SFB")
SFB->(dbSetOrder(1))
If SFB->(dbSeek(xFilial("SFB")+cImp))
	nAliq := SFB->FB_ALIQ
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a alíquota específica por conceito do produto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
dbSelectArea("CCR")
CCR->(dbSetOrder(1))
If CCR->(dbSeek(xFilial("CCR")+cConcept))		
	nAliq := CCR->CCR_ALIQ		
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se pode calcular o RIR³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lCalcRIR
	If !lXFis		                     
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco alíquota  e base de cálculo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 
		   xRet[02] := nAliq											// Aliquota
		   xRet[3] 	:= aItem[3]+aItem[4]+aItem[5]			// Base de Cálculo com frete e despesa

		   IF Subs(xRet[5],4,1) == "S"  .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
		      xRet[3] -= xRet[18]
		   ENDIF		   
		   
		   xRet[4] := xRet[2] * ( xRet[3]/100 )
		   xRet[04]:=Round(xRet[04],nDecs)	
		   
		   //xRet:=aImposto
		Else
		    Do Case    		  		    	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/¿
			//³Retorno A (alíquota), B (base) e V(valor)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/Ù		     
		       Case cCalculo=="B"
		            xRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		             //Tira os descontos se for pelo liquido
					dbSelectArea("SFC")
					SFC->(DbSetOrder(2))
					If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
						If SFC->FC_LIQUIDO=="S"
							xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
						Endif
					Endif					
               Case cCalculo=="A"		       				
		            xRet := nAliq			
		       Case cCalculo=="V"
					nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
					nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])  
					xRet:=(nAliq * nBase)/100
					xRet:=Round(xRet,nDecs)		
		    EndCase
		Endif    
EndIf
Return xRet
