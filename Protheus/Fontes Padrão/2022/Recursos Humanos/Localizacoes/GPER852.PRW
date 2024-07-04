#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "GPER852.CH"
#INCLUDE "TOPCONN.CH"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ GPER852 ³ Autor ³Marcos Kato                      ³ Data ³ 02/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ relatório de Novedadea serem notificadas ao Orgao Social.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tiago Malta ³15/04/2011³005374/2011³Criado imagem jpg optimizando a impressão   ³±±
±±³            ³          ³           ³ e acertado as posições da impressão.       ³±±
±±³Tiago Malta ³11/05/2011³009206/2011³Tratamento para a versao p11.               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso     ³ Microsiga						                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function GPER852()
Local cString		:= "SRA"
Local nomeProg 		:= "GPER852"
Local cPerg     	:= "GPER852"
Local cDesc1		:= STR0001//"Relatorio de Novedades"
Local cDesc2 		:= STR0008//"Ser  impresso de acordo com os parametros solicitados pelo"
Local cDesc3 		:= STR0009//"usuario."
Local aArea			:= GetArea()
Local cTamanho		:="P"
Local cQryF1410		:=""
Local nCont			:= 0  ,nMeses  :=0
Local cSitua		:=""  ,cCateg  :="",cNAFun   :="",cNomFun  :="",cSalMAtu :="",cSalSAtu:="",cSalSAnt:="",cSalMAnt:=""
Local cProces		:=""  ,cFilSra :="",cCC      :="",cDepto   :="",cMat     :="",cNome   :="",cData   :=""
Local cIMesRem 		:=""  ,cIDiaRem  :="",cFMesRem :="",cFDiaRem :="",cIMesRep :="",cIDiaRep:="",cFMesRep:="",cFDiaRep:=""
Local lImprime:=.F.
Private oPrint
Private cTitulo 	:= STR0001//"Relatorio de Novedade
Private aReturn 	:= {STR0010, 1,STR0011, 2, 1, 1, "",1 }//Zebrado#Administracao
Private oArial9N	:= TFont():New("Arial", 9, 9,,.T.,,,,.F.,.F.)
Private oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.F.,.F.)
Private oArial10F	:= TFont():New("Arial",10,30,,.T.,,,,.F.,.F.)
Private oArial14N	:= TFont():New("Arial",14,14,,.T.,,,,.F.,.F.)
Private cStartPath	:= GetSrvProfString("Startpath","")
Private dDataIni 		:=Ctod("  /  /  ")
Private dDataFim 		:=Ctod("  /  /  ")
Private aNovedade	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "GPER852"
wnrel:=SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,,,cTamanho,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

//================================
//MV_PAR01 - PROCESSO
//MV_PAR02 - FILIAL
//MV_PAR03 - CENTRO DE CUSTO
//MV_PAR04 - DEPARTAMENTO
//MV_PAR05 - MATRICULA
//MV_PAR06 - SITUACAO
//MV_PAR07 - CATEGORIA
//MV_PAR08 - NOME
//MV_PAR09 - DATA INICIO
//MV_PAR10 - DATA FIM
//MV_PAR11 - DATA EMISSAO
//MV_PAR12 - LUGAR
//================================
cProces:=MV_PAR01
cFilSra:=IIF(EMPTY(MV_PAR02),"",RANGESX1("RA_FILIAL",MV_PAR02))
cCC    :=IIF(EMPTY(MV_PAR03),"",RANGESX1("RA_CC"    ,MV_PAR03))
cDepto :=IIF(EMPTY(MV_PAR04),"",RANGESX1("RA_DEPTO" ,MV_PAR04))
cMat   :=IIF(EMPTY(MV_PAR05),"",RANGESX1("RA_MAT"   ,MV_PAR05))
cSitua :="'"
For nCont:=1 To Len(Alltrim(MV_PAR06))
	cSitua+=Substr(MV_PAR06,nCont,1)+"','"
Next
cSitua:=Substr(cSitua,1,Len(cSitua)-2)

If Empty(cSitua)
	cSitua:="' '"
Endif


cCateg:="'"
For nCont:=1 To Len(Alltrim(MV_PAR07))
	cCateg+=Substr(MV_PAR07,nCont,1)+"','"
Next
cCateg:=Substr(cCateg,1,Len(cCateg)-2)

If Empty(cCateg)
	cCateg:="' '"
Endif

cNome:=Iif(Empty(MV_PAR08),"",RANGESX1("RA_NOME"  ,MV_PAR08))


