#INCLUDE "PCOC380.ch"
#include "protheus.ch"
#include "msgraphi.ch"
#Define CAMPO_USUARIO "[CPOUSR"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOC380   บAutor  ณPaulo Carnelossi    บ Data ณ  18/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta de Saldos e Projecoes por Periodos-Visao Ger./Cubo บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PCOC380(nCallOpcx)

Local bBlock
Local nPos
SaveInter()
Private cCadastro	:= STR0001 //"Consulta de Saldos e Projecoes por Periodos - Visoes"
Private aRotina := MenuDef()
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Adiciona botoes do usuario no Browse                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PCOC3801" )
		//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ณ
		//P_Eณ browse da tela de Centros Orcamentarios                                            ณ
		//P_Eณ Parametros : Nenhum                                                    ณ
		//P_Eณ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ณ
		//P_Eณ               Ex. :  User Function PCOC3801                            ณ
		//P_Eณ                      Return {{"Titulo", {|| U_Teste() } }}             ณ
		//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ValType( aUsRotina := ExecBlock( "PCOC3801", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf

	If nCallOpcx <> Nil
		nPos := Ascan(aRotina,{|x| x[4]== nCallOpcx})
		If ( nPos # 0 )
			bBlock := &( "{ |x,y,z,k,w,a,b,c,d,e,f,g| " + aRotina[ nPos,2 ] + "(x,y,z,k,w,a,b,c,d,e,f,g) }" )
			Eval( bBlock,Alias(),AKN->(Recno()),nPos)
		EndIf
	Else
		mBrowse(6,1,22,75,"AKN")
	EndIf
EndIf
RestInter()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPco380View บAutor  ณPaulo Carnelossi   บ Data ณ  18/01/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta de Saldos e Projecoes por Periodos-Visao Ger./Cubo บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Pco380View(cAlias,nRecno,nOpcx)
Local lRet := .F.
Local aProcessa, aProcComp
Local nTpGraph
Local nX

Local dIni := dDataBase
Local dFim := dDataBase+20
Local dRef := dDataBase

Local nTpPer	:= 3
Local nDetalhe
Local aListArq := {}
Local aTpGrafico:= {STR0004,;  //"1=Linha"
					STR0005,;  //"2=Area"
					STR0006,;  //"3=Pontos"
					STR0007,;  //"4=Barra"
					STR0008  ,;  //"5=Piramide"
					STR0009,;  //"6=Cilindro"
					STR0010,;  //"7=Barra Horizontal"
					STR0011,;  //"8=Piramide Horizontal"
					STR0012,;  //"9=Cilindro Horizontal"
					STR0013,;  //"10=Pizza"
					STR0014,;  //"11=Forma"
					STR0015,;  //"12=Linha Rapida"
					STR0016,;  //"13=Flechas"
					STR0017,;  //"14=Gantt"
					STR0018 }  //"15=Bolha"

Private aConfig := {}

Private aPrcSldIni := {}
Private nProcCubo := 1

Private aPeriodo
Private aColTitle, aColunas
Private aCpoSel := {}, aCpoUsr := {}
Private COD_CUBO  := AL1->AL1_CONFIG
Private cPicture := PadR("@E 999,999,999,999.99",25)
Private aTotLin
Private aPerLin
Private nPeriodo

dbSelectArea("AKL")
dbSetOrder(1)
If MsSeek(xFilial("AKL")+AKN->AKN_CONFIG) .And. Empty(AKL->AKL_CUBE)        
	Aviso(STR0019,STR0020,{"Ok"},2)   //"Visao nao compativel"###"A Visao selecionada nao possui nenhum cubo relacionado. Apenas as Visoes com cubos relacionados poderao ser utilizadas nesta consulta. Verifique a Visao selecionada."
	Return
EndIf

COD_CUBO  := AKL->AKL_CUBE

If ParamBox({ 		{ 1 ,STR0021,dIni,"" 	 ,""  ,""    ,"" ,50 ,.F. },;  //"Periodo de"
					{ 1 ,STR0022,dFim,"" 	 ,""  ,""    ,"" ,50 ,.F. },;  //"Periodo Ate"
					{ 2 ,STR0023,nTpPer,{STR0024,STR0025,STR0026,STR0027,STR0028,STR0062},80,"",.F.},;  //"Tipo Periodo" //"1=Semanal"###"2=Quinzenal"###"3=Mensal"###"4=Bimestral"###"5=Semestral" //"6=Anual"
					{ 2 ,STR0029,1,{STR0030,STR0031,STR0032,STR0033,STR0034},80,"",.F.},;  //"Moeda"###"1=Moeda 1"###"2=Moeda 2"###"3=Moeda 3"###"4=Moeda 4"###"5=Moeda 5"
					{ 2 ,STR0035,4,aTpGrafico,80,"",.F.},;  //"Tipo do Grafico"
					{ 1 ,STR0036,dRef,"" 	 ,""  ,""    ,"" ,50 ,.F. },;  //"Data de Referencia"
					{ 1  ,STR0037+"-1",Space(LEN(AL3->AL3_CODIGO))		  ,"@!" 	 ,''  ,"AL3" ,"" ,25 ,.F. },;  //"Config.Cubo Serie"
					{ 3 ,STR0038,1,{STR0039,STR0040},40,,.F.},;  //"Exibe Configura็๕es"###"Sim"###"Nao"
					{ 1  ,STR0041,STR0042+"-1","@!" 	 ,""  ,"" ,"" ,75 ,.F. },; //"Descri็ใo S้rie"###"Serie "
					{ 3 ,STR0043,1,{STR0044,STR0045},95,,.F.},;  //"Considerar "###"Saldo final do periodo"###"Movimento do periodo"
					{ 1  ,STR0037+"-2",Space(LEN(AL3->AL3_CODIGO))		  ,"@!" 	 ,''  ,"AL3" ,"" ,25 ,.F. },;  //"Config.Cubo Serie"
					{ 3 ,STR0038,1,{STR0039,STR0040},40,,.F.},;  //"Exibe Configura็๕es"###"Sim"###"Nao"
					{ 1  ,STR0041,STR0042+"-2","@!" 	 ,""  ,"" ,"" ,75 ,.F. },; //"Descri็ใo S้rie"###"Serie "
					{ 3 ,STR0043,1,{STR0044,STR0045},95,,.F.},;  //"Considerar "###"Saldo final do periodo"###"Movimento do periodo"
					{ 2,STR0046,2,{"1="+STR0039,"2="+STR0040},80,"",.F.},; //"Detalhar Cubos"###"Sim"###"Nao"
					{ 3,STR0047,2,{STR0048,STR0049,STR0050},40,,.F.},;  //"Mostrar valores"###"Unidade"###"Milhar"###"Milhao"
					{ 2,STR0051,2,{"1="+STR0039,"2="+STR0040},80,"",.F.},; //"Totaliza Linha"###"Sim"###"Nao"
					{ 2,STR0052,2,{"1="+STR0039,"2="+STR0040},80,"",.F.},; //"Perc.Ref.Total"###"Sim"###"Nao"
					{ 2,STR0053,2,{STR0054,STR0055, STR0056, STR0057, STR0152},130,"",.F.},; //"Cenario/Projecao"###"1=Nenhum"###"2=Manter Tendencia"###"3=Recuperar Orcamento ate final do periodo"###"4=Ajustar ao Orcamento a Partir Data Referencia"###"5=Tendencia pela Media"
					{ 2,STR0058,1,{"1="+STR0039,"2="+STR0040},80,"",.F.},; //"Recuperar e Gravar Configuracao da Consulta"###"Sim"###"Nao"
					{ 1,"Picture",cPicture,"@!" 	 ,""  ,"" ,"" ,75 ,.F. };
			},STR0059,aConfig,,,,,,, "PCOC380_01",,.T.)  //"Parametros"
	aConfig[03]  := If(ValType(aConfig[03])=="N", aConfig[03], Val(aConfig[03]))
	aConfig[04]  := If(ValType(aConfig[04])=="N", aConfig[04], Val(aConfig[04]))
	aConfig[05]  := If(ValType(aConfig[05])=="N", aConfig[05], Val(aConfig[05]))
	
	nDetalhe  := If(ValType(aConfig[15])=="N", aConfig[15], Val(aConfig[15]))
	aConfig[15]  := If(ValType(aConfig[15])=="N", aConfig[15], Val(aConfig[15]))
	aConfig[17]  := If(ValType(aConfig[17])=="N", aConfig[17], Val(aConfig[17]))
	aConfig[18]  := If(ValType(aConfig[18])=="N", aConfig[18], Val(aConfig[18]))
	aConfig[19]  := If(ValType(aConfig[19])=="N", aConfig[19], Val(aConfig[19]))
	aConfig[20]  := If(ValType(aConfig[20])=="N", aConfig[20], Val(aConfig[20]))
	nCasas	 := aConfig[16]
	cPicture := AllTrim(aConfig[21])
	If Empty(aConfig[1])
		aConfig[1] := CtoD("01/01/"+Str(Year(dDataBase),4))
	EndIf
	lRet := .T.
	
	//nao retirar (serve para gravar corretamente os MV_PAR?? da Parambox - referente campos combo modificados)
	aEval(aConfig, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
	ParamSave(__cUserID+"_PCOC380_01",aConfig,"1")
	
EndIf

If lRet
	nTpPer := If(ValType(aConfig[3])=="N", aConfig[3], Val(aConfig[3]))
	aPeriodo := PcoRetPer(aConfig[1]/*dIniPer*/, aConfig[2]/*dFimPer*/, Str(nTpPer,1)/*cTipoPer*/, .F./*lAcumul*/)

	lRet := C380Refer(aPeriodo, aConfig[6], @nPeriodo)

	If ! lRet  //se nao encontrou periodo de referencia
		Aviso(STR0060, STR0061, {"Ok"}) //"Atencao"###"Data de referencia deve pertencer ao periodo informado. Verifique!"
		Return
	EndIf
	
	// sao sempre 2 series
	aAdd(aPrcSldIni, aConfig[10])
	aAdd(aPrcSldIni, aConfig[14])

	//processa primeira configuracao do cubo sempre
	aProcessa := PcoCubeVis(AKN->AKN_CODIGO,Len(aPeriodo),"Pcoc380Sld",aConfig[7],aConfig[8],nDetalhe)

   	If Len(aProcessa) > 0
	   	//processa a  segunda configuracao
	   	nProcCubo := 2
		aProcComp := PcoCubeVis(AKN->AKN_CODIGO,Len(aPeriodo),"Pcoc380Sld",aConfig[11],aConfig[12],nDetalhe)
		aColunas := {}
		aAdd(aColunas, { "SA[Codigo]", "aView[nLin,  1]", "aView[nLin,  1]" } )
		aAdd(aColunas, { "SB[Descricao]", "aView[nLin,  2]", "aView[nLin,  2]" } )
		For nX := 1 TO Len(aPeriodo) 
			aAdd(aColunas, { "S1[Periodo_"+StrZero(nX,3)+"]", "aView[nLin, "+Str(nX*2+1, 3)+"]", "aViewGraf[nLin, "+Str(nX*2-1,3)+"]"} )
			aAdd(aColunas, { "S2[Periodo_"+StrZero(nX,3)+"]", "aView[nLin, "+Str(nX*2+2, 3)+"]", "aViewGraf[nLin, "+Str(nX*2,3)+"]" } )
		Next
		
		cDescri := Capital(AllTrim(aProcessa[1][5]))
		
		aColTitle := {}
		aAdd(aColTitle, cDescri)
		aAdd(aColTitle, STR0063) //"Descricao"
		For nX := 1 TO Len(aPeriodo)
			aAdd(aColTitle, aPeriodo[nx]+"["+AllTrim(aConfig[9])+"]")
			aAdd(aColTitle, aPeriodo[nx]+"["+AllTrim(aConfig[13])+"]")
		Next
			
	    EndIf
	
	If !Empty(aProcessa)
		nTpGraph  := If(ValType(aConfig[5])=="N", aConfig[5], Val(aConfig[5]))
		C380SetCols(aColunas,aColTitle, .T., aCpoSel, aCpoUsr)
		//montagem da planilha e grafico
		PCOC380PFI(aProcessa,aProcComp,cDescri,nTpGraph,{}/*aNiveis*/,nCasas,NIL/*lShowGraph*/, aCpoSel, aCpoUsr, aListArq)
	Else
		Aviso(STR0064,STR0065,{STR0066},2)  //"Aten็ใo"###"Nใo existem valores a serem visualizados na configura็ใo selecionada. Verifique as configura็๕es da consulta."###"Fechar"
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOC380PFI บAutor  ณPaulo Carnelossi   บ Data ณ  18/01/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta de Saldos e Projecoes por Periodos-Visao Ger./Cubo บฑฑ
ฑฑบ          ณTela para exibicao                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PCOC380PFI(aProcessa, aProcComp, cDescri, nTpGrafico, aNiveis, nCasas, lShowGraph, aCpoSel, aCpoUsr, aListArq)
Local oDlg
Local oFolder 
Local oView

Local oGrafico
Local oPanel
Local oPanel1
Local oPanel2

Local aArea       := GetArea()
Local aSize       := {}
Local aPosObj     := {}
Local aObjects    := {}
Local aInfo       := {}
Local nx,ny,nZ
Local aButtons    := {}
Local bEncerra    := {|| If(Aviso( STR0060,STR0067, {STR0039,STR0040},2)==1,  ( PcoArqSave(aListArq), oDlg:End() ), NIL)} //"Atencao"###"Deseja abandonar a consulta ?"###"Sim"###"Nao"
Local aTabMail    := {}
Local aTitle      := {}
Local lPergNome  := ( SuperGetMV("MV_PCOGRAF",.F.,"2") == "1" )

Private aView     := {}
Private aViewGraf := {}

DEFAULT lShowGraph := .T.
DEFAULT aListArq := {}

nCasas	:=	Iif(nCasas==1,0,IIf(nCasas==2,-3,-6))
nDivisor	:=	10**(Abs(nCasas))
If Empty(cPicture)
	cPicture := If(nCasas==-6,"@E 999,999,999,999.99","@E 999,999,999,999")
EndIf	
cCadastro	+=	IIf(nCasas==0,"" ,IIf(nCasas==-3,STR0074,STR0075)) //" - (Valores em milhares)"###" - (Valores em milhoes)"

aButtons := {	{"BMPPOST" 	, {|| PmsGrafMail(oGrafico,Padr(cDescri,150),{cCadastro},aTabMail, 3, 2, .T.) },STR0068,STR0069 },;  //"Enviar Email"###"Email"
				{"GRAF2D"	, {|| HideShowGraph(oPanel2, oPanel1, @lShowGraph) },STR0070,STR0071 },;  //"Exibir/Esconder Grafico"###"Grafico"
				{"SALVAR"	, {|| PcoSaveGraf(oGrafico, lPergNome, .T., .F., aListArq) },STR0150,STR0151 } ; //"Imprimir/Gerar Grafico em formato BMP"##"Salva/BMP"
			}

aView := C380View(aProcessa, aProcComp, aViewGraf, nCasas)

aViewBrw := C380Acols(aCpoSel, aCpoUsr, aView, aViewGraf, aTitle, aTabMail)

If !Empty(aViewBrw)
	aSize := MsAdvSize(,.F.,400)
	aObjects := {}
	
	AAdd( aObjects, { 100, 100 , .T., .T. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD
	DEFINE FONT oFont NAME "Arial" SIZE 0, -10 
	DEFINE MSDIALOG oDlg TITLE cCadastro + " - " + cDescri From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	oDlg:lMaximized := .T.
	
	oPanel := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,10,22,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP

	oPanel1 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,40,40,.T.,.T. )
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel2 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,40,120,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_BOTTOM
	If !lShowGraph
		oPanel2:Hide()
	EndIf	

	@ 2,4 SAY AKN->AKN_DESCRI  of oPanel SIZE 120,9 PIXEL FONT oBold COLOR RGB(80,80,80)
	@ 3,3 BITMAP oBar RESNAME "MYBAR" Of oPanel SIZE BrwSize(@oDlg,0)/2,8 NOBORDER When .F. PIXEL ADJUST

	@ 12,2 SAY STR0072+DTOC(aConfig[1])+STR0073+DTOC(aConfig[2])+ IIf(nCasas==0,"" ,IIf(nCasas==-3,STR0074,STR0075)) Of oPanel PIXEL SIZE 640 ,79 FONT oBold  //"Saldo de : "###" a "###" - (Valores em milhares)"###" - (Valores em milhoes)"

	oView	:= TWBrowse():New( 2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,aTitle,,oPanel1,,,,,,,oFont,,,,,.F.,,.T.,,.F.,,,)
	oView:Align := CONTROL_ALIGN_ALLCLIENT
	oView:SetArray(aViewBrw)
	oView:bChange := { || 	oGrafico:=C380Grafico(aPosObj, oPanel2, oFont, nTpGrafico, aViewGraf[oView:nAT]) }
	oView:bLine := { || aViewBrw[oView:nAT]}

	oGrafico := C380Grafico(aPosObj, oPanel2, oFont, nTpGrafico, aViewGraf[oView:nAT])
	
	aButtons := aClone(AddToExcel(aButtons,{ {"ARRAY",STR0076+DTOC(aConfig[1])+STR0073+DTOC(aConfig[2])+ IIf(nCasas==0,"" ,IIf(nCasas==-3,STR0074,STR0075)),aTitle,aViewBrw} } )) //"Saldo de "###" a "###" - (Valores em milhares)"###" - (Valores em milhoes)"
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Eval(bEncerra)},{|| Eval(bEncerra)},,aButtons )

EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380GraficoบAutor  ณPaulo Carnelossi   บ Data ณ  18/01/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta de Saldos e Projecoes por Periodos-Visao Ger./Cubo บฑฑ
ฑฑบ          ณMonta Grafico para exibicao                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C380Grafico(aPosObj, oPanel, oFont, nTpGrafico, aValues)
Local nZ
Local oGraphic
Local nPeriodo	:= 1
Local aSeries	:= {}
Local aColors	:= {CLR_BLUE,CLR_GREEN,CLR_RED,CLR_CYAN,CLR_MAGENTA,CLR_BROWN,CLR_HGRAY,CLR_YELLOW,CLR_HBLUE}

	@ 2,2 MSGRAPHIC oGraphic SIZE aPosObj[1,4]-10,aPosObj[1,3]-aPosObj[1,1]-30 OF oPanel
	oGraphic:Align := CONTROL_ALIGN_ALLCLIENT
	oGraphic:oFont := oFont

	oGraphic:SetMargins( 15, 25, 10,10 )
	oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGraphic:SetTitle( "", "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
	oGraphic:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .F. )
	//sao 2 series
	aAdd(aSeries,Nil)
	aSeries[1] := oGraphic:CreateSerie( nTpGrafico )

	aAdd(aSeries,Nil)
	aSeries[2] := oGraphic:CreateSerie( nTpGrafico )
	oGraphic:l3D := .F.

	For nZ := 1 To Len(aValues) Step 2 //step 2 pois sao 2 configuracoes
		oGraphic:Add(aSeries[1], aValues[nZ]	, aPeriodo[nPeriodo], aColors[1])
		oGraphic:Add(aSeries[2], aValues[nZ+1]	, aPeriodo[nPeriodo], aColors[2])
		nPeriodo++
	Next

Return(oGraphic)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380View   บAutor  ณPaulo Carnelossi   บ Data ณ  18/01/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta de Saldos e Projecoes por Periodos-Visao Ger./Cubo บฑฑ
ฑฑบ          ณMonta Array para Grafico e prepara array  para Grade        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380View(aProcessa, aProcComp, aViewGraf, nCasas)
Local nx, nz, nPos
Local aView := {} 
Local aAuxView, aGraf 
Local nDivisor	:=	10**(Abs(nCasas))
Local nTotCfg1, nTotCfg2, nCoefic
Local aPeriodos	:= {}

//Local cPicture	:=	If(nCasas==-6,"@E 999,999,999,999.99","@E 999,999,999,999")

For nx := 1 to Len(aProcessa)

	nPos := ASCAN(aProcComp, {|aVal| aVal[1] == aProcessa[nX][1]})
	aPeriodos	:= {}
	aAuxView := {}
	aGraf := {}
	aAdd(aAuxView, aProcessa[nx][1] )   //codigo
	aAdd(aAuxView, aProcessa[nx][6] )   //descricao
	
	If aConfig[19] == 1  //Nenhum
		For nZ := 1 TO Len(aProcessa[nx][2])
			aAdd(aAuxView, TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			
	        If nPos > 0 
				aAdd(aAuxView, TransForm(aProcComp[nPos][2][nZ]/nDivisor,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, aProcComp[nPos][2][nZ]/nDivisor) 
			Else	
				aAdd(aAuxView, TransForm(0,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, 0) 
	        EndIf
		Next

	ElseIf aConfig[19] == 2 //"2=Tendencia Linear"

		nTotCfg1 := 0
		nTotCfg2 := 0
		
		For nZ := 1 TO nPeriodo
			
			aAdd(aAuxView, TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			
	        If nPos > 0 
				aAdd(aAuxView, TransForm(aProcComp[nPos][2][nZ]/nDivisor,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, aProcComp[nPos][2][nZ]/nDivisor) 
			Else	
				aAdd(aAuxView, TransForm(0,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, 0) 
	        EndIf
			AADD(aPeriodos,aGraf[Len(aGraf)])			
		Next
		
		For nZ := nPeriodo+1 TO Len(aProcessa[nx][2])
			aAdd(aAuxView, TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			
			nCoefic := PC380TDLNR(aPeriodos)
            //nesta projecao repete os valores previsto para se adequar ao orcamento 
			aAdd(aAuxView, TransForm(nCoefic/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, nCoefic/nDivisor) 
			AADD(aPeriodos,aGraf[Len(aGraf)])
			
		Next

	ElseIf aConfig[19] == 3 //"3=Recuperar Orcamento ate o fim"
	
		nTotCfg1 := 0
		nTotCfg2 := 0
		For nZ := 1 TO nPeriodo
			aAdd(aAuxView, TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			
	        If nPos > 0 
				aAdd(aAuxView, TransForm(aProcComp[nPos][2][nZ]/nDivisor,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, aProcComp[nPos][2][nZ]/nDivisor) 
			Else	
				aAdd(aAuxView, TransForm(0,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, 0) 
	        EndIf
	        nTotCfg1 += aGraf[Len(aGraf)-1]
	        nTotCfg2 += aGraf[Len(aGraf)]
		Next
		
		nCoefic := nTotCfg2 - nTotCfg1
		//zera ntotcfg1 e acumula para saber total previsto restante
		nTotCfg1 := 0
		For nZ := nPeriodo+1 TO Len(aProcessa[nx][2])
   	        nTotCfg1 += aProcessa[nx][2][nZ]/nDivisor
		Next
		//agora projeta os periodos restantes recuperando o orcamento a partir dt.ref.
		For nZ := nPeriodo+1 TO Len(aProcessa[nx][2])
			//previsto 
			aAdd(aAuxView, TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			//projetado recupera orcto
			aAdd(aAuxView, TransForm((aProcessa[nx][2][nZ] - (nCoefic/nTotCfg1*aProcessa[nx][2][nZ]))/nDivisor,cPicture))  
			aAdd(aGraf, (aProcessa[nx][2][nZ] - (nCoefic/nTotCfg1*aProcessa[nx][2][nZ]))/nDivisor) 
		Next

	ElseIf aConfig[19] == 4 //"4=Ajustar ao Orcamento a Partir da Referencia"

		For nZ := 1 TO nPeriodo
			aAdd(aAuxView, TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			
	        If nPos > 0 
				aAdd(aAuxView, TransForm(aProcComp[nPos][2][nZ]/nDivisor,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, aProcComp[nPos][2][nZ]/nDivisor) 
			Else	
				aAdd(aAuxView, TransForm(0,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, 0) 
	        EndIf
		Next
		
		For nZ := nPeriodo+1 TO Len(aProcessa[nx][2])
		
			aAdd(aAuxView, TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
            //nesta projecao repete os valores previsto para se adequar ao orcamento 
			aAdd(aAuxView, TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			
		Next

	ElseIf aConfig[19] == 5 //"5=Tendencia pela media"

		nTotCfg1 := 0
		nTotCfg2 := 0
		For nZ := 1 TO nPeriodo
			aAdd(aAuxView, TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			
	        If nPos > 0 
				aAdd(aAuxView, TransForm(aProcComp[nPos][2][nZ]/nDivisor,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, aProcComp[nPos][2][nZ]/nDivisor) 
			Else	
				aAdd(aAuxView, TransForm(0,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, 0) 
	        EndIf
	        nTotCfg1 += aGraf[Len(aGraf)-1]
	        nTotCfg2 += aGraf[Len(aGraf)]
		Next
		
		nCoefic := nTotCfg2 / nTotCfg1
		
		For nZ := nPeriodo+1 TO Len(aProcessa[nx][2])
			aAdd(aAuxView, TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			
	        If nPos > 0 
				aAdd(aAuxView, TransForm(aGraf[Len(aGraf)]/nDivisor*nCoefic,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, aGraf[Len(aGraf)]/nDivisor*nCoefic) 
			Else	
				aAdd(aAuxView, TransForm(0,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, 0) 
	        EndIf
		Next

	EndIf
	
	aAdd(aView, aAuxView)
	aAdd(aViewGraf, aGraf)

Next

Return(aView)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380Acols  บAutor  ณPaulo Carnelossi   บ Data ณ  18/01/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta de Saldos e Projecoes por Periodos-Visao Ger./Cubo บฑฑ
ฑฑบ          ณMonta Array para Grade                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380Acols(aCpoSel, aCpoUsr, aView, aViewGraf, aTitle, aTabMail)
Local aRetorno := {}
Local nX, nZ
Local nTotS1 := 0, nTotS2 := 0
Local lTotLin, lPercLin, aPercent
Local cPictPer := "@R 999.99 %"
Local aCpo_Sel := aClone(aCpoSel)
Local aCpo_Usr := aClone(aCpoUsr)
Local cCpoAux, nPos
Local cElem, nCont
Private nLin

lTotLin := (aConfig[17] == 1)
lPercLin:= (aConfig[18] == 1)

//calcula total das series-1 e 2
aTotLin := {}
For nX := 1 TO Len(aViewGraf)
	nTotS1 := 0
	nTotS2 := 0
	For nZ := 1 TO Len(aViewGraf[nX]) STEP 2
		nTotS1 += aViewGraf[nX, nZ]
		nTotS2 += aViewGraf[nX, nZ+1]			
    Next
    aAdd(aTotLin, { nTotS1, nTotS2} )
Next    

aAdd(aColunas, { "S1[TOTAL]"		, "Transform(aTotLin[nLin, 1], '"+cPicture+"')", "aTotLin[nLin, 1]" } )
aAdd(aColunas, { "S2[TOTAL]"		, "Transform(aTotLin[nLin, 2], '"+cPicture+"')", "aTotLin[nLin, 2]" } )
aAdd(aColunas, { "SC[QTDE_PERIODO]"	, "Transform(Len(aPeriodo), '999')", "Len(aPeriodo)" } )
aAdd(aColunas, { "S1[MEDIA]"		, "Transform(aTotLin[nLin, 1]/Len(aPeriodo), '"+cPicture+"')", "aTotLin[nLin, 1]/Len(aPeriodo)" } )
aAdd(aColunas, { "S2[MEDIA]"		, "Transform(aTotLin[nLin, 2]/Len(aPeriodo), '"+cPicture+"')", "aTotLin[nLin, 2]/Len(aPeriodo)" } )

// calcula e exibe percentual p coluna em relacao ao total
aPerLin := {}
For nX := 1 TO Len(aViewGraf)
	nTotS1 := aTotLin[nX, 1]
	nTotS2 := aTotLin[nX, 2]
	aPercent := {}
	For nZ := 1 TO Len(aViewGraf[nX]) STEP 2
		aAdd(aPercent, aViewGraf[nX, nZ] / nTotS1 * 100)
		aAdd(aPercent, aViewGraf[nX, nZ+1] / nTotS2 * 100)
    Next
    aAdd(aPerLin, aClone(aPercent) )
Next

For nX := 1 TO Len(aPeriodo)
	aAdd(aColunas, { "S1[PERC"+StrZero(nX,2)+"]", "Transform(aPerLin[nLin, "+StrZero(nX*2-1)+"], '"+cPicture+"')", "aPerLin[nLin, "+StrZero(nX*2-1)+"]" } )
	aAdd(aColunas, { "S1[PERC"+StrZero(nX,2)+"]", "Transform(aPerLin[nLin, "+StrZero(nX*2)  +"], '"+cPicture+"')", "aPerLin[nLin, "+StrZero(nX*2)  +"]" } )
Next

aTitle := {}
nX := 1

While  nX <= Len(aCpo_Sel)

	If ! aCpo_Sel[nX, 1]  //se nao estiver marcado nao exibe na tela
		nX++
		Loop
	EndIf
	
	cCpoAux := Alltrim(aCpo_Sel[nX, 4])

	If Left(cCpoAux,7) != CAMPO_USUARIO
		
		If (nPos := Ascan(aColunas,{|aVal| Alltrim(aVal[1]) == Alltrim(cCpoAux)})) > 0 
			//insere as formulas de apresentacao e calculo no array aCpo_Sel
			aAdd(aTitle, aCpo_Sel[nX, 3])
			aAdd(aCpo_Sel[nX], aColunas[nPos, 2])
			aAdd(aCpo_Sel[nX], aColunas[nPos, 3])
	    EndIf
	
		If  (Left(cCpoAux, 3)$"S1[|S2[" ) .And. lPercLin

			aAdd(aTitle, STR0077+"["+AllTrim(aConfig[If(Left(cCpoAux, 3)="S1",9,13)])+"-P"+Right(cCpoAux,3)) //"Perc."
			aSize(aCpo_Sel, Len(aCpo_Sel)+1)
			aIns(aCpo_Sel, nX+1)
			If Left(cCpoAux, 3) == "S1["
				cElem := "(2*"+Left(Right(cCpoAux, 3),2)+")-1]"
			Else
				cElem := "(2*"+Left(Right(cCpoAux, 3),2)+")]"
			EndIf	
			aCpo_Sel[nX+1] := { 	.T.,;
									0, ;
									aTitle[Len(aTitle)],;
									Left(cCpoAux, 3)+"PERC"+Right(cCpoAux, 3),;
									"Transform(aPerLin[nLin, "+cElem+", '"+cPictPer+"')", ;
									"aPerLin[nLin, "+cElem }
			nX++
		EndIf
									
	Else  //se for campo de usuario
	
		If (nPos := Ascan(aCpoUsr,{|aVal| Alltrim(aVal[1]) == Alltrim(cCpoAux)})) > 0
			aAdd(aTitle, aCpo_Sel[nX, 3]) 
			aFormula :=  C380Formula( aCpoUsr[nPos], aColunas)
			//insere as formulas de apresentacao e calculo no array aCpo_Sel
			aAdd(aCpo_Sel[nX], aFormula[1])
			aAdd(aCpo_Sel[nX], aFormula[2])
	    EndIf
	
	EndIf
	
	nX++
	
EndDo

//aqui voltar nas expressoes de campo de usuario para 
//verificar se ficou algum campo sem resolver
nCont := 0
While nCont <= 11

	aResolver := {}
	If !C380ResolvCpo(aCpo_Sel, aResolver)
		Return
	EndIf
	
	If ! Empty(aResolver)
		C380AuxResolv(aCpo_Sel, aResolver, aResolver[1,2])
	Else
		Exit	
	EndIf

	If nCont >= 10
		Aviso(STR0060,STR0078+aResolver[1,1]+".", {"Ok"}) //"Atencao"###"Referencia circular, verifique o campo "
		Return
	EndIf
	
	nCont++	
	
EndDo	

If lTotLin
	//coluna total da configuracao-1 do cubo
	aAdd(aTitle, STR0079+"["+AllTrim(aConfig[9])+"]") //"Total "
	aSize(aCpo_Sel, Len(aCpo_Sel)+1)
	aCpo_Sel[Len(aCpo_Sel)] := { 	.T.,;
							0, ;
							aTitle[Len(aTitle)],;
							"S1[TOTAL]",;
							"Transform(aTotLin[nLin, 1], '"+cPicture+"')",;
							"aTotLin[nLin, 1]" }	

	//coluna total da configuracao-2 do cubo
	aAdd(aTitle, STR0079+"["+AllTrim(aConfig[13])+"]") //"Total "
	aSize(aCpo_Sel, Len(aCpo_Sel)+1)
	aCpo_Sel[Len(aCpo_Sel)] := { 	.T.,;
							0, ;
 							aTitle[Len(aTitle)],;
							"S2[TOTAL]",;
							"Transform(aTotLin[nLin, 2], '"+cPicture+"')",;
							"aTotLin[nLin, 2]" }	

EndIf	

//array para envio por e-mail
aTabMail	:=	{}
//titulo para as colunas
aAdd(aTabMail,{})
For nZ:=1 To Len(aTitle)
	AAdd(aTabMail[1],Alltrim(aTitle[nZ]) )
Next

aRetorno := {}

For nZ := 1 TO Len(aView)
	nLin := nZ
	aAux := {}
	aAuxMail := {}
	For nX := 1 TO Len(aCpo_Sel)
		If aCpo_Sel[nX, 1] //somente exibe se estiver marcado
			aAdd(aAux, &(Alltrim(aCpo_Sel[nX, 5])) )
			aAdd(aAuxMail, &(Alltrim(aCpo_Sel[nX, 6])) )
		EndIf	
    Next
	aAdd(aRetorno, aClone(aAux) )

	//array para envio por e-mail
	aAdd(aTabMail,{})
	For nX:=1 To Len(aAuxMail)
		If ValType(aAuxMail[nX])=="C"
			aAdd(aTabMail[Len(aTabMail)], Alltrim(aAuxMail[nX]) )
		ElseIf ValType(aAuxMail[nX])=="D"
			aAdd(aTabMail[Len(aTabMail)], Alltrim(DtoC(aAuxMail[nX])) )
		Else
			aAdd(aTabMail[Len(aTabMail)], Alltrim(Transform(aAuxMail[nX], cPicture)) )
		EndIf	
	Next
	
Next	

Return(aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380FormulaบAutor  ณPaulo Carnelossi   บ Data ณ  18/01/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a Formula a ser interpretada na carga do array para a บฑฑ
ฑฑบ          ณGrade                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380Formula( aAuxUsr )
Local aRetForm := {"", ""}
Local cExpr := "", cCampo
Local nX
Local cTipo, nTamanho, nDecimal, cPict

cTipo 		:= Alltrim(aAuxUsr[2])
nTamanho 	:= aAuxUsr[4]
nDecimal 	:= aAuxUsr[5]
cPict 		:= Alltrim(aAuxUsr[3])
cExpr 		+= Alltrim(aAuxUsr[6])  //Formula Original

For nX := 1 TO Len(aColunas)
	cCampo := Alltrim(aColunas[nX, 1])
	cExpr := StrTran(cExpr, cCampo, Alltrim(aColunas[nX,3]))
Next
If cTipo == "C"
	If Empty(cPict)
		aRetForm[1] := "'"+cExpr+"')"
	Else
		aRetForm[1] := "Transform("+cExpr+", '"+cPict+"')"
	EndIf	
ElseIf cTipo == "D"
	If Empty(cPict)
		aRetForm[1] := "DtoC("+cExpr+")"
	Else
		aRetForm[1] := "Transform("+cExpr+", '"+cPict+"')"
	EndIf	
Else
	If Empty(cPict)
		cPict := "@E 999,999,999.99"
	EndIf	
	aRetForm[1] := "Transform("+cExpr+", '"+cPict+"')"
EndIf
aRetForm[2] := cExpr
Return(aRetForm)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoC380SldบAutor  ณPaulo Carnelossi    บ Data ณ  18/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta de Saldos e Projecoes por Periodos-Visao Ger./Cubo บฑฑ
ฑฑบ          ณRotina utilizada pela funcao pcoruncubevis() para compor os บฑฑ
ฑฑบ          ณsaldos das contas envolvidas na visao                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoC380Sld(cConfig,cChave)
Local aRetorno := {}
Local aRetFim
Local nCrdFim
Local nDebFim
Local ny
Local lSaldoIni := .T.

For ny := 1 to Len(aPeriodo)

	nSldIni := 0
	
	If aPrcSldIni[nProcCubo] == 2

		If lSaldoIni
	
			nSldIni := 0
		    // PROCESSA CUBO SALDO INICIAL 
			dIni := CtoD(Subs(aPeriodo[ny], 1, 10))-1
	
			aRetIni := PcoRetSld(cConfig,cChave,dIni)
			nCrdIni := aRetIni[1, aConfig[4]]
			nDebIni := aRetIni[2, aConfig[4]]
	
			nSldIni := nCrdIni-nDebIni
			lSaldoIni := .F.
	
		Else
	
			nSldIni := nSldFim
	
		EndIf
		
    EndIf
    
    // PROCESSA CUBO SALDO FINAL
	dFim := CtoD(Subs(aPeriodo[ny],14))

	aRetFim := PcoRetSld(cConfig,cChave,dFim)
	nCrdFim := aRetFim[1, aConfig[4]]
	nDebFim := aRetFim[2, aConfig[4]]

	nSldFim := nCrdFim-nDebFim

	//retorna saldo final - saldo inicial
	aAdd(aRetorno,nSldFim-nSldIni)
	
Next

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณC380SetCols   บAutor ณPaulo Carnelossi  บ Data ณ 26/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณTela para indicar os campos assim como a ordem em que serao บฑฑ
ฑฑบ          ณexibidos. Permite criar campos de usuarios com formulas     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380SetCols(aColunas,aColTitle, lEdtPar, aCpoSel, aCpoUsr)
Local nX, lRet := .T.
Local aParametros := {}
Local oDlg, oFont
Local nItem := 1
Local aButtons		:= {}
Local cCampo, cTipo, cPicture, nTamanho, nDecimal, cExprCpo
Local lFilePar, cGrvPar, cLidoArq, lCheck, cCpoAux, cLinAux
Local oOk		:= LoadBitMap(GetResources(), "LBTIK")
Local oNo		:= LoadBitMap(GetResources(), "LBNO")
Local lCampos := .T.
Local cTitle, nZ, lAdiciona, nPos, cAux
Local cArqPlan := "", cExtPlan := ".PFG", lArqPlan := .F., aPlan := {}
Local aConPlan, aRetPlan, cArqCon, aRetCon 
Local lArqNew, cConsArq := "", nCont
lEdtPar := .T.

cArqPlan :="\PROFILE\PCOC380_"+__cUserID

lArqPlan := File(cArqPlan+cExtPlan)

If lArqPlan
	If aConfig[20]==1
		//le o arquivo que contem a lista das consultas
		cLidoArq := MEMOREAD(cArqPlan+cExtPlan)
		nLenArq := MLCOUNT(cLidoArq,80)
		For nX := 1 TO nLenArq
			cLinAux := MEMOLINE(cLidoArq, 80, nX)
			aAdd(aPlan, {Subs(cLinAux,1,16), Subs(cLinAux, 17,20), Subs(cLinAux,37,29) })
		Next
        //constroi um array com as consultas referente ao periodo informado
		aConPlan := {}
		aRetPlan := {}
		aAdd(aConPlan, STR0080) //"01=Nova Consulta"
		aAdd(aRetPlan, "01=Nova Consulta")
		nCont := 2

		For nX := 1 TO Len(aPlan)
			If DTOS(aConfig[1])+DTOS(aConfig[2]) == aPlan[nX, 1]
				aAdd(aConPlan, StrZero(nCont,2)+"="+aPlan[nX, 2])
				aAdd(aRetPlan, aPlan[nX, 3])
				nCont++
			EndIf
		Next		
		If !Empty(aConPlan)
			aRetCon := {}
			If ParamBox( {	{2,STR0081,1,aConPlan,80,"",.F.} },STR0082,aRetCon,,,,,,,,.F.,) //"Arquivo/Consulta"###"Arquivo Configuracao da Consulta"
				aRetCon[1]  := If(ValType(aRetCon[1])=="N", aRetCon[1], Val(aRetCon[1]))
				If aRetCon[1] == 1  //Nova Consulta
					lArqPlan := .F.
				Else
					cArqCon := aRetPlan[aRetCon[1]]
				EndIf
			Else
				lArqPlan := .F.
			EndIf
		Else
			lArqPlan := .F.
		EndIf
	Else
		lArqPlan := .F.
	EndIf
EndIf

If lArqPlan
	lFilePar := File(cArqCon+cExtPlan)
Else
	lFilePar := .F.
EndIf		

If !lFilePar
	cArqCon := NIL
	For nX := 1 TO Len(aColTitle)
		aAdd(aCpoSel, {.T., nItem++, aColTitle[nX], aColunas[nX, 1]})
	Next
Else
	If aConfig[20]==1
		cLidoArq := MEMOREAD(cArqCon+cExtPlan)
		cLinAux := MEMOLINE(cLidoArq, 120, 1)
	Else
		cLinAux := ""	
	EndIf	
    If DTOS(aConfig[1]) == Subs(cLinAux, 1, 8) .And. ;
	    DTOS(aConfig[2]) == Subs(cLinAux, 9, 8)
    
		nLenArq := MLCOUNT(cLidoArq,120)
		For nX := 2 TO nLenArq
			cLinAux := MEMOLINE(cLidoArq, 120, nX)
			If Alltrim(cLinAux)=="[CAMPOS USUARIO-CFG]"
				lCampos := .F.
				Loop
			EndIf
			If lCampos
				cCampo :=  Alltrim(Subs(cLinAux,54,50))
				lAdiciona := .F.
				If Alltrim(Subs(cCampo,1,2)) $ "SA|SB" 
					lCheck := If(Subs(cLinAux,1,1)=="1", .T., .F.)
					aAdd(aCpoSel, {lCheck, Val(Subs(cLinAux,2,2)), Alltrim(Subs(cLinAux,4,50)),cCampo})
					lAdiciona := .T.					
				ElseIf (Alltrim(Subs(cCampo,1,2)) $ "S1|S2" .And. ;
					 	Ascan(aColunas, {|aVal| Alltrim(aVal[1]) == cCampo }) > 0 )
					lCheck := If(Subs(cLinAux,1,1)=="1", .T., .F.)
					//procurar no array aColTitle/aColunas titulo do periodo 
					nPos := Ascan(aColunas, {|aVal| Alltrim(aVal[1]) == cCampo })
					cTitle := aColTitle[nPos]  
					aAdd(aCpoSel, {lCheck, Val(Subs(cLinAux,2,2)), cTitle, cCampo })
					lAdiciona := .T.					
				ElseIf Alltrim(Subs(cLinAux,54,7)) == CAMPO_USUARIO
					lCheck := If(Subs(cLinAux,1,1)=="1", .T., .F.)
					aAdd(aCpoSel, {lCheck, Val(Subs(cLinAux,2,2)), Alltrim(Subs(cLinAux,4,50)),Alltrim(Subs(cLinAux,54,50))})
					lAdiciona := .T.					
				EndIf	
				If ! lAdiciona
					Aviso(STR0060, STR0083+Alltrim(Subs(cLinAux,54,50))+STR0084, {"Ok"}) //"Atencao"###"Campo : "###" nao contemplado no periodo informado. Verifique as formulas!"
				EndIf
			Else
				cCampo   := Subs(cLinAux,1,10)
				cTipo    := Subs(cLinAux,11,1)
				cPicture :=	Subs(cLinAux,12,20)
				nTamanho := Val(Subs(cLinAux,32,2))
				nDecimal := Val(Subs(cLinAux,34,2))
				cExprCpo := Subs(cLinAux,36)
				lAdiciona := .T.
				nPos := At("[Periodo_", cExprCpo)
                If nPos > 0 
                	cAux := Subs(cExprCpo, nPos-2, 14)
                	If Ascan(aColunas, {|aVal| Alltrim(aVal[1]) == cAux }) == 0
                		lAdiciona := .F.
                		If (nPos := aScan(aCpoSel, {|aVal| Alltrim(aVal[4]) == Alltrim(cCampo) })) > 0
						    ADEL(aCpoSel, nPos)
						    ASIZE(aCpoSel, Len(aCpoSel)-1)
						EndIf
                	EndIf
                EndIf	
                If lAdiciona	
					aAdd(aCpoUsr, { cCampo, cTipo, cPicture, nTamanho, nDecimal, cExprCpo })
				Else
					Aviso(STR0060, STR0083+cCampo+STR0084, {"Ok"}) //"Atencao"###"Campo : "###" nao contemplado no periodo informado. Verifique as formulas!"
				EndIf	
			EndIf
		Next
	Else
		cArqCon := NIL
		For nX := 1 TO Len(aColTitle)
			aAdd(aCpoSel, {.T., nItem++, aColTitle[nX], aColunas[nX, 1]})
		Next
	EndIf
EndIf

DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD
aSize := MsAdvSize(,.F.,400)
aObjects := {}

AAdd( aObjects, { 100, 100 , .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

If Empty(aCpoSel)
	aAdd(aCpoSel, {.F.,nItem++, STR0085}) //"Nenhum"
EndIf   

DEFINE MSDIALOG oDlg TITLE STR0086 From 0,0 to 200,400 of oMainWnd PIXEL  //"Colunas"
AAdd( aButtons, { "PMSSETADOWN", { || C380MudaOrd(1, aCpoSel, oCampos) }, STR0087, STR0087 } ) //"Abaixo"###"Abaixo"
AAdd( aButtons, { "PMSSETAUP"  , { || C380MudaOrd(2, aCpoSel, oCampos) }, STR0088, STR0088 } ) //"Acima"###"Acima"
AAdd( aButtons, { "INSTRUME"   , { || C380ConstrForm(aCpoSel, oCampos, aCpoUsr) }, STR0089, STR0090 } ) //"Construtor de Formulas"###"Formulas"
AAdd( aButtons, { "BMPINCLUIR" , { || C380InsCampo(aCpoSel, oCampos, aCpoUsr) }	, STR0091, STR0092 } ) //"Incluir Campo"###"Campo"
AAdd( aButtons, { "NOTE"       , { || C380EdtCpoUsr(aCpoSel[oCampos:nAt, 4], aCpoSel, oCampos, aCpoUsr) }	, STR0093, STR0092 } ) //"Editar Campo"###"Campo"
AAdd( aButtons, { "EXCLUIR"    , { || C380ExcCpoUsr(aCpoSel[oCampos:nAt, 4], aCpoSel, oCampos, aCpoUsr) }	, STR0094, STR0092 } ) //"Excluir Campo"###"Campo"

oCampos := 	TWBrowse():New( 2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,{" ",STR0095,STR0096,STR0097," "},,oDlg,,,,,,,oFont,,,,,.F.,,.T.,,.F.,,,)  //"Ordem"###"Coluna"###"Referencia"
oCampos:Align := CONTROL_ALIGN_ALLCLIENT

oCampos:SetArray(aCpoSel)
oCampos:bLine := { || {If(aCpoSel[oCampos:nAt,1],oOk,oNo),PadR(aCpoSel[oCampos:nAT, 2],20),PadR(aCpoSel[oCampos:nAT, 3],80),PadR(aCpoSel[oCampos:nAT, 4],30)," "}}
oCampos:bLDblClick := { ||InverteSel(oCampos, oCampos:nAt, .T.)}

// Quando nao for MDI chama centralizada.
If SetMDIChild()
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||lRet := .F., oDlg:End()},, aButtons)
Else
	ACTIVATE MSDIALOG oDlg  ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||lRet := .F., oDlg:End()},, aButtons) CENTERED
EndIf

If lRet
	If lEdtPar .And. aConfig[20]==1
		
		If cArqCon == NIL
			cConsArq := C380ArqCons()
		EndIf	
		
		cGrvPar := DTOS(aConfig[1])+DTOS(aConfig[2])+STR0098+CRLF //"Arquivo de Parametros - Consulta Visao por Cubo por Periodo"
		For nX := 1 TO Len(aCpoSel)
			cGrvPar += If(aCpoSel[nX,1],"1","0")
	   		cGrvPar += StrZero(aCpoSel[nX,2],2)
   			cGrvPar += PadR(aCpoSel[nX,3], 50)
   			cGrvPar += PadR(aCpoSel[nX,4], 50)
	   		cGrvPar += CRLF
		Next

		If Len(aCpoUsr) > 0
			cGrvPar += "[CAMPOS USUARIO-CFG]"+CRLF
			For nX := 1 TO Len(aCpoUsr)
		   		cGrvPar += PadR(aCpoUsr[nX,1], 10) //Campo
	   			cGrvPar += PadR(aCpoUsr[nX,2], 01) //Tipo
	   			cGrvPar += PadR(aCpoUsr[nX,3], 20) //Picture
   				cGrvPar += StrZero(aCpoUsr[nX,4], 2)  // tamanho
   				cGrvPar += StrZero(aCpoUsr[nX,5], 2)  // decimal
   				cGrvPar += PadR(aCpoUsr[nX,6], 60)  // Expressao
	   			cGrvPar += CRLF
		   	Next
		   	
		EndIf
		
		If cArqCon == NIL
			cArqCon := cArqPlan+"_C"+StrZero(Len(aPlan)+1, 4)
			lArqNew := .T.
		EndIf
		
		MemoWrit(cArqCon+cExtPlan,cGrvPar)

		//agora grava a lista de arquivos para consulta
		If lArqNew
			cGrvPar := ""
			For nX := 1 TO Len(aPlan)
	   			cGrvPar += PadR(aPlan[nX,1], 16)
	   			cGrvPar += PadR(aPlan[nX,2], 20)
	   			cGrvPar += PadR(aPlan[nX,3], 29)
		   		cGrvPar += CRLF
			Next
			
	   		cGrvPar += PadR(DTOS(aConfig[1])+DTOS(aConfig[2]), 16)
	   		cGrvPar += PadR(cConsArq, 20)
	   		cGrvPar += PadR(cArqCon, 29)
		   	cGrvPar += CRLF
			MemoWrit(cArqPlan+cExtPlan,cGrvPar)

		EndIf
		
		lEdtPar := .F.
	   
   EndIf
   
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณC380MudaOrd   บAutor ณPaulo Carnelossi  บ Data ณ 18/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณRotina que permite mudar ordem dos campos a ser apresentado บฑฑ
ฑฑบ          ณna consulta                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380MudaOrd(nDirecao, aCpoSel, oCampos)
Local lRet := .T.
Local nX

If nDirecao == 2 .And. oCampos:nAt == 1
	Aviso(STR0060, STR0099,{"OK"}) //"Atencao"###"Topo de Lista"
	lRet := .F.
	
ElseIf nDirecao == 1 .And. oCampos:nAt == Len(aCpoSel)
	Aviso(STR0060,STR0100,{"OK"})  //"Atencao"###"Ultimo Item da Lista"
   lRet := .F.
   
EndIf

If lRet
   aAuxCop := aClone(aCpoSel[oCampos:nAt])
   aSize(aCpoSel, Len(aCpoSel)+1)
   If nDirecao == 1
   	aIns(aCpoSel, oCampos:nAt+1)
   	aCpoSel[oCampos:nAt+1] := aClone(aAuxCop)
   	aCpoSel[oCampos:nAt] := aClone(aCpoSel[oCampos:nAt+2])
   	aDel(aCpoSel, oCampos:nAt+2)
   	oCampos:nAt++
   Else
   	aIns(aCpoSel, oCampos:nAt-1)
   	aCpoSel[oCampos:nAt-1] := aClone(aAuxCop)
   	aDel(aCpoSel, oCampos:nAt+1)
   	oCampos:nAt--
   EndIf
   aSize(aCpoSel, Len(aCpoSel)-1)
	//Renumera a Ordem dos Campos
	For nX := 1 TO Len(aCpoSel)
		aCpoSel[nX][2] := nX
	Next
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณInverteSel    บAutor ณPaulo Carnelossi  บ Data ณ 18/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณRotina Marca/Desmarca campos que serao exibidos na consulta บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function InverteSel(oListBox,nLin, lInverte, lMarca) 
DEFAULT nLin := oListBox:nAt
DEFAULT lMarca := .T.

If lInverte
	oListbox:aArray[nLin,1] := ! oListbox:aArray[nLin,1]

Else
   If lMarca
	   oListbox:aArray[nLin,1] := .T.
   Else
	   oListbox:aArray[nLin,1] := .F.
   EndIf
EndIf   

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณC380ConstrFormบAutor ณPaulo Carnelossi  บ Data ณ 26/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณRotina construtora de formulas                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380ConstrForm(aCpoSel, oCampos, aCpoUsr)
Local nTop      := oMainWnd:nTop+35
Local nLeft     := oMainWnd:nLeft+10
Local nBottom   := oMainWnd:nBottom-12
Local nRight    := oMainWnd:nRight-10
Local nPeriodo  := 0
Local aImg      := {}
Local aFig      := {}
Local bEncerra  := {||oDlg:End()}
Local aButtons  := {}
Local cFormula	 	:= Space(60)
Local oGet1

Local oAplica, nAplica
Local oLayout, nLayout
Local oCodigo, oDescri, oSerie1, oSerie2, oCpoUsr, oCpoOut
Local oMais, oMenos, oDivide, oVezes, oAbrePar, oFechaPar, oLimpaForm
Local oSetCpo

Local nOpca     := 0
Local cAuxForm, nX
Local bNaoseAplica := {||nAplica := 3, nLayout := 5, oAplica:refresh(), oLayout:refresh(),C380Layout(aImg,nLayout),C380PerFig(aFig,nAplica)}
Local bSerie := {||If(nAplica==3, (Aviso(STR0060, STR0141, {"Ok"} ), .F.), .T.) }  //"Atencao"##"Informe faixa ou periodo a ser aplicado."
Local aCfgCpo 	:= {PadR(STR0101,20),; //"Nova Coluna"
					2,;
					14,;
					2,;
					"@E 999,999,999.99"}

DEFINE MSDIALOG oDlg TITLE STR0089 OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight  //"Construtor de Formulas"
oDlg:lMaximized := .T.
//--------------------------------------------------------------------------------
nTop := 15
nLeft := 1
nRight := 30
nBottom := 30
nWidth := oMainWnd:nRight/2 - 5
nHeight := 90
nAplica := 1
oPanel := TPanel():New(nTop,nLeft,'',oDlg,oDlg:oFont, .T., .T.,,,nWidth,nHeight*3,.T.,.T. )
TGroup():New(1, nLeft, 35, nWidth-1, STR0102, oPanel,,, .T.)  //"Aplicar a"
@ 7,nLeft+10 RADIO oAplica VAR nAplica Prompt STR0103,STR0104,STR0142 SIZE 80 ,10  OF oPanel ON CLICK {|| If(nAplica == 1, nPeriodo := 0, If(nAplica == 2, nPeriodo := C380Periodo(),nPeriodo := 0)),C380PerFig(aFig,nAplica),oAplica:refresh()} PIXEL //"Todas as Series / Periodos"###"Somente Periodo Informado"##"Nao se Aplica"
aAdd(aFig,TBitmap():New( 0.5, 20, 240, 50, "PcoTodos",,, oPanel))
aAdd(aFig,TBitmap():New( 0.5, 20, 240, 50, "PcoPer_1",,, oPanel))
C380PerFig(aFig,nAplica)
//--------------------------------------------------------------------------------
nHeight := 88
nLayout := 3
TGroup():New(35, nLeft, nHeight-1, nWidth-1, "Layout", oPanel,,, .T.) 
@ 40,nLeft+10 RADIO oLayout VAR nLayout Prompt STR0105,STR0106,STR0107,STR0139, STR0143 SIZE 60 ,10  OF oPanel ON CLICK {|| C380Layout(aImg,nLayout),oLayout:refresh()} PIXEL //"Antes da Serie - 1"###"Entre as 2 Series"###"Apos a Serie - 2" //"Posicao Atual"##"Nova Coluna no Final"
aAdd(aImg,TBitmap():New( 3.5, 20, 130, 40, "PcoAntes", , , oPanel))
aAdd(aImg,TBitmap():New( 3.5, 20, 130, 40, "PcoEntre", , , oPanel))
aAdd(aImg,TBitmap():New( 3.5, 20, 130, 40, "PcoDepoi", , , oPanel))
aAdd(aImg,TBitmap():New( 3.5, 20, 130, 40, "PcoPosit", , , oPanel))
C380Layout(aImg,nLayout)

//--------------------------------------------------------------------------------
nTop += 88
nHeight := 25

oPanelCpo := TPanel():New(nTop,nLeft,'',oDlg,oDlg:oFont, .T., .T., , ,nWidth,nHeight,.T.,.T. )
TGroup():New(1, nLeft, nHeight-1, nWidth-1, STR0108, oPanelCpo,,, .T.)  //"Campos"
@ 7,nLeft+10 	BUTTON oCodigo 	Prompt STR0109 		SIZE 35,10  FONT oDlg:oFont ACTION {|| Eval(bNaoseAplica), C380MontaForm(1,oGet1,@cFormula,1)} OF oPanelCpo PIXEL //"Codigo"
@ 7,nLeft+60 	BUTTON oDescri  Prompt STR0063		SIZE 35,10  FONT oDlg:oFont ACTION {|| Eval(bNaoseAplica), C380MontaForm(1,oGet1,@cFormula,2)} OF oPanelCpo PIXEL //"Descricao"
@ 7,nLeft+110 	BUTTON oSerie1 	Prompt STR0110		SIZE 35,10  FONT oDlg:oFont ACTION {|| If(Eval(bSerie), C380MontaForm(1,oGet1,@cFormula,3,StrZero(nPeriodo,2)),NIL) } OF oPanelCpo PIXEL  //"Serie - 1"
@ 7,nLeft+160 	BUTTON oSerie2  Prompt STR0111 		SIZE 35,10  FONT oDlg:oFont ACTION {|| If(Eval(bSerie), C380MontaForm(1,oGet1,@cFormula,4,StrZero(nPeriodo,2)),NIL) } OF oPanelCpo PIXEL //"Serie - 2"
@ 7,nLeft+210 	BUTTON oCpoUsr  Prompt STR0112 		SIZE 35,10  FONT oDlg:oFont ACTION {|| Eval(bNaoseAplica), cCpoAux := C380UsuCpo(aCpoSel),C380MontaForm(1,oGet1,@cFormula,5,,cCpoAux)} OF oPanelCpo PIXEL //"Def.Usuario"
@ 7,nLeft+260 	BUTTON oCpoOut  Prompt STR0144		SIZE 35,10  FONT oDlg:oFont ACTION {|| Eval(bNaoseAplica), cCpoAux := C380OutCpo(aCpoSel,aCfgCpo),C380MontaForm(1,oGet1,@cFormula,5,,cCpoAux)} OF oPanelCpo PIXEL //"Outros"
//--------------------------------------------------------------------------------
nTop += 25
nHeight := 25

oPanelOp := TPanel():New(nTop,nLeft,'',oDlg,oDlg:oFont, .T., .T., , ,nWidth,nHeight,.T.,.T. )
TGroup():New(1, nLeft, nHeight-1, nWidth-1, STR0113, oPanelOp,,, .T.)  //"Operadores"

@ 7,nLeft+10 	BUTTON oMais 		Prompt "+" 		SIZE 15 ,10  FONT oDlg:oFont ACTION {|| C380MontaForm(2,oGet1,@cFormula,1) } OF oPanelOp PIXEL
@ 7,nLeft+60 	BUTTON oMenos  		Prompt "-"		SIZE 15 ,10  FONT oDlg:oFont ACTION {|| C380MontaForm(2,oGet1,@cFormula,2) } OF oPanelOp PIXEL
@ 7,nLeft+110 	BUTTON oDivide 		Prompt "/"		SIZE 15 ,10  FONT oDlg:oFont ACTION {|| C380MontaForm(2,oGet1,@cFormula,3) } OF oPanelOp PIXEL 
@ 7,nLeft+160 	BUTTON oVezes  		Prompt "*" 		SIZE 15 ,10  FONT oDlg:oFont ACTION {|| C380MontaForm(2,oGet1,@cFormula,4) } OF oPanelOp PIXEL
@ 7,nLeft+210 	BUTTON oAbrePar 	Prompt "(" 		SIZE 15 ,10  FONT oDlg:oFont ACTION {|| C380MontaForm(2,oGet1,@cFormula,5) } OF oPanelOp PIXEL
@ 7,nLeft+260 	BUTTON oFechaPar 	Prompt ")" 		SIZE 15 ,10  FONT oDlg:oFont ACTION {|| C380MontaForm(2,oGet1,@cFormula,6) } OF oPanelOp PIXEL
@ 7,nLeft+300 	BUTTON oLimpaForm 	Prompt STR0114 	SIZE 75 ,10  FONT oDlg:oFont ACTION {|| cFormula := Space(60), oGet1:refresh() } OF oPanelOp PIXEL //"Limpar Formula"
//--------------------------------------------------------------------------------
nTop += 25
nHeight := 45

oPanelForm := TPanel():New(nTop,nLeft,'',oDlg,oDlg:oFont, .T., .T., , ,nWidth,nHeight,.T.,.T. )
TGroup():New(1, nLeft, nHeight-1, nWidth-1, STR0115, oPanelForm,,, .T.)  //"Formula"
@ 5,5 MsGet oGet1 Var cFormula Size 380,035 COLOR CLR_BLACK PIXEL OF oPanelForm
@ 8,nLeft+300	BUTTON oSetCpo  Prompt STR0116 	SIZE 75,10  FONT oDlg:oFont ACTION {|| C380CfgCampo(aCfgCpo, cFormula) } OF oPanelForm PIXEL //"Configurar Campo de Formula"
//--------------------------------------------------------------------------------

// Quando nao for MDI chama centralizada.
If SetMDIChild()
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(C380CfgCampo(aCfgCpo, cFormula),(nOpca := 1,Eval(bEncerra)), NIL)},{|| Eval(bEncerra)},,aButtons )
Else
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(C380CfgCampo(aCfgCpo, cFormula),(nOpca := 1,Eval(bEncerra)), NIL)},{|| Eval(bEncerra)},,aButtons ) CENTERED 
EndIf

If nOpca == 1  //se tudo ok

	If nAplica == 1   //aplica a todos os periodos
	    cFormula := Alltrim(cFormula)
	    For nX := 1 TO Len(aPeriodo)
	    	cAuxForm := StrTran(cFormula, "[Periodo_00]", "[Periodo_"+StrZero(nX,2)+"]")
	    	C380InsArray(aCpoSel, aCpoUsr, oCampos, cAuxForm, aCfgCpo, nLayout, nX, "P "+StrZero(nX,2)+"-")
		Next	
	Else   // se aplica somente ao periodo ou nao se aplica
		C380InsArray(aCpoSel, aCpoUsr, oCampos, cFormula, aCfgCpo, nLayout, nPeriodo)
	EndIf
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380InsArrayบAutor ณPaulo Carnelossi   บ Data ณ  26/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInsere no array aCpoSel os campos de usuarios definidos peloบฑฑ
ฑฑบ          ณconstrutor de formulas                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380InsArray(aCpoSel, aCpoUsr, oCampos, cFormula, aCfgCpo, nLayout, nPeriodo, cTitulo)
Local nPos := Len(aCpoSel)
Local cCpoAux := ""
Local cCpoUsr
Local cTipo

Default cTitulo := ""

If 		aCfgCpo[2] == 1
	cTipo := "C"
ElseIf 	aCfgCpo[2] == 2
	cTipo := "N"
Else
	cTipo := "D"
EndIf

If nLayout == 1  //antes das series
	cCpoAux := "S1[Periodo_"+StrZero(nPeriodo, 2)+"]"
	nPos 	:= Ascan(aCpoSel, {|aVal| aVal[4] == cCpoAux })
ElseIf nLayout == 2 //entre as series do periodo
	cCpoAux := "S1[Periodo_"+StrZero(nPeriodo, 2)+"]"
	nPos 	:= Ascan(aCpoSel, {|aVal| aVal[4] == cCpoAux }) + 1
ElseIf nLayout == 3 //depois das series do periodo
	cCpoAux := "S2[Periodo_"+StrZero(nPeriodo, 2)+"]"
	nPos 	:= Ascan(aCpoSel, {|aVal| aVal[4] == cCpoAux }) + 1
ElseIf nLayout == 4  //na posicao do listbox
	nPos 	:= oCampos:nAt
ElseIf nLayout == 5  //no final 
	nPos 	:= Len(aCpoSel)+1
EndIf

cCpoUsr := C380CpoUsr(aCpoSel)
   
aSize(aCpoSel, Len(aCpoSel)+1)
aIns(aCpoSel, nPos)
aCpoSel[nPos] := { .T., 99, Alltrim(cTitulo)+aCfgCpo[1], cCpoUsr }
aAdd(aCpoUsr, { cCpoUsr, cTipo, aCfgCpo[5], Val(aCfgCpo[3]),Val(aCfgCpo[4]), cFormula } )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณC380MontaForm บAutor ณPaulo Carnelossi  บ Data ณ  26/01/07  บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณIncrementa na variavel formula o campo ou operador correpon-บฑฑ
ฑฑบ          ณdente ao botao pressionado no construtor de formulas        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380MontaForm(nCpo_Oper,oGet1,cFormula,nOpcao,cPeriodo,cCpoUsr) 
Default cPeriodo := ""
Default cCpoUsr := ""

If nCpo_Oper == 1  //Campos

	If 		nOpcao == 1  //Codigo
		cFormula := PadR(Alltrim(cFormula)+"SA[Codigo]",60)
	ElseIf 	nOpcao == 2	 //Descricao
		cFormula := PadR(Alltrim(cFormula)+"SB[Descricao]",60)
	ElseIf 	nOpcao == 3	 //Serie - 1
		cFormula := PadR(Alltrim(cFormula)+"S1[Periodo_"+cPeriodo+"]",60)
	ElseIf 	nOpcao == 4	 //Serie - 2
		cFormula := PadR(Alltrim(cFormula)+"S2[Periodo_"+cPeriodo+"]",60)
	ElseIf 	nOpcao == 5	 //Definido por Usuario
		cFormula := PadR(Alltrim(cFormula)+cCpoUsr,60)
	EndIf

ElseIf nCpo_Oper == 2  //Operadores
	
	If 		nOpcao == 1  //Mais
		cFormula := PadR(Alltrim(cFormula)+"+",60)
	ElseIf 	nOpcao == 2	 //Menos
		cFormula := PadR(Alltrim(cFormula)+"-",60)
	ElseIf 	nOpcao == 3	 //Divide
		cFormula := PadR(Alltrim(cFormula)+"/",60)
	ElseIf 	nOpcao == 4	 //Multiplica
		cFormula := PadR(Alltrim(cFormula)+"*",60)
	ElseIf 	nOpcao == 5	 //Abre Parenteses
		cFormula := PadR(Alltrim(cFormula)+"(",60)
	ElseIf 	nOpcao == 6	 //Fecha Parenteses
		cFormula := PadR(Alltrim(cFormula)+")",60)
	EndIf

EndIf

oGet1:refresh()
oGet1:SetFocus()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380UsuCpo  บAutor ณPaulo Carnelossi   บ Data ณ  26/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para solicitar o campo de usuario a ser aplicado nas บฑฑ
ฑฑบ          ณna construca das formulas                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380UsuCpo(aCpoSel)
Local cCampo := ""
Local aCampo := {}, aTitulo := {}
Local nX, aRet := {}, nCont := 1

For nX := 1 TO Len(aCpoSel)
	If Left(Alltrim(aCpoSel[nX, 4]),7) == CAMPO_USUARIO
		aAdd(aCampo, Alltrim(aCpoSel[nX, 4]) )
		aAdd(aTitulo, StrZero(nCont, 2)+"="+Alltrim(aCpoSel[nX, 3]) )
		nCont++
	EndIf
Next
	
If !Empty(aTitulo) .And. ParamBox( {	{2,STR0117,1,aTitulo,80,"",.F.} },STR0117,aRet,,,,,,,,.F.,) //"Campo de Usuario"###"Campo de Usuario"
	aRet[1]  := If(ValType(aRet[1])=="N", aRet[1], Val(aRet[1]))
	cCampo := aCampo[aRet[1]]
EndIf	

Return(cCampo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380OutCpo  บAutor ณPaulo Carnelossi   บ Data ณ  09/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para solicitar campo especiais a serem aplicado nas  บฑฑ
ฑฑบ          ณna construcao das formulas                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380OutCpo(aCpoSel,aCfgCpo)
Local cCampo := ""
Local aCampo := {}, aTitulo := {}
Local aRet := {}

aAdd(aCampo, "S1[TOTAL]")
aAdd(aTitulo, "1="+STR0079+"-"+STR0110)  //"Total"###"Serie 1"
aAdd(aCampo, "S2[TOTAL]")
aAdd(aTitulo, "2="+STR0079+"-"+STR0111)  //"Total"###"Serie 1"
aAdd(aCampo, "SC[QTDE_PERIODO]")
aAdd(aTitulo, "3="+STR0145)  //"Qtd.Periodos"
aAdd(aCampo, "S1[MEDIA]")
aAdd(aTitulo, "4="+STR0146)  //"Media-Serie 1"
aAdd(aCampo, "S2[MEDIA]")
aAdd(aTitulo, "5="+STR0147)  //"Media-Serie 2"

If !Empty(aTitulo) .And. ParamBox( {	{2,STR0148,1,aTitulo,80,"",.F.} },STR0149,aRet,,,,,,,,.F.,) //"Campos Especiais"##"Outros Campos"
	aRet[1]  := If(ValType(aRet[1])=="N", aRet[1], Val(aRet[1]))
	cCampo := aCampo[aRet[1]]
	aCfgCpo[1] := PadR(Subs(aTitulo[aRet[1]],3), 20)
	If aRet[1] == 3
		aCfgCpo[3] := 5
		aCfgCpo[4] := 0
		aCfgCpo[5] := "@E 999.99"
	EndIf
EndIf	

Return(cCampo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380Periodo บAutor ณPaulo Carnelossi   บ Data ณ  26/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para solicitar o periodo a ser aplicado nas formulas บฑฑ
ฑฑบ          ณna construca das  formulas                                  บฑฑ
ฑฑบ          ณServe como referencia para insercao das colunas criadas     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380Periodo()
Local aRet := {}
Local nPeriodo := 0

While nPeriodo == 0
	If ParamBox( {	{1,STR0118,Space(2),"","","","", 2,.F.} },STR0119, aRet,,,,,,,,.F.,)  //"Periodo"###"Informe o Periodo"
		nPeriodo := Val(aRet[1])
	EndIf
	If nPeriodo < 1 .OR. nPeriodo > Len(aPeriodo)
		Aviso(STR0060, STR0120, {"Ok"}) //"Atencao"###"Periodo invalido. Verifique!"
		nPeriodo := 0
	EndIf	
EndDo

Return(nPeriodo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380ArqCons บAutor ณPaulo Carnelossi   บ Data ณ  26/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para solicitar o nome para a configuracao dos campos บฑฑ
ฑฑบ          ณde usuario criado                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380ArqCons()
Local aRet := {}
Local cConsArq := ""

While Empty(cConsArq)
	If ParamBox( {	{1,STR0081,Space(20),"","","","", 120,.F.} },STR0121, aRet,,,,,,,,.F.,)  //"Arquivo/Consulta"###"Informe o nome da consulta"
		cConsArq := PadR(aRet[1], 20)
	EndIf
EndDo

Return(cConsArq)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380CfgCampoบAutor ณPaulo Carnelossi   บ Data ณ  26/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfiguracao do campo de usuario criado - utilizado na fina-บฑฑ
ฑฑบ          ณlizacao da rotina construtor de formulas                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380CfgCampo(aCfgCpo, cFormula)
Local lRet := .F.

If Empty(cFormula)
	Aviso(STR0060, STR0140, {"Ok"}) //"Atencao"###"Formula Invalida. Verifique"
	Return(.F.)
EndIf

While ! lRet
	If ParamBox({	{1,STR0122,PadR(aCfgCpo[1],20),"","","","", 85 ,.T.},;   //"Titulo"
					{3,STR0123,aCfgCpo[2],{STR0124,STR0125,STR0126},60,,.F.},;  //"Tipo"###"Caracter"###"Numerico"###"Data"
					{1,STR0127,PadR(aCfgCpo[3],12),"","","","", 30 ,.T.},;   //"Tamanho"
					{1,STR0128,PadR(aCfgCpo[4],12),"","","","", 15 ,.F.},;  //"Decimal"
					{1,"Picture",PadR(aCfgCpo[5],20),"","","","", 85 ,.F.} },STR0129, aCfgCpo,,,,,,,,.F.,)  //"Configure o Campo de Formula"
					lRet := .T.
	EndIf				
EndDo

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380PerFig บAutor ณPaulo Carnelossi    บ Data ณ  26/01/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณControle de exibicao das imagens (recurso) para aplicar  a  บฑฑ
ฑฑบ          ณtodos os periodos ou ao periodo informado                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380PerFig(aFig,nAplica)

If nAplica == 1
	aFig[1]:Show()
	aFig[2]:Hide()
ElseIf nAplica == 2
	aFig[1]:Hide()
	aFig[2]:Show()
Else
	aFig[1]:Hide()
	aFig[2]:Hide()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380Layout   บAutor ณPaulo Carnelossi  บ Data ณ  26/01/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณControle de exibicao das imagens (recurso) para layout      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380Layout(aImg,nLayout)

If nLayout == 1
	aImg[1]:Show()
	aImg[2]:Hide()
	aImg[3]:Hide()
	aImg[4]:Hide()
ElseIf nLayout == 2
	aImg[1]:Hide()
	aImg[2]:Show()
	aImg[3]:Hide()
	aImg[4]:Hide()
ElseIf nLayout == 3
	aImg[1]:Hide()
	aImg[2]:Hide()
	aImg[3]:Show()
	aImg[4]:Hide()
Else
	aImg[1]:Hide()
	aImg[2]:Hide()
	aImg[3]:Hide()
	aImg[4]:Show()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380InsCampo บAutor ณPaulo Carnelossi  บ Data ณ  26/01/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInsere  campo definido por usuario                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380InsCampo(aCpoSel,oCampos,aCpoUsr)
Local aRet	:= {}
Local aAuxUsr := {}
Local cCpoUsr
Local nX
Local aColAux := {}

For nX := 1 TO Len(aColTitle)
	aAdd(aColAux, aColTitle[nX])
Next	

If ParamBox({	{1,STR0122,SPACE(20),"","","","", 85 ,.T.},;   //"Titulo"
				{3,STR0123,2,{STR0124,STR0125,STR0126},60,,.F.},;  //"Tipo"###"Caracter"###"Numerico"###"Data"
				{1,STR0127,12,"","","","", 30 ,.T.},;   //"Tamanho"
				{1,STR0128,0,"","","","", 15 ,.F.},;  //"Decimal"
				{1,"Picture",SPACE(20),"","","","", 85 ,.F.},; 
				{1,STR0115,SPACE(60),"","","","", 85 ,.T.}; //"Formula"
			 },STR0130, aRet,,,,,,,,.F.,) //"Configuracoes"
	
	Do Case
		Case aRet[2]==1
			cTipo := "C"
		Case aRet[2]==2
			cTipo := "N"
		Case aRet[2]==3
			cTipo := "D"
	EndCase
	
	aAuxUsr := { NIL, aRet[1], cTipo, aRet[3], aRet[4], aRet[5], aRet[6] }
	
	cCpoUsr := C380CpoUsr(aCpoSel)
	
	If cCpoUsr != NIL
		aAuxUsr[1] := cCpoUsr
	    aAdd(aCpoSel, { .T., Len(aCpoSel)+1, aAuxUsr[2], aAuxUsr[1]} )
	    aAdd(aCpoUsr, { aAuxUsr[1], aAuxUsr[3], aAuxUsr[6], aAuxUsr[4],aAuxUsr[5], aAuxUsr[7] } )
		oCampos:Refresh()
		oCampos:SetFocus()
	EndIf	

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380CpoUsr บAutor ณPaulo Carnelossi    บ Data ณ  26/01/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna nome do campo de usuario                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380CpoUsr(aCpoSel)
Local cCpoUsr
Local nX
Local cCpoAnt := CAMPO_USUARIO

For nX := 1 TO 40 //MAXIMO 40 CAMPOS DE USUARIOS

	If Ascan(aCpoSel, {|aVal| aVal[4] == cCpoAnt+StrZero(nX,2)+"]" }) > 0
		Loop
	Else
		cCpoUsr := cCpoAnt+StrZero(nX,2)+"]"
		Exit
	EndIf

Next

If cCpoUsr == NIL
	Aviso(STR0060, STR0131, {"Ok"})  //"Atencao"###"Excesso de Coluna de Usuario (Maximo 40)."
EndIf

Return(cCpoUsr)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380EdtCpoUsrบAutor ณPaulo Carnelossi  บ Data ณ  26/01/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAlteracao de campo definido por usuario                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380EdtCpoUsr(cCampo,aCpoSel,oCampos,aCpoUsr)
Local aRet := {}
Local nPos, cTitulo, nTipo, nTamanho, nDecimal, cPicture, cExprCpo
Local aAuxUsr

If Left(cCampo,7) != CAMPO_USUARIO
	Aviso(STR0060, STR0132, {"Ok"}) //"Atencao"###"Somente e permitido alteracao em campos definidos por usuario."
	Return
EndIf

If (nPos := Ascan(aCpoUsr,{|aVal| Alltrim(aVal[1]) == Alltrim(cCampo)})) == 0
	Aviso(STR0060, STR0133+cCampo+STR0134, {"Ok"}) //"Atencao"###"Campo "###" definidos por usuario nao encontrado."
	Return
Else
	cTitulo := aCpoSel[oCampos:nAt, 3]
	Do Case
		Case aCpoUsr[nPos, 2] == "C"
			nTipo := 1
		Case aCpoUsr[nPos, 2] == "N"
			nTipo := 2
		Case aCpoUsr[nPos, 2] == "D"
			nTipo := 3
	EndCase
	nTamanho := aCpoUsr[nPos,4] 
	nDecimal := aCpoUsr[nPos,5]
	cPicture := aCpoUsr[nPos,3]
	cExprCpo := aCpoUsr[nPos,6]
EndIf
	

If ParamBox({	{1,STR0122,PadR(cTitulo,20),"","","","", 85 ,.T.},;   //"Titulo"
				{3,STR0123,nTipo,{STR0124,STR0125,STR0126},60,,.F.},;  //"Tipo"###"Caracter"###"Numerico"###"Data"
				{1,STR0127,nTamanho,"","","","", 30 ,.T.},;   //"Tamanho"
				{1,STR0128,nDecimal,"","","","", 15 ,.F.},;  //"Decimal"
				{1,STR0135,PadR(cPicture,20),"","","","", 85 ,.F.},;  //"Picture"
				{1,STR0115,PadR(cExprCpo,60),"","","","", 85 ,.T.}; //"Formula"
			 },STR0130, aRet,,,,,,,,.F.,)  //"Configuracoes"
	
	Do Case
		Case aRet[2]==1
			cTipo := "C"
		Case aRet[2]==2
			cTipo := "N"
		Case aRet[2]==3
			cTipo := "D"
	EndCase
	
	aAuxUsr := { cCampo, aRet[1], cTipo, aRet[3], aRet[4], aRet[5], aRet[6] }
    aCpoUsr[nPos] := { aAuxUsr[1], aAuxUsr[3], aAuxUsr[6], aAuxUsr[4],aAuxUsr[5], aAuxUsr[7] } 
    aCpoSel[oCampos:nAt, 3] := aAuxUsr[2]
    
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380ExcCpoUsrบAutor ณPaulo Carnelossi  บ Data ณ  26/01/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclusao de campo definido por usuario                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380ExcCpoUsr(cCampo,aCpoSel,oCampos,aCpoUsr)
Local aRet := {}, nX
Local nPos, cTitulo, nTipo, nTamanho, nDecimal, cPicture, cExprCpo
Local aAuxUsr

If Left(cCampo,7) != CAMPO_USUARIO
	Aviso(STR0060, STR0136, {"Ok"}) //"Atencao"###"Somente e permitido exclusao de campos definidos por usuario."
	Return
EndIf

If (nPos := Ascan(aCpoUsr,{|aVal| Alltrim(aVal[1]) == Alltrim(cCampo)})) == 0
	Aviso(STR0060, STR0133+cCampo+STR0134, {"Ok"}) //"Atencao"###"Campo "###" definidos por usuario nao encontrado."
	Return
Else
	cTitulo := aCpoSel[oCampos:nAt, 3]
	Do Case
		Case aCpoUsr[nPos, 2] == "C"
			nTipo := 1
		Case aCpoUsr[nPos, 2] == "N"
			nTipo := 2
		Case aCpoUsr[nPos, 2] == "D"
			nTipo := 3
	EndCase
	nTamanho := aCpoUsr[nPos,4] 
	nDecimal := aCpoUsr[nPos,5]
	cPicture := aCpoUsr[nPos,3]
	cExprCpo := aCpoUsr[nPos,6]
EndIf
	

If ParamBox({	{1,STR0122,PadR(cTitulo,20),"","","",".F.", 85 ,.T.},;   //"Titulo"
				{3,STR0123,nTipo,{STR0124,STR0125,STR0126},60,"",.F.,.F.},;  //"Tipo"###"Caracter"###"Numerico"###"Data"
				{1,STR0127,nTamanho,"","","",".F.", 30 ,.T.},;   //"Tamanho"
				{1,STR0128,nDecimal,"","","",".F.", 15 ,.F.},;  //"Decimal"
				{1,"Picture",PadR(cPicture,20),"","","",".F.", 85 ,.F.},; 
				{1,STR0115,PadR(cExprCpo,60),"","","",".F.", 85 ,.T.}; //"Formula"
			 },STR0137, aRet,,,,,,,,.F.,) //"Confirma Exclusao do Campo [Configuracoes] ? "
	
    ADEL(aCpoSel, oCampos:nAt)
    ASIZE(aCpoSel, Len(aCpoSel)-1)

    ADEL(aCpoUsr, nPos)
    ASIZE(aCpoUsr, Len(aCpoUsr)-1)

	//Renumera a Ordem dos Campos
	For nX := 1 TO Len(aCpoSel)
		aCpoSel[nX][2] := nX
	Next
	
	oCampos:Refresh()
	oCampos:SetFocus()
    
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC380Refer บAutor  ณPaulo Carnelossi    บ Data ณ  26/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida data de referencia verificando se esta dentro do     บฑฑ
ฑฑบ          ณperiodo informado                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380Refer(aPeriodo, dDatRef, nPeriodo)
Local nX, dDatIni, dDatFim, lRet := .F.

nPeriodo := 0

For nX := 1 TO Len(aPeriodo)

	dDatIni := CtoD(Subs(aPeriodo[nX], 1, 10))
	dDatFim := CtoD(Subs(aPeriodo[nX],14))
	
	If dDatRef >= dDatIni .And. dDatRef <= dDatFim
		lRet := .T.
	    nPeriodo := nX
	    Exit
	EndIf    

Next

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณC380ResolvCpo บAutor ณPaulo Carnelossi  บ Data ณ 26/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณPopula o array aResolver com os campos que deverao ser      บฑฑ
ฑฑบ          ณser transformado em expressao ADVPL                         บฑฑ
ฑฑบ          ณFuncao retorna falso se nao encontrar campo de usuario      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380ResolvCpo(aCpo_Sel, aResolver)
Local nX, nPos, nPosRes, lRet := .T.
Local cExpr := ""
For nX := 1 TO Len(aCpo_Sel)
	
	If ! aCpo_Sel[nX, 1]  //se nao estiver marcado nao exibe na tela
		Loop
	EndIf
	
	If Left(aCpo_Sel[nX, 4], 7) == CAMPO_USUARIO .And. ;
		CAMPO_USUARIO $ aCpo_Sel[nX, 6]	
		aAdd(aResolver, { aCpo_Sel[nX, 4], nX, {}})
	EndIf
	
Next

For nX := 1 TO Len(aResolver)

    nElem := aResolver[nX, 2]
    cExpr := aCpo_Sel[nElem, 6]
    
	While (nPos := At(CAMPO_USUARIO,cExpr) ) > 0
		cCampo := Subs(cExpr, nPos, 10)
		nElem := aScan(aCpo_Sel, {|aVal| Alltrim(aVal[4]) == cCampo } )
		If nElem > 0
			aAdd(aResolver[nX, 3],  { cCampo, nElem, {} } )
		Else
			Aviso(STR0060, STR0133+cCampo+STR0138, {"Ok"}) //"Atencao"###"Campo "###" nao encontrado. Verifique!"
			lRet := .F.
			Exit	
		EndIf	
		cExpr := Subs(cExpr, 1,nPos-1)+"[********]"+Subs(cExpr,nPos+10)
	EndDo
	
Next

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณC380AuxResolvบAutor  ณPaulo Carnelossi  บ Data ณ 26/01/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณTransforma as expressoes CAMPO_USUARIO em expressao ADVPL   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C380AuxResolv(aCpo_Sel, aResolver, nElem)
Local nX

For nX := 1 TO Len(aResolver)

	If ValType(aResolver[nX,3]) == "A"
		If Empty(aResolver[nX, 3])
			cCampo := aResolver[nX, 1]
			nPos 	:= aResolver[nX,  2]
		Else
			C380AuxResolv(aCpo_Sel, aResolver[nX, 3], aResolver[nX,2])
			Loop
		EndIf

		cExpr 	:= aCpo_Sel[nPos, 6]
		aCpo_Sel[nElem, 5] := StrTran( aCpo_Sel[nElem, 5], cCampo, Alltrim(cExpr) )
		aCpo_Sel[nElem, 6] := StrTran( aCpo_Sel[nElem, 6], cCampo, Alltrim(cExpr) )

	EndIf
	
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPC380TDLNRบAutor  ณ TOTVS              บ Data ณ  12/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCALCULO DO VALOR DO PERIODO EM FUNCAO DA TENDENCIA LINEAR   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION PC380TDLNR(aPeriodos)

Local nValPrev	:= 0 
Local nMv	 	:= 0
Local nMp	 	:= 0
Local nVar		:= 0
Local nVi		:= 0
Local nTemp1	:= 0
Local nTemp2	:= 0
Local nTemp3	:= 0
Local nTemp4	:= 0
Local nPeriodos	:= Len(aPeriodos)
Local nX		:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณComposicao de valores intermediarios do calculo      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to nPeriodos
	nTemp1 += aPeriodos[nX] * nx 				   		// SOMA(SP*VALOR)
	nTemp2 += nX                    					// SOMA(SP)
	nTemp3 += aPeriodos[nX]						   		// SOMA(VALOR)
	nTemp4 += nX^2					   					// SOMA(SP^2)
Next nX
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalculo do MV e MP                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nMv		:= (nPeriodos * nTemp1) - (nTemp2 * nTemp3)	// (NP * SOMA(SP*VALOR)) - (SOMA(SP) * SOMA(VALOR))
nMp		:= (nPeriodos * nTemp4) - (nTemp2 * nTemp2)	// (NP * SOMA(SP^2)) - (SOMA(SP) * SOMA(SP))
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalculo da Variacao e do VI                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nVar 	:= nMv / nMp									// MV / MP
nVi	 	:= (nTemp3 - (nVar * nTemp2)) / nPeriodos 		// (SOMA(VALOR) - (VARIACAO * (SOMA(SP))) / NP
nValPrev:= nVi + (nVar*(nPeriodos+1))					// VI + (VARIACAO*(NP+1))

RETURN nValPrev
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuDef  บAutor  ณ Pedro Pereira Lima บ Data ณ  09/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,		"AxPesqui" 		, 0 , 1},;  //"Pesquisar"
							{ STR0003, 		"Pco380View" 	, 0 , 2} }   //"Consultar"
							
Return aRotina
