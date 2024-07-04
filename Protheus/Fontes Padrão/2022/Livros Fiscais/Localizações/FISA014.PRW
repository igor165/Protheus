#INCLUDE "TopConn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA014.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FISA014   ³ Autor ³ Hermes Ferreira       ³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apuracao de impostos. Peru			    			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISA014()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Apuracao de impostos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³08/07/15³PCREQ-4256³Se elimina la funcion AjustaSX1() que ³±±
±±³            ³        ³          ³hace modificacion a SX1 por motivo de ³±±
±±³            ³        ³          ³adecuacion a fuentes a nuevas estruc- ³±±
±±³            ³        ³          ³turas SX para Version 12.             ³±±
±±³M.Camargo   ³09.11.15³PCREQ-4262³Merge sistemico v12.1.8		           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISA014()

	Local 	cxCadastro	:= STR0001 //"Apuração de impostos"
	Local 	aSays		:= {}
	Local 	aButtons	:= {}
	Local 	nxOpc		:= 0
	Local 	lPerg		:= .F.
	Local 	i,j            
	Private cPerg		:= "FISA014"
	// Variaveis da rotina de FINA050
	Private LF050AUTO
	Private laltera
	Private nOldValor 
                 
	
	aAdd(aSays,STR0002) //"Esta rotina tem a finalidade de efetuar a apuração dos impostos calculados pelo sistema:"
	aAdd(aSays,STR0003) //"Imposto Seletivo ao Consumo (ISC) e Imposto Geral sobre vendas (IGV)."
	aAdd(aSays,"")

	aAdd(aButtons,{5,.T.,{ || lPerg := Pergunte(cPerg,.T.) }})
	aAdd(aButtons,{1,.T.,{ || nxOpc := 1,FechaBatch()      }})
	aAdd(aButtons,{2,.T.,{ || nxOpc := 0,FechaBatch()      }})
	FormBatch(cxCadastro,aSays,aButtons)

	If nxOpc == 1
		If !lPerg
			lPerg := Pergunte(cPerg,.T.)
		Endif

		If lPerg
			ApuraImp()
		Endif
	Endif
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ApuraImp  ³ Autor ³ Hermes Ferreira       ³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apuracao de impostos, Construção da tela   			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ApuraImp()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Apuracao de impostos                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ApuraImp()
	Local	alImp		:= {STR0050,STR0051} // "ISC"###"IGV"
	Local 	alTipImp	:= {STR0004,STR0005} //"Imposto Seletivo de Consumo"###"Imposto Geral de Vendas"
	Local   alExtArq   	:= {"IS","IG"}
	Local   nlGetDOpc  	:= 2
	Local	nSldCrd		:= 0
	Local 	oScroll		:= NIL
	Local	oFont		:= TFont():New("Arial",,-11,,.T.)
	Local	lExclTit	:= .T.
	Local	llMonGet	:= .T.

	Private npIPMV		:= 0
	Private npIPMC		:= 0
	Private cpNomTxt   	:= "A"+GravaData(mv_par02,.F.,1)+GravaData(mv_par03,.F.,1)+cEmpAnt+cFilAnt+"."+alExtArq[mv_par01]
	Private cImpDesc 	:= alTipImp[MV_PAR01]
	Private aHeader		:= {}
	Private	apTabApu   	:= {}
	Private apAlter    	:= {"VALOR","OBSERV"}
	Private apTitulos  	:= {}

	aAdd(aHeader,{STR0006,"ITEM"	,"@!"						,03,2,"","","C","",""}) //"Item"
	aAdd(aHeader,{STR0007,"ITMAPUR"	,"@!"                		,40,2,"","","C","",""}) //"Item da Apuração"
	aAdd(aHeader,{STR0008,"VALOR" 	,"@R 999,999,999,999,999.99",12,2,"","","N","",""}) //"Valor"
	aAdd(aHeader,{STR0009,"OBSERV"	,"@!"						,50,0,"","","C","",""}) //"Observações"

   	If File(cpNomTxt)
		If ApMsgYesNo(STR0010) //"Este periodo ja foi apurado. Deseja refazer?"
			MsgRun(STR0011,,{|| lExclTit := ExTit() }) //"Cancelando apuração anterior..."
			If !lExclTit
				ApMsgStop(STR0012,STR0001) //"Apenas será possível excluir o título gerado e baixado anteriormente se for estornado."
				Return nil
			Endif
		Else
			llMonGet := .F.
			MsgRun(STR0013,,{|| ApTxt()}) //"Carregando apuração anterior..."
			nlGetDOpc := 0
		Endif
	EndIf

	If llMonGet
		aAdd(apTabApu,{STR0017,STR0018,																		,Space(20),.F.}) // "001"### "Saídas com Dédito de Imposto"
		aAdd(apTabApu,{STR0019,STR0020,nImpVen:=FQImpVen() 												,Space(20),.F.}) // "002"### "Imposto de Vendas"
		aAdd(apTabApu,{STR0021,STR0022,nRetenS:=FOutImpV("R")												,Space(20),.F.}) // "003"### "Retenções"
		aAdd(apTabApu,{STR0023,STR0024,nPercepS:=FOutImpV("P")												,Space(20),.F.}) // "004"### "Percepções"
		aAdd(apTabApu,{STR0025,STR0026,nOutroDeb:=0															,Space(20),.F.}) // "005"### "Outros Débitos (especificar)"
		aAdd(apTabApu,{STR0027,STR0028,nTotDI:=nImpVen-nRetenS-nPercepS+apTabApu[5][3]						,Space(20),.F.}) // "006"### "Total do Débito do Imposto"
		aAdd(apTabApu,{STR0029,STR0030, 																	,Space(20),.F.}) // "007"### "Entradas com Créditos de Imposto"
		aAdd(apTabApu,{STR0031,STR0032,nImpCom:=FQImpCom()													,Space(20),.F.}) // "008"### "Imposto nas Compras"
		aAdd(apTabApu,{STR0033,STR0034,nRetenC:=FRntPerC("R")												,Space(20),.F.}) // "009"### "Retenções"
		aAdd(apTabApu,{STR0035,STR0036,nPercepC:=FRntPerC("P")												,Space(20),.F.}) // "010"### "Percepções"
		aAdd(apTabApu,{STR0037,STR0038,nDetrac:= FOutImpV("D")												,Space(20),.F.}) // "011"### "Detrações"
		aAdd(apTabApu,{STR0039,STR0040,nCrdPerAnt:=FCrdant()												,Space(20),.F.}) // "012"### "Crédito do período anterior"
		aAdd(apTabApu,{STR0041,STR0042,nOutCrd:=0															,Space(20),.F.}) // "013"### "Outros Créditos (especificar)"
		aAdd(apTabApu,{STR0043,STR0044,nTotCI:=nImpCom+nRetenC+nPercepC+nDetrac+nCrdPerAnt+apTabApu[13][3],Space(20),.F.}) // "014"### "Total do Crédito do Imposto"
		aAdd(apTabApu,{STR0045,STR0046,nSldDev:= IIF(nTotDI>nTotCI,nSldDev:=nTotDI-nTotCI,nSldDev:=0)		,Space(20),.F.}) // "015"### "Saldo Devedor"
		aAdd(apTabApu,{STR0047,STR0048,nSldCrd:= IIF(nTotCI>nTotDI,nSldCrd:=nTotCI-nTotDI,nSldCrd:=0)		,Space(20),.F.}) // "016"### "Saldo Credor a Transportar"
	Endif

	Define MsDialog oDlgApur Title STR0001 From 000,000 TO 600,800 Pixel //"Apuração de impostos"

		@ 002,002 Folder oFolder Items alTipImp[mv_par01] Size 397,270 Pixel Of oDlgApur
		@ 005,005 Group oGrpImps To 195,392 Label STR0001 Of oFolder:aDialogs[1] Pixel 	//"Apuração de Impostos"

		@ 015,010 Say STR0049 Pixel Of oGrpImps //"Imposto apurado"
		@ 013,060 Combobox mv_par01 Items alImp When .F. Size 50,10 Of oGrpImps Pixel

		oGetDadosImp := MsNewGetDados():New(030,010,187,387,nlGetDOpc,"AllwaysTrue","AllWaysTrue",,apAlter,,Len(apTabApu),"FCmpOk(n)",,"AllWaysTrue",oGrpImps,aHeader,apTabApu)
		oGetDadosImp:LEDITLINE:= .F.

		@ 200,005 Group oGrpImps To 250,392 Label STR0016 Of oFolder:aDialogs[1] Pixel	//"Informações Complementares"
		@ 210,010 ScrollBox oScroll VERTICAL BORDER Size 35,377 Pixel Of oFolder:aDialogs[1]

		If MV_PAR01 == 2
			FValIPM()
			@ 005,010 Say STR0058 Pixel Of oScroll //"IPM Entradas"
			@ 005,090 Say Transform(npIPMC,"@R 999,999,999,999,999.99") Font oFont Pixel Of oScroll

			@ 020,010 Say STR0059 Pixel Of oScroll //"IPM Saídas"
			@ 020,090 Say Transform(npIPMV,"@R 999,999,999,999,999.99") Font oFont Pixel Of oScroll
		EndIf

		oBtn02 := SButton():New(280,330,1, {|| TXTFS014(),oDlgApur:End()	},,llMonGet)
		oBtn03 := SButton():New(280,360,2, {|| oDlgApur:End()         		},,.T.)

	Activate MsDialog oDlgApur Centered

Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FValIPM   ³ Autor ³ Hermes Ferreira       ³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Query para trazer o valor total do IPM do Periodo informado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FValIPM()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                     				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ IPM  			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FValIPM
	Local clQry		:= ""
	Local alTipo	:= {}
	Local n			:= 0
	Local nlNFV		:= 0
	Local nlNDC		:= 0
	Local nlNCC		:= 0
	Local nlNFC		:= 0
	Local nlNDI		:= 0
	Local nlNCI		:= 0	
	
	AADD(alTipo,"NF" )
	AADD(alTipo,"NDC")
	AADD(alTipo,"NCC") 
	AADD(alTipo,"NF" )
	AADD(alTipo,"NDI")
	AADD(alTipo,"NCI")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query por tipo movimento(Venda/Compra) e tipo de NF/NDC/NCC/NDI/NCI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	For n := 1 to Len(alTipo)
		
		clQry := ""
		clQry := "SELECT SUM(F3_VALIMP3) AS F3_VALIMP3"
		clQry += " FROM " +RetSqlName("SF3")+" SF3"
		
		clQry += " WHERE SF3.D_E_L_E_T_=' '"
		clQry += " AND F3_FILIAL = '"+xFilial("SF3")+"'"
		clQry += " AND F3_EMISSAO BETWEEN'"+dtos(mv_par02)+"' AND '"+dtos(mv_par03)+"'"
		clQry += " AND F3_VALIMP1 <> 0"	
		If n <= 3
			clQry += " AND F3_TIPOMOV = 'V' "
		Else
			clQry += " AND F3_TIPOMOV = 'C' "
		EndIf
		clQry += " AND F3_ESPECIE = '"+alTipo[n]+"'"
	
		TcQuery clQry New Alias "IPM"
		TCSetField("IPM","F3_VALIMP3" ,"N",14,2)
		
		If n == 1
			nlNFV := IPM->F3_VALIMP3
		ElseIf n == 2
			nlNDC := IPM->F3_VALIMP3
		ElseIf n == 3
			nlNCC := IPM->F3_VALIMP3
		ElseIf n == 4
			nlNFC := IPM->F3_VALIMP3
		ElseIf n == 5
			nlNDI := IPM->F3_VALIMP3
		ElseIf n == 6
			nlNCI := IPM->F3_VALIMP3
		EndIf		
		
		IPM->(dbCloseArea())
		
	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo do IPM de saída³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	npIPMV := nlNFV+nlNDC-nlNCC
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo do IPM de entrada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	npIPMC := nlNFC+nlNDI-nlNCI		

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQImpVen  ³ Autor ³ Hermes Ferreira       ³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Query para trazer o valor total dos Impostos de Vendas     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQImpVen()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nlImpvd - Valor total do imposto de venda                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos de Vendas                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FQImpVen
	Local cQuery	:= ""
	Local nlNF		:= 0
	Local nlNDC		:= 0
	Local nlNCC		:= 0
	Local nlImpvd	:= 0
	Local n			:= 0
	Local alTipo	:= {}
	
	AADD(alTipo,"NF" )
	AADD(alTipo,"NDC")
	AADD(alTipo,"NCC") 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query para separar o valor de Imposto de Vendas das NF/NDC/NCC³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	For n := 1 to len(alTipo)
	
		cQuery := ""
		cQuery := "SELECT "
		
		If MV_PAR01 == 1
			cQuery += "	SUM(F3_VALIMP2) AS VALOR"
		Else
			cQuery += "	SUM(F3_VALIMP1) AS VALOR"
		EndIf 
		
		cQuery	+= " FROM " +RetSqlName("SF3")+" SF3"
		
		cQuery	+= " WHERE SF3.D_E_L_E_T_=' '"
		cQuery	+= " AND F3_FILIAL = '"+xFilial("SF3")+"'"
		cQuery	+= " AND F3_EMISSAO BETWEEN'"+dtos(mv_par02)+"' AND '"+dtos(mv_par03)+"'"
		cQuery	+= " AND F3_TIPOMOV = 'V'
		cQuery  += " AND F3_ESPECIE = '"+alTipo[n]+"'"
		If MV_PAR01 == 1 // ISC
			cQuery	+= " AND F3_VALIMP2 > 0"
		Else 			 // IGV
			cQuery	+= " AND F3_VALIMP1 > 0"
		EndIf
	
		TcQuery cQuery New Alias "IMPVD"
		TCSetField("IMPVD","VALOR","N",14,2)

		If n == 1
			nlNF	:= IMPVD->VALOR
		ElseIf n == 2
			nlNDC	:= IMPVD->VALOR
		ElseIf n == 3
			nlNCC	:= IMPVD->VALOR
		EndIf
		
		IMPVD->(dbCloseArea())
		
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo do Imposto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nlImpvd:= nlNF+nlNDC-nlNCC	
	