dDataIni 		:=MV_PAR09
dDataFim 		:=MV_PAR10


MsgRun(STR0004,STR0003, {||})//"consultando dados"#Aguarde...
//==============================================================================================================================================
//==================================Processando dados do Registro Segurado======================================================================
//==============================================================================================================================================
cQryF1410:="SELECT RA_FILIAL,RA_MAT MAT,RA_NOME NOME,RA_RG RG,RA_SALARIO SALARIO,R8_TIPOAFA TPAF,COALESCE(R8_DATAINI,'-') DTINI,COALESCE(R8_DATAFIM,'-') DTFIM, "
cQryF1410+="0        VLR,0          VLRANT "
cQryF1410+="FROM "+RETSQLNAME("SRA")+" SRA "
cQryF1410+="INNER JOIN "+RETSQLNAME("SR8")+" SR8 ON "
cQryF1410+="R8_FILIAL=RA_FILIAL "
cQryF1410+="AND R8_MAT=RA_MAT "
cQryF1410+="AND SR8.D_E_L_E_T_='' "
cQryF1410+="AND R8_DATAINI BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
cQryF1410+="AND SR8.D_E_L_E_T_='' "      
cQryF1410+="WHERE SRA.D_E_L_E_T_='' "
cQryF1410+="AND RA_PROCES = '"+cProces+"' "
If !Empty(cFilSra)
	cQryF1410+="AND "+cFilSra
Endif
If !Empty(cCC)
	cQryF1410+="AND "+cCC
Endif
If !Empty(cDepto)
	cQryF1410+="AND "+cDepto
Endif
If !Empty(cMat)
	cQryF1410+="AND "+cMat
Endif
cQryF1410+="AND RA_SITFOLH IN ("+cSitua+") "
cQryF1410+="AND RA_CATFUNC IN ("+cCateg+") "
If !Empty(cNome)
	cQryF1410+="AND "+cNome
Endif
cQryF1410+="UNION "
cQryF1410+="SELECT RA_FILIAL,RA_MAT MAT,RA_NOME NOME,RA_RG RG,RA_SALARIO SALARIO,' '        TPAF,COALESCE(R3_DATA,'-') DTINI,'-'         DTFIM, "
cQryF1410+="COALESCE(R3_VALOR,0) VLR,COALESCE(R3_ANTEAUM,0) VLRANT "
cQryF1410+="FROM "+RETSQLNAME("SRA")+" SRA "
cQryF1410+="INNER JOIN "+RETSQLNAME("SR3")+" SR3 ON "
cQryF1410+="R3_FILIAL=RA_FILIAL "
cQryF1410+="AND R3_MAT=RA_MAT "
cQryF1410+="AND R3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
cQryF1410+="AND SR3.D_E_L_E_T_='' "      
cQryF1410+="WHERE SRA.D_E_L_E_T_='' "
cQryF1410+="AND RA_PROCES = '"+cProces+"' "
If !Empty(cFilSra)
	cQryF1410+="AND "+cFilSra
Endif
If !Empty(cCC)
	cQryF1410+="AND "+cCC
Endif
If !Empty(cDepto)
	cQryF1410+="AND "+cDepto
Endif
If !Empty(cMat)
	cQryF1410+="AND "+cMat
Endif
cQryF1410+="AND RA_SITFOLH IN ("+cSitua+") "
cQryF1410+="AND RA_CATFUNC IN ("+cCateg+") "
If !Empty(cNome)
	cQryF1410+="AND "+cNome
Endif
cQryF1410+="ORDER BY RA_FILIAL,DTINI,MAT "
cQryF1410 := ChangeQuery(cQryF1410)

If Select("TRBF1410")>0
	DbSelectArea("TRBF1410")
	TRBF1410->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryF1410),"TRBF1410",.F.,.T.)

Do While TRBF1410->(!Eof())
	If Empty(TRBF1410->DTINI)
		TRBF1410->(DbSkip())
		Loop                
	Endif
	cData:=TRBF1410->DTINI
	Do While TRBF1410->(!Eof()) .And. cData==TRBF1410->DTINI
		cNAFun  :=Iif(Len(Alltrim(TRBF1410->RG))==9,Alltrim(TRBF1410->RG),Strzero(0,9-len(Alltrim(TRBF1410->RG)))+Alltrim(TRBF1410->RG))
		cNomFun	:=TRBF1410->NOME
		If TRBF1410->VLR>0

			cSalMAnt:=Transform(TRBF1410->VLR         ,"@E 99,999,999.99")
  			cSalSAnt:=Transform((TRBF1410->VLR/30)*7  ,"@E 99,999,999.99")
			lImprime:=.T.
		Else
	  		cSalMAnt:=Transform(0,"@E 99,999,999.99")
			cSalSAnt:=Transform(0,"@E 99,999,999.99")  

		Endif

		cSalMAtu:=Transform(TRBF1410->SALARIO       ,"@E 99,999,999.99")
		cSalSAtu:=Transform((TRBF1410->SALARIO/30)*7,"@E 99,999,999.99")		
	
		DbSelectArea("RCM")
		RCM->(Dbsetorder(1))
		RCM->(DbGotop())
		If DbSeek(xFilial("RCM")+TRBF1410->TPAF)
			If RCM->RCM_NOVIDA=="1"
				cIMesRem:=Substr(TRBF1410->DTINI,5,2)
				cIDiaRem:=Substr(TRBF1410->DTINI,7,2)
				cFMesRem:=Iif(DTOS(dDataFim)<TRBF1410->DTFIM,"",Substr(TRBF1410->DTFIM,5,2))
				cFDiaRem:=Iif(DTOS(dDataFim)<TRBF1410->DTFIM,"",Substr(TRBF1410->DTFIM,7,2))
				lImprime:=.T.
			ElseIF RCM->RCM_NOVIDA=="2"
				cIMesRep:=Substr(TRBF1410->DTINI,5,2)
				cIDiaRep:=Substr(TRBF1410->DTINI,7,2)
				cFMesRep:=Iif(DTOS(dDataFim)<TRBF1410->DTFIM,"",Substr(TRBF1410->DTFIM,5,2))
				cFDiaRep:=Iif(DTOS(dDataFim)<TRBF1410->DTFIM,"",Substr(TRBF1410->DTFIM,7,2))
				lImprime:=.T.
			Endif
		Endif
		If lImprime        // 1        2      3       4        5        6         7        8       9        10        11      12       13      14         15        
			Aadd(aNovedade,{cNAFun,cNomFun,cSalMAnt,cSalSAnt,cSalMAtu,cSalSAtu,cIDiaRem,cIMesRem,cFDiaRem,cFMesRem,cIDiaRep,cIMesRep,cFDiaRep,cFMesRep,cData,TRBF1410->RA_FILIAL})
			lImprime:=.F.
			cIMesRem:=""
			cIDiaRem:=""
			cFMesRem:=""
			cFDiaRem:=""
			cIMesRep:=""
			cIDiaRep:=""
			cFMesRep:=""
			cFDiaRep:=""
		Endif   
		TRBF1410->(DbSkip())
	End
	cData:=TRBF1410->DTINI
End
If Len(aNovedade)>0
	aSort(aNovedade,,,{|x,y|x[16]+x[15]+x[2]<y[16]+y[15]+y[2]})
	MsgRun(STR0002,STR0003, {||CursorWait(),RelF1410(aNovedade),CursorArrow()})//Processando dados do trabalhador#Aguarde...
	If aReturn[5]==1
		MsgRun(STR0005,STR0003, {||CursorWait(),oPrint:Preview(),CursorArrow()})//Carregando Layout#Aguarde...
	Endif
Else
	Aviso(STR0007,STR0006 ,{ "OK" } )//"Atencao"#"Nao ha informacoes para serem geradas.Verifique os parametros"
Endif
RestArea(aArea)
Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ RelF1410 ³ Autor ³Marcos Kato              ³ Data ³ 22/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Contem todo o detalhe do relatorio do Assegurado			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga						                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function RelF1410(aNovedade)
Local nCont    :=0, nFun:=0
Local cFilSra  := ""
Private cAno:=""
Private nLin	:= 0
Private nCol	:= 0

oPrint:= TMSPrinter():New( cTitulo )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se ha impressora ativa conectada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! oPrint:IsPrinterActive()
	oPrint:Setup()							//-- Escolhe a impressora
	If ! oPrint:IsPrinterActive()
		Help(" ",1,"NOPRINTGRA")			//-- Nao foi encontrada configuracao de impressora. ##Certifique-se de que as configurações da impressora estão corretas ou se há alguma impressora conectada.
		Return(Nil)
	Endif