Return nlImpvd

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FOutImpV  ³ Autor ³ Hermes Ferreira       ³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Query para trazer o valor total dos Impostos, com Retenção,³±±
±±³ 		 | Percepção, Detração - Tipo de movimento de vendas		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FOutImpV(tpImp)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ tpImp - tipo de imposto a ser calculado					  ³±±
±±³ 		 | 			R - Retenção de vendas                            ³±±
±±³ 		 | 			P - Percepção de vendas                           ³±±
±±³ 		 | 			D - Detração                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nlOutImp - Valor total do imposto   	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FOutImpV(tpImp)
	Local cQuery	:= ""
	Local clWhre	:= ""
	Local nlNF		:= 0
	Local nlNDC		:= 0
	Local nlNCC		:= 0
	Local nlOutImp	:= 0
	Local n			:= 0
	Local alTipo	:= {}
	
	AADD(alTipo,"NF" )
	AADD(alTipo,"NDC")
	AADD(alTipo,"NCC")	

	If MV_PAR01 == 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Condicao para as Querys ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If tpImp == "R"
			clWhre := "SELECT DISTINCT "
			clWhre += " F3_NFISCAL,"
			clWhre += " F3_SERIE,"
			clWhre += " F3_CLIEFOR,"
			clWhre += " F3_LOJA "
			clWhre += " FROM " +RetSqlName("SF3")+" SF3"

			clWhre += " JOIN " +RetSqlName("SE1")+" SE1"
			clWhre += " ON SE1.D_E_L_E_T_ = ' ' "
			clWhre += " AND E1_FILIAL	= '"+xFilial("SE1")+"'"	
			clWhre += " AND E1_NUM 		= F3_NFISCAL "
			clWhre += " AND E1_PREFIXO	= F3_SERIE "
			clWhre += " AND E1_CLIENTE	= F3_CLIEFOR "
			clWhre += " AND E1_LOJA		= F3_LOJA "

			clWhre += " JOIN " +RetSqlName("SA1")+" SA1"
			clWhre += " ON SA1.D_E_L_E_T_ = ' '"
			clWhre += " AND A1_FILIAL	= '"+xFilial("SA1")+"'"	
			clWhre += " AND A1_COD 		= F3_CLIEFOR"
			clWhre += " AND A1_LOJA		= F3_LOJA"
			clWhre += " AND A1_AGENRET	= '1'"			
		EndIf

		clWhre += " WHERE SF3.D_E_L_E_T_=' '"
		clWhre += " AND F3_FILIAL =  '"+xFilial("SF3")+"'"
		clWhre += " AND F3_EMISSAO BETWEEN'"+dtos(mv_par02)+"' AND '"+dtos(mv_par03)+"'"
		clWhre += " AND F3_TIPOMOV = 'V'"
		If tpImp == "P"		// Percepcao
			clWhre += " AND F3_VALIMP1 > 0 "
			clWhre += " AND F3_VALIMP4 > 0 "

		ElseIf tpImp == "D"	// Detracao
			clWhre += " AND F3_VALIMP5 > 0 " 

		ElseIf tpImp == "R"	// Retencao
			clWhre += " AND F3_VALIMP1 > 0 " 
		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o tipo (Retenção, Percepção ou Detração)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If tpImp == "R"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Query para separar o valor de Retenção de Saida das NF/NCC/CDC³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
  			n:=0
  			For n := 1 to Len(alTipo)
  			
				cQuery := " "
				cQuery += clWhre
				cQuery += "	 AND F3_ESPECIE = '"+alTipo[n]+"' "
	
				If Select("OUTIMP")>0	  
					DbSelectARea("OUTIMP")
					OUTIMP->(DbCloseArea())
				Endif                   
				TcQuery cQuery New Alias "OUTIMP"

				If n == 1
					nlNF	:= FRntRslQ()
				ElseIf n == 2
					nlNDC	:= FRntRslQ()
				ElseIf n == 3
					nlNCC	:= FRntRslQ()
				EndIf
				OUTIMP->(dbCloseArea())
				
			Next


		ElseIf tpImp == "P"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Query para separar o valor de Percepção de Saida das NF/NCC/NDC³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			
			n:=0
			For n:= 1 to len (alTipo)
				cQuery := " SELECT COALESCE(SUM(F3_VALIMP4),0) AS VALOR  "
				cQuery += " FROM " +RetSqlName("SF3")+" SF3 "
				cQuery += clWhre
				cQuery += "	 AND F3_ESPECIE = '"+alTipo[n]+"' "
				If Select("OUTIMP")>0	  
					DbSelectARea("OUTIMP")
					OUTIMP->(DbCloseArea())
				Endif                   
	
				TcQuery cQuery New Alias "OUTIMP"
				TCSetField("OUTIMP","VALOR" ,"N",14,2)
				
				If n == 1
					nlNF	:= OUTIMP->VALOR
				Elseif n == 2
					nlNDC	:= OUTIMP->VALOR
				Elseif n == 3
					nlNCC	:= OUTIMP->VALOR
				EndIf

				OUTIMP->(dbCloseArea())
				
			Next


		ElseIf tpImp == "D"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Query para separar o valor de Detração das NF³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			n:=0
			For n:= 1 to len (alTipo)
						
				cQuery := " SELECT COALESCE(SUM(F3_VALIMP5),0) AS VALOR  "
				cQuery += " FROM " +RetSqlName("SF3")+" SF3 "
				cQuery += clWhre
				cQuery += " AND F3_ESPECIE = '"+alTipo[n]+"' " 
	
				If Select("OUTIMP")>0	  
					DbSelectARea("OUTIMP")
					OUTIMP->(DbCloseArea())
				Endif                   
	
				TcQuery cQuery New Alias "OUTIMP"
				TCSetField("OUTIMP","VALOR" ,"N",14,2)

				If n == 1
					nlNF	:= OUTIMP->VALOR
				Elseif n == 2
					nlNDC	:= OUTIMP->VALOR
				Elseif n == 3
					nlNCC	:= OUTIMP->VALOR
				EndIf
				OUTIMP->(dbCloseArea())
				
			Next
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo do Imposto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nlOutImp:= nlNF+nlNDC-nlNCC
	EndIf