Endif
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
//Modo de Impressao                                                           //
//oPrint:SetLandscape() - Impressao Paisagem                                  //
//oPrint:SetPortrait()  - Impressao Retrato                                   //
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
oPrint:SetLandscape()
cAno    :=aNovedade[1][15]
cFilSra :=aNovedade[1][16]
CabF1410(cAno,cFilSra)
nLin+=165
nCol:= 80
For nCont:=1 To Len(aNovedade)
	If nFun==15 .Or. Substr(cAno,1,4)<>SubStr(aNovedade[nCont][15],1,4)
		oPrint:Say(2920,nCol+60      ,MV_PAR12 ,oArial14N)
		oPrint:Say(3050,nCol+60      ,Iif(Empty(MV_PAR11),DTOC(DDATABASE),DTOC(MV_PAR11)) ,oArial14N)
		oPrint:EndPage()
		oPrint:StartPage()
		CabF1410(SubStr(aNovedade[nCont][15],1,4),cFilSra)
		nCol:= 80
		nLin+=165
		nFun:=0 
	ELSEIF aNovedade[nCont][16] <> cFilSra
		cFilSra := aNovedade[nCont][16]
		oPrint:EndPage()
		oPrint:StartPage()
		CabF1410(SubStr(aNovedade[nCont][15],1,4),cFilSra)
		nCol:= 80
		nLin+=165
		nFun:=0 	
	Endif  
	
	oPrint:Say(nLin,nCol+20   ,aNovedade[nCont][4] ,oArial9N)//Salario Semanal Anterior ao mes da Data de Referencia
	oPrint:Say(nLin,nCol+250  ,aNovedade[nCont][6] ,oArial9N)//Salario Semanal Atual
	oPrint:Say(nLin,nCol+470  ,aNovedade[nCont][3] ,oArial9N)//Salario Mensal Anterior ao mes da Data de Referencia
	oPrint:Say(nLin,nCol+690  ,aNovedade[nCont][5] ,oArial9N)//Salario Mensal Atual
	oPrint:Say(nLin,nCol+920  ,aNovedade[nCont][2] ,oArial10N)//Nome do Assegurado
	oPrint:Say(nLin,nCol+1730 ,aNovedade[nCont][1] ,oArial10N)//Numero do Assegurado
	oPrint:Say(nLin,nCol+2260 ,aNovedade[nCont][7] ,oArial10N) //dia
	oPrint:Say(nLin,nCol+2350 ,aNovedade[nCont][8] ,oArial10N) //mes
	oPrint:Say(nLin,nCol+2445 ,aNovedade[nCont][9] ,oArial10N) //dia
	oPrint:Say(nLin,nCol+2540 ,aNovedade[nCont][10],oArial10N) //mes
	oPrint:Say(nLin,nCol+2630 ,aNovedade[nCont][11],oArial10N) //dia
	oPrint:Say(nLin,nCol+2720 ,aNovedade[nCont][12],oArial10N) //mes
	oPrint:Say(nLin,nCol+2810 ,aNovedade[nCont][13],oArial10N) //dia
	oPrint:Say(nLin,nCol+2900 ,aNovedade[nCont][14],oArial10N) //mes
	nLin+=82                                                 
	cAno    := aNovedade[nCont][15] 
	nFun++
Next
oPrint:Say(2920,nCol+60      ,MV_PAR12 ,oArial14N)
oPrint:Say(3050,nCol+60      ,Iif(Empty(MV_PAR11),DTOC(DDATABASE),DTOC(MV_PAR11)) ,oArial14N)

oPrint:EndPage()
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ CabF1410  ³ Autor ³Marcos Kato             ³ Data ³ 02/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Cabecalho do relatorio Novedades  					       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga						                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function CabF1410(cAno,cFilSra)