Return nlOutImp

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FRntRslQ  ³ Autor ³ Hermes Ferreira       ³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Soma o valor da retenção proporcioanl as parcelas baixadas.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FRntRslQ			                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nlVal - Valor total da retenção   	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Retençao de vendas                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRntRslQ
	Local nlVal		:= 0

nlVal:= 0

dbSelectArea("OUTIMP")
OUTIMP->(DbGoTop())
Do While OUTIMP->(!EOF())
	DbSelectArea("SFE")
	SFE->(DbSetOrder(8))//FE_FILIAL+FE_CLIENTE+FE_LOJCLI+FE_NFISCAL+FE_SERIE
	SFE->(DbGoTop())   
	If DbSeek(xFilial("SFE")+AvKey(OUTIMP->F3_CLIEFOR,"FE_CLIENTE")+AvKey(OUTIMP->F3_LOJA,"FE_LOJCLI")+AvKey(OUTIMP->F3_NFISCAL,"FE_NFISCAL");
	+AvKey(OUTIMP->F3_SERIE,"FE_SERIE"))
		Do While SFE->FE_CLIENTE==OUTIMP->F3_CLIEFOR .AND. SFE->FE_LOJCLI==OUTIMP->F3_LOJA .AND. SFE->FE_NFISCAL==OUTIMP->F3_NFISCAL .AND. SFE->FE_SERIE==OUTIMP->F3_SERIE 
			nlVal+= SFE->FE_RETENC
			
			SFE->(DbSkip())
		End
	Endif
	OUTIMP->(DbSkip())	
End	        
Return nlVal
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQImpCom  ³ Autor ³ Hermes Ferreira       ³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Query para trazer o valor total dos Impostos de Compra     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQImpCom()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum       	         								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nlImpCm - Valor total dos impostos de compra               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos de Compra                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FQImpCom()
	Local cQuery	:= ""
	Local nlNF		:= 0
	Local nlNDI		:= 0
	Local nlNCI		:= 0
	Local n			:= 0
	Local alTipo	:= {}
	
	AADD(alTipo,"NF" )
	AADD(alTipo,"NDI")
	AADD(alTipo,"NCI")		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query para separar o valor de Imposto de Compras das NF/NDI/NCI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	For n:= 1 to Len(alTipo)
	
		cQuery := ""
		cQuery := "SELECT "
		
		If MV_PAR01 == 2
			cQuery += "	SUM(F3_VALIMP1) AS VALOR "
		Else
			cQuery += "	SUM(F3_VALIMP2) AS VALOR "
		EndIf
			
		cQuery	+= " FROM " +RetSqlName("SF3")+" SF3"
		
		If MV_PAR01 == 2 // IGV
			cQuery	+= " JOIN " +RetSqlName("SF4")+" SF4"
			cQuery	+= " ON SF4.D_E_L_E_T_ = ' '"
			cQuery	+= " AND F4_FILIAL = '"+xFilial("SF4")+"'"
			cQuery	+= " AND F4_CODIGO = F3_TES"
			cQuery	+= " AND F4_CREDIGV <> '2'"
		EndIf 
		
		cQuery	+= " WHERE SF3.D_E_L_E_T_=' '"
		cQuery	+= " AND F3_FILIAL = '"+xFilial("SF3")+"'"
		cQuery	+= " AND F3_EMISSAO BETWEEN'"+dtos(mv_par02)+"' AND '"+dtos(mv_par03)+"'"
		cQuery	+= " AND F3_TIPOMOV = 'C' "
		cQuery  += " AND F3_ESPECIE = '"+alTipo[n]+"' "
				
		If MV_PAR01 == 1 // ISC
			cQuery	+= " AND F3_VALIMP2 > 0 "
		Else 			 // IGV
			cQuery	+= " AND F3_VALIMP1 > 0 "
		EndIf

		TcQuery cQuery New Alias "IMPCM"
	    TCSetField("IMPCM","VALOR"  ,"N",14,2)
	    
	    If n == 1
			nlNF	:= IMPCM->VALOR
		ElseIf n == 2
			nlNDI	:= IMPCM->VALOR
		ElseIf n == 3
			nlNCI	:= IMPCM->VALOR
		EndIf
		IMPCM->(dbCloseArea())
		
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo do Imposto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nlImpCm:= nlNF+nlNDI-nlNCI
	