Local cNomEmp:="",cCGCEmp:=""
Local aEmpCor:={}
Local nPos   := 0   

	aEmpCor     := FWLoadSM0()
	nPos        := aScan( aEmpcor , { |x| x[1] == cEmpant .and. x[2] == cFilSra } )
	
	IF nPos > 0
		cCGCEmp:=Substr(Alltrim(aEmpCor[nPos][SM0_CGC]),1,9)
		cNomEmp:=IIF(EMPTY(aEmpCor[nPos][SM0_NOME]),aEmpCor[nPos][SM0_NOMRED],aEmpCor[nPos][SM0_NOME])
	ENDIF 
		
	oPrint:Saybitmap(50,70,cStartPath+"F1410"+".JPG",3100,2230)
	nCol:=550
	nLin:=290                         
	If Substr(Dtos(dDataIni),1,4) == Substr(cAno,1,4) .And. Substr(Dtos(dDataFim),1,4) == Substr(cAno,1,4)	
		oPrint:Say(nLin,nCol+1190  ,Substr(Dtos(dDataIni),7,2),oArial14N)
		oPrint:Say(nLin,nCol+1320  ,Substr(Dtos(dDataIni),5,2),oArial14N)
		oPrint:Say(nLin,nCol+1465  ,Substr(Dtos(dDataIni),3,2),oArial14N)    
		oPrint:Say(nLin,nCol+1720  ,Substr(Dtos(dDataFim),7,2),oArial14N)
		oPrint:Say(nLin,nCol+1870  ,Substr(Dtos(dDataFim),5,2),oArial14N)
		oPrint:Say(nLin,nCol+2010  ,Substr(Dtos(dDataFim),3,2),oArial14N)                                                   
	ElseIf Substr(Dtos(dDataIni),1,4) == Substr(cAno,1,4) .And. Substr(Dtos(dDataFim),1,4) <> Substr(cAno,1,4)		
		oPrint:Say(nLin,nCol+1190  ,Substr(Dtos(dDataIni),7,2),oArial14N)
		oPrint:Say(nLin,nCol+1320  ,Substr(Dtos(dDataIni),5,2),oArial14N)
		oPrint:Say(nLin,nCol+1465  ,Substr(Dtos(dDataIni),3,2),oArial14N)    
		oPrint:Say(nLin,nCol+1720  ,"31",oArial14N)
		oPrint:Say(nLin,nCol+1870  ,"12",oArial14N)
		oPrint:Say(nLin,nCol+2010  ,Substr(cAno,3,2),oArial14N)
	ElseIf Substr(Dtos(dDataIni),1,4) <> Substr(cAno,1,4) .And. Substr(Dtos(dDataFim),1,4) == Substr(cAno,1,4)		
		oPrint:Say(nLin,nCol+1190  ,"01",oArial14N)
		oPrint:Say(nLin,nCol+1320  ,"01",oArial14N)
		oPrint:Say(nLin,nCol+1465  ,Substr(Dtos(dDataFim),3,2),oArial14N)    
		oPrint:Say(nLin,nCol+1720  ,Substr(Dtos(dDataFim),7,2),oArial14N)
		oPrint:Say(nLin,nCol+1870  ,Substr(Dtos(dDataFim),5,2),oArial14N)                                               
		oPrint:Say(nLin,nCol+2010  ,Substr(Dtos(dDataFim),3,2),oArial14N)
	ElseIf Substr(Dtos(dDataIni),1,4) <> Substr(cAno,1,4) .And. Substr(Dtos(dDataFim),1,4) <> Substr(cAno,1,4)	
		oPrint:Say(nLin,nCol+1190  ,"01",oArial14N)
		oPrint:Say(nLin,nCol+1320  ,"01",oArial14N)
		oPrint:Say(nLin,nCol+1465  ,Substr(cAno,3,2),oArial14N)
		oPrint:Say(nLin,nCol+1720  ,"31",oArial14N)
		oPrint:Say(nLin,nCol+1870  ,"12",oArial14N)
		oPrint:Say(nLin,nCol+2010  ,Substr(cAno,3,2),oArial14N)
	Endif
	nLin+=190
	oPrint:Say(nLin,nCol+450  ,cNomEmp ,oArial10N)
	oPrint:Say(nLin,nCol+1270 , Substr(cCgcEmp,1,1) ,oArial10N)
	oPrint:Say(nLin,nCol+1320 , Substr(cCgcEmp,2,1) ,oArial10N)
	oPrint:Say(nLin,nCol+1380 , Substr(cCgcEmp,3,1) ,oArial10N)
	oPrint:Say(nLin,nCol+1440 , Substr(cCgcEmp,4,1) ,oArial10N)
	oPrint:Say(nLin,nCol+1500 , Substr(cCgcEmp,5,1) ,oArial10N)
	oPrint:Say(nLin,nCol+1550 , Substr(cCgcEmp,6,1) ,oArial10N)
	oPrint:Say(nLin,nCol+1610 , Substr(cCgcEmp,7,1) ,oArial10N)
	oPrint:Say(nLin,nCol+1670 , Substr(cCgcEmp,8,1) ,oArial10N)
	oPrint:Say(nLin,nCol+1720 , Substr(cCgcEmp,9,1) ,oArial10N)

Return 