Return nlImpCm

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FRntPerC  ³ Autor ³ Hermes Ferreira       ³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Query para trazer o valor total dos Impostos, com Retenção,³±±
±±³ 		 | Percepção - Movimento de compras							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FRntPerC(tpImp)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ tpImp - tipo de imposto a ser calculado					  ³±±
±±³ 		 | 			R - Retenção de vendas                            ³±±
±±³ 		 | 			P - Percepção de vendas                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nlImRp - Valor total do imposto   	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRntPerC(tpImp)
	Local cQuery	:= ""
	Local nlImRp	:= 0
	Local nlNF		:= 0
	Local nlNDI		:= 0
	Local nlNCI		:= 0
	Local n			:= 0
	Local alTipo	:= {}
	
	AADD(alTipo,"NF" )
	AADD(alTipo,"NDI")
	AADD(alTipo,"NCI")
	
	
	If MV_PAR01 == 2 // IGV

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Query para separar o valor de Retenção/percepçãp das NF/NDI/NCI ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		For n:= 1 to len(alTipo)
		
			If tpImp == "R" // Retencao
				cQuery := "SELECT SUM(FE_RETENC) AS VALOR "
			Else			// Percepcao
				cQuery := "SELECT SUM(FE_VALIMP) AS VALOR "
			EndIf
			
			cQuery += " FROM " +RetSqlName("SFE")+" SFE "
			
			cQuery += " JOIN " +RetSqlName("SF3")+" SF3 "
			cQuery += " ON SF3.D_E_L_E_T_= ' '"
			cQuery += " AND F3_FILIAL	= '"+xFilial("SF3")+"'"		
			cQuery += " AND F3_NFISCAL	= FE_NFISCAL "
			cQuery += " AND F3_SERIE	= FE_SERIE "
			cQuery += " AND F3_CLIEFOR	= FE_FORNECE "
			cQuery += " AND F3_LOJA 	= FE_LOJA "
			cQuery += " AND F3_TIPOMOV	= 'C' "			
			cQuery += " AND F3_ESPECIE = '"+alTipo[n]+"' "
			
			cQuery += " WHERE SFE.D_E_L_E_T_=' ' "
			cQuery += "	AND FE_FILIAL = '"+xFilial("SFE")+" ' "
			cQuery += "	AND FE_EMISSAO BETWEEN'"+dtos(mv_par02)+"' AND '"+dtos(mv_par03)+"'"

			If tpImp == "R" // Retenção
				cQuery += " AND FE_TIPO = 'I'"
			Else			// Percepção
				cQuery += " AND FE_TIPO = 'P'"
			EndIf			
	
			TcQuery cQuery New Alias "IMPRP"
			TCSetField("IMPRP","VALOR" ,"N",14,2)
			
	        If n == 1
				nlNF	:= IMPRP->VALOR
			ElseIf n == 2
				nlNDI	:= IMPRP->VALOR
			ElseIf n == 3
				nlNCI	:= IMPRP->VALOR
			EndIf
			IMPRP->(dbCloseArea())
			
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo do Imposto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nlImRp:= nlNF+nlNDI-nlNCI
	EndIf
Return nlImRp

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FCrdant   ³ Autor ³ Hermes Ferreira       ³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que busca o Saldo credor do Periodo anterior indica-³±±
±±³ 		 | do no paramentro MV_par06	 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FCrdant			                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nlSldCred - Saldo do Credito anterior                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FCrdant	
	Local cBuffer	:= ""
	Local nlSldCred	:= 0

	FT_FUSE(MV_PAR06)
	FT_FGOTOP()
	If File(MV_PAR06)
		While !FT_FEOF()
			cBuffer := FT_FREADLN()
			If Substr(cBuffer,009,03) == "016"	// Saldo Credor a Transportar
				nlSldCred := RemPict(Substr(cBuffer,072,22))  // valor da linha
				Exit
			EndIf
			FT_FSKIP()
		EndDo
	EndIf
	FT_FUSE()	
Return nlSldCred

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FCmpOk    ³ Autor ³ Hermes Ferreira       ³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação dos campos Outros Debitos/Creditos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FCmpOk(n)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ n - Linha do aCols         								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ llRet - Retorna True/False                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Alteração do valor dos campos                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FCmpOk(n)
	Local llRet	:= .T.
	Local cEditVar := ReadVar()

	If cEditVar == "M->VALOR"
		If n == 5 .or. n == 12 .or. n == 13
			llRet := .T.
			If M->VALOR < 0
				llRet := .F.
				Aviso(STR0052,STR0053,{STR0055}) // Atenção ### "O valor não pode ser negativo" ### "Ok"
			Else
				Do case
					Case n == 5 
						nTotDI:=nImpVen-nRetenS-nPercepS+M->VALOR
						oGetDadosImp:aCols[6][3]:=nTotDI 
					Case n == 12
						nTotCI:=nImpCom+nRetenC+nPercepC+nDetrac+M->VALOR+oGetDadosImp:aCols[13][3]
						oGetDadosImp:aCols[14][3]:=nTotCI
					Case n == 13
						nTotCI:=nImpCom+nRetenC+nPercepC+nDetrac+oGetDadosImp:aCols[12][3]+M->VALOR
						oGetDadosImp:aCols[14][3]:=nTotCI
				EndCase

				If nTotDI>nTotCI
					nSldDev:= nTotDI-nTotCI
					nSldCrd := 0
				Else
					nSldDev := 0
					nSldCrd:= nTotCI-nTotDI
				EndIf

				oGetDadosImp:aCols[15][3] := nSldDev
				oGetDadosImp:aCols[16][3] := nSldCrd
				oGetDadosImp:Refresh()
			EndIf
		Else
			Aviso(STR0052,STR0054,{STR0055})// Atenção ### "O valor deste campo não pode ser alterado" ### "Ok"
			M->VALOR:= oGetDadosImp:aCols[n][3]
		EndIf
	Else
		oGetDadosImp:aCols[n][4] := M->OBSERV
		oGetDadosImp:Refresh()
	EndIf

Return (llRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TXTFS014  ³ Autor ³ Hermes Ferreira       ³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o titulo a pagar para o Governo e o TXT 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TXTFS014()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum								  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum										              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ titulo				                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TXTFS014
	If mv_par05 = 1
		MsgRun(STR0056,,{|| IIf(nSldDev>0,apTitulos := GrvTitLoc(nSldDev),Nil) }) //"Gerando titulo de apuração..."
	Endif

	If mv_par05 == 1 .and. Len(apTitulos) <= 0
		Return nil
	Endif

	CriarArq()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CriarArq  ³ Autor ³ Hermes Ferreira       ³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o arquivo TXT com os valores que constam na getdados  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CriarArq 		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum								  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum										              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TXT  				                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriarArq
	Local cCRLF		:= Chr(13)+Chr(10)
	Local nHdl		:= 0
	Local nlCont	:= 0
	Local cLinha	:= ""

	nHdl := fCreate(cpNomTxt)
	If nHdl <= 0
		ApMsgStop(STR0057) // "Ocorreu um erro ao criar o arquivo"
	Endif  

	nlCont := 0
	For nlCont := 1 to Len(oGetDadosImp:aCols)
		cLinha := "IPM"									 								+ Space(5) // Clausula que indica a linha
		cLinha += oGetDadosImp:aCols[nlCont][1]			 								+ Space(5) // Codigo de linha 
		cLinha += Padr(oGetDadosImp:aCols[nlCont][2],50)								+ Space(5) // Descrição da linha
		cLinha += Transform(oGetDadosImp:aCols[nlCont][3],"@R 999,999,999,999,999.99")	+ Space(5) // Valor da linha
		cLinha += Padr(oGetDadosImp:aCols[nlCont][4],50)                              	+ Space(5) // Observação da linha

		cLinha += cCRLF
		fWrite(nHdl,cLinha)
	Next nlCont

	If MV_PAR01 == 2
		cLinha := "INF"											+ Space(5) // Clausula que indica o tipo de linha
		cLinha += Padr(STR0058,50)								+ Space(5) // "IPM Entradas"
		cLinha += Transform(npIPMC,"@R 999,999,999,999,999.99")	+ Space(5) // Valor do IPM de Entrada
		cLinha += cCRLF
		fWrite(nHdl,cLinha)

		cLinha := "INF"											+ Space(5) // Clausula que indica o tipo de linha
		cLinha += Padr(STR0059,50)								+ Space(5) // "IPM Saídas"
		cLinha += Transform(npIPMV,"@R 999,999,999,999,999.99")	+ Space(5) // Valor do IPM de Saída
		cLinha += cCRLF		

		fWrite(nHdl,cLinha)	
	EndIf

	If Len(apTitulos) > 0
		cLinha := "TIT"													+ Space(5) // Clausula que indica o tipo de linha
		cLinha += Padr(apTitulos[1],10)									+ Space(5) // Prefixo
		cLinha += Padr(apTitulos[2],20)									+ Space(5) // Numero
		cLinha += Padr(apTitulos[3],5)									+ Space(5) // Parcela
		cLinha += Padr(apTitulos[4],5)									+ Space(5) // Tipo
		cLinha += Padr(apTitulos[5],10)									+ Space(5) // Fornecedor
		cLinha += Padr(apTitulos[6],5)									+ Space(5) // Loja
//		cLinha += Transform(apTitulos[7],"@e 999,999,999,999,999.99")	+ Space(5) // Moeda
		cLinha += Transform(apTitulos[8],"@e 999,999,999,999,999.99")	+ Space(5) // Valor do Imposto
		cLinha += cCRLF
		fWrite(nHdl,cLinha)
	Endif
	If nHdl > 0
		fClose(nHdl)
	Endif
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ApTxt     ³ Autor ³ Hermes Ferreira       ³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Abre o arquivo TXT, e preenche os valores na getdados	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ApTxt     		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum								  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum										              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ler o TXT			                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ApTxt
	Local cBuffer := ""
	Local aGrava  := {}

	FT_FUSE(cpNomTxt)
	FT_FGOTOP()
	While !FT_FEOF()
		cBuffer := FT_FREADLN()
		aGrava  := {}
		If Substr(cBuffer,1,3) = "IPM"
			aAdd(apTabApu,{	Substr(cBuffer,009,03) 			,; 	// Codigo da linha
							Substr(cBuffer,017,50) 			,; 	// Descricao da linha
							RemPict(Substr(cBuffer,072,22)),;	// valor da linha
							Substr(cBuffer,099,50) 			,; 	// Observações da linha	
							.F.	})
		EndIf
		FT_FSKIP()
	EndDo
	FT_FUSE()
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RemPict   ³ Autor ³ Hermes Ferreira       ³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Altera o formato do numero								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RemPict(cVar)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cVar - conteudo a ser alterado (String)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Val(cVar) - Retorna o valor					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ StrTran				                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RemPict(cVar)
	cVar := StrTran(cVar,",","")
Return Val(cVar)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ExTit     ³ Autor ³ Hermes Ferreira       ³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Excluir o titulo de apuração para o governo,no financeiro  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExTit     		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum								  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet- Se .T. Foi excluido. Se .F. não foi possivel excluir ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ler o TXT			                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Static Function ExTit()
	Local   lRet        := .T.
	Local   cBuffer     := ""
	Local   aDadosSE2   := {}
	Private lMsErroAuto := .F.

	FT_FUSE(cpNomTxt)
	FT_FGOTOP()
	Do While !FT_FEOF()
		cBuffer := FT_FREADLN()
		If Substr(cBuffer,1,3) = "TIT"
			aAdd(aDadosSE2,{"E2_FILIAL" ,xFilial("SE2"),nil})
			aAdd(aDadosSE2,{"E2_PREFIXO",Substr(cBuffer,09,TamSX3("E2_PREFIXO")[1])	,nil})
			aAdd(aDadosSE2,{"E2_NUM"    ,Substr(cBuffer,24,TamSX3("E2_NUM")[1])		,nil})
			aAdd(aDadosSE2,{"E2_PARCELA",Substr(cBuffer,49,TamSX3("E2_PARCELA")[1])	,nil})
			aAdd(aDadosSE2,{"E2_TIPO"   ,Substr(cBuffer,59,TamSX3("E2_TIPO")[1])		,nil})
			aAdd(aDadosSE2,{"E2_FORNECE",Substr(cBuffer,69,TamSX3("E2_FORNECE")[1])	,nil})
			aAdd(aDadosSE2,{"E2_LOJA"   ,Substr(cBuffer,84,TamSX3("E2_LOJA")[1])		,nil})

			MsExecAuto({|x,y,z| FINA050(x,y,z)},aDadosSE2,,5)
			If lMsErroAuto
       			MostraErro()
       			lRet := .F.
	  		Endif
   			Exit                          
		Endif
		FT_FSKIP()
	EndDo
	FT_FUSE()

	If lRet
		fErase(cpNomTxt)
	Endif
Return lRet
