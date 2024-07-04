#Include "Ctbr240.Ch"
#Include "PROTHEUS.Ch"

#DEFINE TAM_VALOR	16

// 17/08/2009 -- Filial com mais de 2 caracteres

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR240  � Autor � Cicero J. Silva   	� Data � 04.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete 2 Entidades filtrada pela terceira Entidade	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Ctbr240      											  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nenhum       											  ���
�������������������������������������������������������������������������Ĵ��
���Uso 		 � SIGACTB      											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function CTBR240()

Local aArea := GetArea()
Local oReport          
Local lOk := .T.
Local lAtSlComp		:= Iif(GETMV("MV_SLDCOMP") == "S",.T.,.F.)

PRIVATE cTipoAnt	:= ""
PRIVATE cPerg	 	:= "CTR240"
PRIVATE nomeProg  	:= "CTBR240"  
PRIVATE titulo

//��������������������������������������������������������������Ŀ
//� Mostra tela de aviso - atualizacao de saldos				 �
//����������������������������������������������������������������
cMensagem := OemToAnsi(STR0027)+chr(13)  		//"Caso nao atualize os saldos compostos na"
cMensagem += OemToAnsi(STR0028)+chr(13)  		//"emissao dos relatorios(MV_SLDCOMP ='N'),"
cMensagem += OemToAnsi(STR0029)+chr(13)  		//"rodar a rotina de atualizacao de saldos "

IF !lAtSlComp
	If !MsgYesNo(cMensagem,OemToAnsi(STR0030))	//"ATEN��O"
		lOk := .F.
	EndIf
Endif

If lOk
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

//Limpa os arquivos tempor�rios 
CTBGerClean()
	
RestArea(aArea)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ReportDef � Autor � Cicero J. Silva    � Data �  01/08/06  ���
�������������������������������������������������������������������������͹��
���Descricao � Definicao do objeto do relatorio personalizavel e das      ���
���          � secoes que serao utilizadas                                ���
�������������������������������������������������������������������������͹��
���Parametros� aCtbMoeda  - Matriz ref. a moeda                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local oSection1
Local oSection2 
Local oTotais

Local cDesc1 		:= OemToAnsi(STR0001) //"Este programa ira imprimir o Balancete de 2 Entidades "
Local cDesc2 		:= OemToansi(STR0002) //"fitrando o saldo pela terceira Entidade. Utilizar esse "
Local cDesc3		:= OemToAnsi(STR0003) //"relatorio, caso utilize C.C/Item/Cl.Valor."		

Local aTamCC    	:= TamSX3("CTT_CUSTO")
Local aTamCCRes 	:= TamSX3("CTT_RES")
Local aTamConta		:= TamSX3("CT1_CONTA")
Local aTamCtaRes	:= TamSX3("CT1_RES")
Local aCtbMoeda		:= {}
                                            
Local nDivide		:= 1

Local bCdEnt1		:= ""
Local bCdEnt1RES	:= ""
Local bCdEnt2		:= ""
Local bCdEnt2RES	:= ""

//"Balancete de 2 Entidades filtrada pela Terceira Entidade"
oReport := TReport():New(nomeProg,OemToAnsi(STR0004),cPerg,{|oReport| Pergunte(cPerg,.F.),Iif(F240Valid(@aCtbMoeda,@nDivide),ReportPrint(oReport,aCtbMoeda,nDivide),oReport:CancelPrint())},cDesc1+cDesc2+cDesc3)
oReport:SetLandScape(.T.)

// Sessao 1
oSection1 := TRSection():New( oReport, STR0038, {"cArqTmp"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)	//"1a. Entidade Cont�bil"
oReport:SetTotalInLine(.F.)
oReport:EndPage(.T.)

TRCell():New(oSection1,"ENTID1"	, "cArqTmp", STR0031,/*Picture*/,aTamConta[1],/*lPixel*/,/*bCodeBlock*/)	// "CODIGO"
TRCell():New(oSection1,"DESCENT1", "cArqTmp",,/*Picture*/,,/*lPixel*/,/*bCodeBlock*/)

oSection1:Cell("DESCENT1"):HideHeader()

// Sessao 2
oSection2 := TRSection():New(oReport, STR0039,{"cArqTmp"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)	//"2a. Entidade Cont�bil"

TRCell():New(oSection2,"ENTID2"	, "cArqTmp", STR0031,/*Picture*/,aTamConta[1],/*lPixel*/,/*bCodeBlock*/ ) // "CODIGO"       
TRCell():New(oSection2,"DESCENT2", "cArqTmp", STR0032,/*Picture*/,,/*lPixel*/,/*bCodeBlock*/)		// "D  E  S  C  R  I  C  A  O"
TRCell():New(oSection2,"SALDOANT", "cArqTmp", STR0033,/*Picture*/,TAM_VALOR	,/*lPixel*/,/*bCodeBlock*/,"RIGHT",,"RIGHT")	// "SALDO ANTERIOR"
TRCell():New(oSection2,"SALDODEB", "cArqTmp", STR0034,/*Picture*/,TAM_VALOR	,/*lPixel*/,/*bCodeBlock*/,"RIGHT",,"RIGHT")	// "DEBITO"
TRCell():New(oSection2,"SALDOCRD", "cArqTmp", STR0035,/*Picture*/,TAM_VALOR	,/*lPixel*/,/*bCodeBlock*/,"RIGHT",,"RIGHT")	// "CREDITO"
TRCell():New(oSection2,"MOVIMENTO","cArqTmp", STR0036	,/*Picture*/,TAM_VALOR	,/*lPixel*/,/*bCodeBlock*/,"RIGHT",,"RIGHT")	// "MOVIMENTO PERIODO"
TRCell():New(oSection2,"SALDOATU","cArqTmp", STR0037	,/*Picture*/,TAM_VALOR	,/*lPixel*/,/*bCodeBlock*/,"RIGHT",,"RIGHT")	// "SALDO ATUAL"

oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage()
                                    	
oTotais := TRSection():New( oReport,STR0040,,, .F., .F. )	//"Total"

TRCell():New( oTotais, "TOT",,,/*Picture*/,78,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oTotais, "TOT_DEBITO"	,,,/*Picture*/,TAM_VALOR,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")
TRCell():New( oTotais, "TOT_CREDITO",,,/*Picture*/,TAM_VALOR,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")
TRCell():New( oTotais, "TOT_MOV",,,/*Picture*/,TAM_VALOR+1,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")

oTotais:Cell("TOT_DEBITO"):HideHeader()
oTotais:Cell("TOT_CREDITO"):HideHeader()
oTotais:Cell("TOT_MOV"):HideHeader()

Return oReport

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint� Autor � Cicero J. Silva    � Data �  14/07/06  ���
�������������������������������������������������������������������������͹��
���Descricao � Definicao do objeto do relatorio personalizavel e das      ���
���          � secoes que serao utilizadas                                ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,aCtbMoeda,nDivide)

Local oSection1 	:= oReport:Section(1)
Local oSection2		:= oReport:Section(2)
Local oTotais		:= oReport:Section(3)
Local cArqTmp   	:= ""

Local aSetOfBook 	:= CTBSetOf(mv_par12)	  
Local nDecimais 	:= DecimalCTB(aSetOfBook,mv_par14)
Local cDescMoeda 	:= aCtbMoeda[2]
Local cPicture 		:= aSetOfBook[4]
Local dDataLP  		:= mv_par30
Local dDataFim 		:= mv_par02
Local lPulaPag		:= (mv_par23==1)
Local lNormal1E		:= (mv_par24==1)
Local lNormal2E		:= (mv_par25==1)
Local lImpAntLP		:= (mv_par29==1)
Local lPrintZero	:= (mv_par27==1)
Local lVlrZerado	:= (mv_par13==1) 
Local lMov 			:= (mv_par22==1)
Local lPula	  		:= (mv_par26==1) 

Local nTamCC		:= (TamSX3("CTT_CUSTO")[1])
Local nTamItem		:= (TamSX3("CTD_ITEM")[1])
Local nTamClVl		:= (TamSX3("CTH_CLVL")[1])    
Local cConta		:= Space((TamSX3("CT1_CONTA")[1]))
Local nTamDesCC  	:= Len(CriaVar("CTT->CTT_DESC"+mv_par14))
Local nTamDesCta 	:= Len(CriaVar("CT1->CT1_DESC"+mv_par14))

Local cSegAte 	   	:= mv_par17 // Imprimir ate o Segmento?
Local nDigitAte		:= 0
Local cEntid1		:= ""
Local cEntid2		:= ""
Local cFiltroEnt	:= ""
Local cCodFilEnt	:= mv_par06 //Codigo de filtro da 3a. Entidade
Local cSayEnt1		:= ""
Local cSayEnt2		:= ""
Local cCustoIni		:= ""
Local cCustoFim		:= ""
Local cItemIni		:= ""
Local cItemFim		:= ""
Local cClVlIni		:= ""
Local cClVlFim		:= ""
Local nTotEnt1Db	:= 0
Local nTotEnt1Cr	:= 0                     
Local nTotEnt2Db	:= 0                     
Local nTotEnt2Cr	:= 0                     
Local cEnt1Ant		:= ""
Local cSepara1		:= ""
Local cSepara2		:= ""
Local cMascara1		:= ""
Local cMascara2		:= ""
Local lColDbCr 		:= If(cPaisLoc $ "RUS",.T.,.F.) // Disconsider cTipo in ValorCTB function, setting cTipo to empty
Local lRedStorn		:= If(cPaisLoc $ "RUS",SuperGetMV("MV_REDSTOR",.F.,.F.),.F.) // CAZARINI - 20/06/2017 - Parameter
Local nTotMov1		:= 0
Local nTotMov2		:= 0
Local bNormal		:= { || cArqTmp->NORMAL }

//Primeira Entidade
Do Case
	Case mv_par03 == 1
		cEntid1		:= 'CTT' //C.Custo
		cSayEnt1	:= CtbSayApro("CTT")	
		cCustoIni	:=	mv_par07 
		cCustoFim	:=	mv_par08
	Case mv_par03 == 2
		cEntid1		:= 'CTD' //Item
		cSayEnt1	:= CtbSayApro("CTD")
		cItemIni	:= mv_par07
		cItemFim	:= mv_par08                     
	Case mv_par03 == 3
		cEntid1	:= 'CTH' //Cl.Valor	
		cSayEnt1	:= CtbSayApro("CTH")	
		cClVlIni	:= mv_par07
		cClVlFim	:= mv_par08
EndCase

//Segunda Entidade
Do Case
	Case mv_par04 == 1
		cEntid2		:= 'CTT' //C.Custo
		cSayEnt2	:= CtbSayApro("CTT")		
		cCustoIni	:= mv_par09
		cCustoFim	:= mv_par10
		If lRedStorn
			bNormal := {|| Posicione("CTT",1,xFilial("CTT")+padr(cArqTmp->ENTID2,nTamCC),"CTT_NORMAL") }		
		Endif
	Case mv_par04 == 2
		cEntid2		:= 'CTD' //Item
		cSayEnt2	:= CtbSayApro("CTD")		
		cItemIni	:= mv_par09
		cItemFim	:= mv_par10
		If lRedStorn
			bNormal := {|| Posicione("CTD",1,xFilial("CTD")+padr(cArqTmp->ENTID2,nTamItem),"CTD_NORMAL") }		
		Endif
	Case mv_par04 == 3
		cEntid2		:= 'CTH' //Cl.Valor	
		cSayEnt2	:= CtbSayApro("CTH")		
		cClVlIni	:= mv_par09
		cClVlFim	:= mv_par10	
		If lRedStorn
			bNormal := {|| Posicione("CTH",1,xFilial("CTH")+padr(cArqTmp->ENTID2,nTamClVl),"CTH_NORMAL") }		
		Endif
EndCase       
	
//Arquivo a ser filtrado.                                                                       
Do Case
	Case (cEntid1 == 'CTT' .And. cEntid2 == 'CTD') .Or.(cEntid1 == 'CTD' .And. cEntid2 == 'CTT')  
		cFiltroEnt	:= 'CTH'                                     
		cClVlIni	:= Space(nTamClVl)
		cClVlFim	:= Replicate('Z',nTamClVl)
	Case (cEntid1 == 'CTT' .And. cEntid2 == 'CTH') .Or.(cEntid1 == 'CTH' .And. cEntid2 == 'CTT')  
		cFiltroEnt	:= 'CTD'
		cItemIni	:= Space(nTamItem)
		cItemFim	:= Replicate('Z',nTamItem)	
	Case (cEntid1 == 'CTD' .And. cEntid2 == 'CTH') .Or.(cEntid1 == 'CTH' .And. cEntid2 == 'CTD')   
		cFiltroEnt	:= 'CTT'                  
		cCustoIni	:= Space(nTamCC)
		cCustoFim	:= Replicate('Z',nTamCC)	
EndCase
	
//��������������������������������������������������������������������������Ŀ
//� Carrega titulo do relatorio de acordo com os parametros					 �
//����������������������������������������������������������������������������
If mv_par11 == 1
	Titulo:=	OemToAnsi(STR0007)//"BALANCETE ANALITICO DE  "
ElseIf mv_par11 == 2
	Titulo:=	OemToAnsi(STR0008)//"BALANCETE SINTETICO DE  "
ElseIf mv_par11 == 3
	Titulo:=	OemToAnsi(STR0009)//"BALANCETE DE  "
EndIf

Titulo += Alltrim(Upper(cSayEnt1)) + " / " + Alltrim(Upper(cSayEnt2))
Titulo += 	OemToAnsi(STR0010) + DTOC(mv_par01) + OemToAnsi(STR0011) + Dtoc(mv_par02) + OemToAnsi(STR0012) + cDescMoeda

If mv_par16 > "1"			
	Titulo += " (" + Tabela("SL", mv_par16, .F.) + ")"
Endif

//��������������������������������������������������������������������������Ŀ
//� Atualiza pagina inicial e cabecalho customizado 						 �
//����������������������������������������������������������������������������
oReport:SetPageNumber(mv_par15) // Pagina Inicial
oReport:SetCustomText( { || CtCGCCabTR(,,,,,dDataFim,titulo,,,,,oReport) } )

//��������������������������������������������������������������������������Ŀ
//� Atualiza conteudo das celulas das secoes        		        		 �
//����������������������������������������������������������������������������
oSection2:Cell("SALDOANT"):SetBlock({|| ValorCTB(cArqTmp->SALDOANT ,,,TAM_VALOR,nDecimais,.T.,cPicture,Eval(bNormal),,,,,,lPrintZero,.F.)})
oSection2:Cell("SALDODEB"):SetBlock({|| ValorCTB(cArqTmp->SALDODEB ,,,TAM_VALOR,nDecimais,.F.,cPicture,Eval(bNormal),,,,,,lPrintZero,.F.,lColDbCr)})
oSection2:Cell("SALDOCRD"):SetBlock({|| ValorCTB(cArqTmp->SALDOCRD ,,,TAM_VALOR,nDecimais,.F.,cPicture,Eval(bNormal),,,,,,lPrintZero,.F.,lColDbCr)})
oSection2:Cell("SALDOATU"):SetBlock({|| ValorCTB(cArqTmp->SALDOATU ,,,TAM_VALOR,nDecimais,.T.,cPicture,Eval(bNormal),,,,,,lPrintZero,.F.)})

//��������������������������������������������������������������������������Ŀ
//� Imprime coluna de movimentos                    		        		 �
//����������������������������������������������������������������������������
If lMov 
	oSection2:Cell("MOVIMENTO"):SetBlock({||ValorCTB(cArqTmp->MOVIMENTO,,,TAM_VALOR,nDecimais,.T.,cPicture,Eval(bNormal),,,,,,lPrintZero,.F.)})
Else
	oSection2:Cell("MOVIMENTO"):Disable()
	oTotais:Cell("TOT_MOV"):Disable()
EndIf

If lPulaPag
	oSection1:SetPageBreak(.T.)
EndIf
      
//��������������������������������������������������������������������������Ŀ
//� Define salto de linha de acordo com o parametro "Salta linha sintetica?" �
//����������������������������������������������������������������������������
oSection2:OnPrintLine( {|| ( IIf( lPula .And. (cTipoAnt == "1" .Or. (cArqTmp->TIPOENT2 == "1" .And. cTipoAnt == "2")), oReport:SkipLine(),NIL),;
								 cTipoAnt := cArqTmp->TIPOENT2 ) })

// Primeira Entidade
Do Case
	Case mv_par03 == 1
		nBook1		:= 6    
	Case mv_par03 == 2
		nBook1		:= 7         
	Case mv_par03 == 3
		nBook1	:= 8                    
EndCase
	
// Segunda Entidade
Do Case
	Case mv_par04 == 1
		nBook2		:= 6                       
	Case mv_par04 == 2
		nBook2		:= 7
	Case mv_par04 == 3
		nBook2		:= 8
EndCase       
	
cMascara1	:= IIF (Empty(aSetOfBook[nBook1]),"",RetMasCtb(aSetOfBook[nBook1],@cSepara1))// Mascara da Primeira Entidade
cMascara2	:= IIF (Empty(aSetOfBook[nBook2]),"",RetMasCtb(aSetOfBook[nBook2],@cSepara2))// Mascara da Segunda Entidade
                                        
oSection1:Cell("ENTID1"):SetTitle(Upper(cSayEnt1))
If lNormal1E                               
	oSection1:Cell("ENTID1"):SetBlock( {|| EntidadeCTB(cArqTmp->ENTID1,0,0,20,.F.,cMascara1,cSepara1,,,,,.F.) } )
Else
	oSection1:Cell("ENTID1"):SetBlock( {|| EntidadeCTB(cArqTmp->ENTRES1,0,0,20,.F.,cMascara1,cSepara1,,,,,.F.) } )
EndIf

If lNormal2E
	oSection2:Cell("ENTID2"):SetBlock( {|| Iif(cArqTmp->TIPOENT2=="1","","  ")+EntidadeCTB(cArqTmp->ENTID2,0,0,20,.F.,cMascara2,cSepara2,,,,,.F.) } )
Else
	oSection2:Cell("ENTID2"):SetBlock( {|| Iif(cArqTmp->TIPOENT2=="1","","  ")+EntidadeCTB(cArqTmp->ENTRES2,0,0,20,.F.,cMascara2,cSepara2,,,,,.F.) } )
EndIf                      

oSection1:Cell("DESCENT1"):SetSize(nTamDesCC)
oSection2:Cell("DESCENT2"):SetSize(nTamDesCta)

//��������������������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao							  	 	 �
//����������������������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
		CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
		 mv_par01,mv_par02,"CTY","",cConta,cConta,cCustoIni,cCustoFim,cItemIni,cItemFim,;
		  cClVlIni,cClVlFim,mv_par14,mv_par16,aSetOfBook,mv_par18,;
		   mv_par19,mv_par20,mv_par21,!lMov,.F.,2,cEntid1,lImpAntLP,dDataLP,nDivide,lVlrZerado,;
		    cFiltroEnt,cCodFilEnt)},;
			 OemToAnsi(OemToAnsi(STR0015)),;  //"Criando Arquivo Tempor�rio..."
			  OemToAnsi(STR0004)+Alltrim(Upper(cSayEnt1)) + " / " + Alltrim(Upper(cSayEnt2)))     //"Balancete Verificacao "

//�������������������������������������������������������������������������������Ŀ
//� Inicia a impressao do relatorio                                               �
//���������������������������������������������������������������������������������
dbSelectArea("cArqTmp")
dbGotop()     

oReport:SetMeter(cArqTmp->(RecCount()))

//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial 
//nao esta disponivel e sai da rotina.
If !( RecCount() == 0 .And. !Empty(aSetOfBook[5]) )

	cEnt1Ant := cArqTmp->ENTID1

	Do While !Eof() .And. !oReport:Cancel()

	    oReport:IncMeter()

		If f240Fil(cSegAte, nDigitAte,cMascara2)
			dbSkip()
			Loop
		EndIF		

		//Imprime Section(1)
		oSection1:Init()       
     	oSection1:PrintLine()
	    oSection1:Finish()

     	oReport:ThinLine()    

		//Imprime Section(2)
   	 	oSection2:Init()

		Do While !Eof() .And. cEnt1Ant == cArqTmp->ENTID1

	     	oSection2:PrintLine()

			nTotEnt1Db	+= f240Soma("D",cSegAte)
			nTotEnt1Cr	+= f240Soma("C",cSegAte)
			nTotEnt2Db	+= f240Soma("D",cSegAte)
			nTotEnt2Cr	+= f240Soma("C",cSegAte)
			
			If cPaisLoc $ "RUS"
				nTotMov1	+= RedStorTt(nTotEnt1Db,nTotEnt1Cr,cArqTmp->TIPOENT2,cArqTmp->NORMAL,"T")
				nTotMov2	+= RedStorTt(nTotEnt2Db,nTotEnt2Cr,cArqTmp->TIPOENT2,cArqTmp->NORMAL,"T")
			Endif
			
			dbSkip()

		EndDo
	    oSection2:Finish()

            //Imprime o totalizador da entidade
		If (cEnt1Ant <> cArqTmp->ENTID1) .And. !Empty(cEnt1Ant)

			If mv_par24 == 2 .and. cArqTmp->TIPOENT1 == "2" //Se Imprime cod. reduzido da Entidade 1 e � analitica
				cTitEnt := EntidadeCTB(cEnt1RsAnt,0,0,20,.F.,cMascara1,cSepara1,,,,,.F.)
			Else //Se Imprime cod. normal do Item
				cTitEnt := EntidadeCTB(cEnt1Ant,0,0,20,.F.,cMascara1,cSepara1,,,,,.F.)
			Endif 			               

			oTotais:Cell("TOT"):SetTitle(OemToAnsi(STR0020)+ Upper(cSayEnt1)+ " : " + cTitEnt) 		//"T O T A I S  "			
			oTotais:Cell("TOT_DEBITO"	):SetBlock( { || ValorCTB(nTotEnt1Db,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) } )
			oTotais:Cell("TOT_CREDITO"):SetBlock( { || ValorCTB(nTotEnt1Cr,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) } )
			If lMov
				If lRedStorn
					nTotMov := nTotMov1
					oTotais:Cell("TOT_MOV"):SetBlock( { || ValorCTB(nTotMov,,,TAM_VALOR,nDecimais,.T.,cPicture,Iif(nTotMov<0,"1","2"),,,,,,lPrintZero,.F.,lColDbCr) } )
				Else
					nTotMov := (nTotEnt1Cr - nTotEnt1Db)
					If Round(NoRound(nTotMov,3),2) < 0
						oTotais:Cell("TOT_MOV"):SetBlock( { || ValorCTB(nTotMov,,,TAM_VALOR,nDecimais,.T.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) } )
					ElseIf Round(NoRound(nTotMov,3),2) >= 0
						oTotais:Cell("TOT_MOV"):SetBlock( { || ValorCTB(nTotMov,,,TAM_VALOR,nDecimais,.T.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) } )
					EndIf
				Endif
			EndIf
			
			oTotais:Init()
			oTotais:PrintLine()
			oTotais:Finish()

			nTotEnt1Db	:= 0
			nTotEnt1Cr	:= 0        
			nTotMov1	:= 0

		Endif	  

		If mv_par23 == 1 .And. ! Empty(cEnt1Ant)
			If cEnt1Ant <> cArqTmp->ENTID1 .And. !Eof() //Se o Item atual for diferente do Item anterior
			 	oReport:EndPage(.T.) // Quebra direto
			EndIf
		Endif
	 	cEnt1Ant := cArqTmp->ENTID1

	EndDo

	oTotais:Cell("TOT"):SetTitle(OemToAnsi(STR0019))  		//"T O T A I S  D O  P E R I O D O : "
	oTotais:Cell("TOT_DEBITO"	):SetBlock( { || ValorCTB(nTotEnt2Db,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) } )
	oTotais:Cell("TOT_CREDITO"):SetBlock( { || ValorCTB(nTotEnt2Cr,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) } )

	If lMov
		If lRedStorn
			nTotMov := nTotMov2
			If lMov
				oTotais:Cell("TOT_MOV"):SetBlock( { || ValorCTB(nTotMov,,,TAM_VALOR,nDecimais,.T.,cPicture,Iif(nTotMov<0,"1","2"),,,,,,lPrintZero,.F.,lColDbCr) } )
			EndIf
		Else
			nTotMov := (nTotEnt2Cr - nTotEnt2Db)
			If lMov
				If Round(NoRound(nTotMov,3),2) < 0
					oTotais:Cell("TOT_MOV"):SetBlock( { || ValorCTB(nTotMov,,,TAM_VALOR,nDecimais,.T.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) } )
				ElseIf Round(NoRound(nTotMov,3),2) >= 0
					oTotais:Cell("TOT_MOV"):SetBlock( { || ValorCTB(nTotMov,,,TAM_VALOR,nDecimais,.T.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) } )
				EndIf
			EndIf
		Endif
	EndIf
	
	oTotais:Init()
	oTotais:PrintLine()
	oTotais:Finish()

EndIf
	
dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
If Select("cArqTmp") == 0
	Ferase(cArqTmp+GetDBExtension())
	FErase("cArqInd"+OrdBagExt())
EndIf	
dbselectArea("CT2")

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �f240Soma  �Autor  �Cicero J. Silva     � Data �  24/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR195                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function f240Soma(cTipo,cSegAte)

Local nRetValor		:= 0

	If mv_par11 == 1					// So imprime Sinteticas - Soma Sinteticas
		If cArqTmp->TIPOENT2 == "1" .And. cArqTmp->NIVEL1
			If cTipo == "D"
				nRetValor := cArqTmp->SALDODEB
			ElseIf cTipo == "C"
				nRetValor := cArqTmp->SALDOCRD
			EndIf
		EndIf
	Else								// Soma Analiticas
		If Empty(cSegAte)				//Se nao tiver filtragem ate o nivel
			If cArqTmp->TIPOENT2 == "2"
				If cTipo == "D"
					nRetValor := cArqTmp->SALDODEB
				ElseIf cTipo == "C"
					nRetValor := cArqTmp->SALDOCRD
				EndIf
			EndIf
		Else							//Se tiver filtragem, somo somente as sinteticas
			If cArqTmp->TIPOENT2 == "1" .And. cArqTmp->NIVEL1
				If cTipo == "D"
					nRetValor := cArqTmp->SALDODEB
				ElseIf cTipo == "C"
					nRetValor := cArqTmp->SALDOCRD
				EndIf
			EndIf
	   	Endif
	EndIf                     
	
Return nRetValor                                                                         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �f240Fil   �Autor  �Cicero J. Silva     � Data �  24/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR240                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function f240Fil(cSegAte, nDigitAte,cMascara2)

Local lDeixa	:= .F.
Local nCont    := 0

	If mv_par11 == 1					// So imprime Sinteticas
		If cArqTmp->TIPOENT2 == "2"
			lDeixa := .T.
		EndIf
	ElseIf mv_par11 == 2				// So imprime Analiticas
		If cArqTmp->TIPOENT2 == "1"
			lDeixa := .T.
		EndIf
	EndIf

	// Verifica Se existe filtragem Ate o Segmento
	//Filtragem ate o Segmento ( antigo nivel do SIGACON)		
	If !Empty(cSegAte)
		For nCont := 1 to Val(cSegAte)
			nDigitAte += Val(Subs(cMascara2,nCont,1))	
		Next
		If Len(Alltrim(cArqTmp->ENTID2)) > nDigitAte
			lDeixa := .T.
		Endif
	EndIf
	If mv_par11 == 2			// Saldos Zerados nao serao impressos
		If (Abs(cArqTmp->SALDOANT)+Abs(cArqTmp->SALDOATU)+Abs(cArqTmp->SALDODEB)+Abs(cArqTmp->SALDOCRD)) == 0
			lDeixa := .T.
		EndIf
	EndIf                                        

dbSelectArea("cArqTmp")

Return (lDeixa)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F240Valid �Autor  � Gustavo Henrique   � Data �  10/11/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Validar o preenchimento dos parametros apos confirmar o    ���
���          � grupo de perguntas.                                        ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function f240Valid( aCtbMoeda, nDivide )

Local lOk := .T.

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)			 �
//����������������������������������������������������������������
If !ct040Valid(mv_par12) // Set Of Books
	lOk := .F.
EndIf 

If mv_par28 == 2			// Divide por cem
	nDivide := 100
ElseIf mv_par28 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par28 == 4		// Divide por milhao
	nDivide := 1000000
EndIf	

If lOk
	aCtbMoeda  	:= CtbMoeda(mv_par14,nDivide) // Moeda?
   If Empty(aCtbMoeda[1])
      Help(" ",1,"NOMOEDA")
      lOk := .F.
   Endif
Endif           

If lOk                         
	//A 1a. Entidade nao pode ser igual a 2a.Entidade
	If mv_par03 == mv_par04 	
	    MsgAlert(OemToAnsi(STR0021))//"A segunda Entidade nao pode ser a mesma que a primeira Entidade!!!"
		lOk := .F.
	EndIf
EndIf 

If lOk
	If (mv_par03 == mv_par05) .Or. (mv_par04 == mv_par05)
		MsgAlert(OemToAnsi(STR0023))//"A Entidade a ser filtrada nao pode ser a mesma que a primeira e a segunda Entidade!!!"
		lOk	:= .F.
	EndIf                                       
EndIf

If lOk               
	// A pergunta de filtro nao pode ser vazia. 
	If Empty(mv_par05)
	    MsgAlert(OemToAnsi(STR0022))//"Favor Preencher a pergunta de Filtro 3a. Entidade..."
		lOk	:= .F.	
	Endif
EndIf

Return lOk
/*/
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���Fun��o    �CtbSX1Opc   � Autor � Simone Mie Sato      � Data � 10.05.2002		���
�����������������������������������������������������������������������������������Ĵ��
���Descri��o � Chama a tela de Entidade de acordo com a opcao escolhida      		���
���          � pelo usuario no parametro.                                 			���
�����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � CtbSX1Opc()                                                   	    ���
�����������������������������������������������������������������������������������Ĵ��
��� Uso      � SigaCtb                                                   			���
�����������������������������������������������������������������������������������Ĵ��
���Parametros� cGrupo 		= Informa qual o grupo do SX1 a ser atualizado    	    ���
���          � cOrdAtu1  	= Ordem da Pergunta atual				          	    ���
���          � cOrdRet1  	= Ordem da Pergunta a ser atualizada.(1)			    ���
��� 		 � cOrdRet2   	= Ordem da Pergunta a ser atualizada.(2)	      	    ���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
/*/
Function CtbSX1Opc(cGrupo,nOrdAtu1,cOrdRet1,cOrdRet2,nTotret)

Local aSaveArea	:= GetArea()

Local nMvParAtu	:= &('mv_par'+StrZero(nOrdAtu1,2))	//Conteudo do Parametro atual.
Local cPerg1	:= ""
Local cPerg2	:= ""          
Local cRetorno1	:= ""
Local cRetorno2	:= ""

cOrdRet1	:= Iif(cOrdRet1 == Nil,"",cOrdRet1)
cOrdRet2	:= Iif(cOrdRet2 == Nil,"",cOrdRet2)

Do Case
Case nMvParAtu 	== 1 	//Se for Centro de Custo
	cSayEnt		:= UPPER(Alltrim(CtbsayApro("CTT")))                  
	cF3			:= "CTT" 
	cRetorno1	:= Space(TAMSX3("CTT_CUSTO")[1])
	cRetorno2	:= Space(TAMSX3("CTT_CUSTO")[1])
Case nMvParAtu	== 2	//Se for Item Contabil
	cSayEnt	:= UPPER(Alltrim(CtbsayApro("CTD")))	
	cF3		:= "CTD"                             
	cRetorno1	:= Space(TAMSX3("CTD_ITEM")[1]) 
	cRetorno2	:= Space(TAMSX3("CTD_ITEM")[1])		
Case nMvParAtu == 3		//Se for Classe de Valor
	cSayEnt	:= UPPER(Alltrim(CtbsayApro("CTH")))
	cF3		:= "CTH"                     
	cRetorno1	:= Space(TAMSX3("CTH_CLVL")[1]) 
	cRetorno2	:= Space(TAMSX3("CTH_CLVL")[1])		
EndCase	

If empty(cOrdRet2)
	cPerg1	:= cSayEnt + "?"
	cPerg2	:= ""
Else
	cPerg1	:= cSayEnt + OemToAnsi(STR0024)+ "?"	//DE
	cPerg2	:= cSayEnt + OemToAnsi(STR0025)+ "?"	//ATE
EndIf

CtbOpcao(@cRetorno1,@cRetorno2,cSayEnt,cPerg1,cPerg2,cF3,nTotRet,cGrupo,cOrdRet1,cOrdRet2)

If !Empty(cRetorno1)
	&("mv_par"+StrZero(cOrdRet1,2)) 	:= cRetorno1
EndIf
If !Empty(cRetorno2)
	If nTotret	== 2
		&("mv_par"+StrZero(cOrdRet2,2))		:= cRetorno2
	EndIf
EndIf

RestArea(aSaveArea)

Return .T.

/*/
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���Fun��o    �CtbOpcao    � Autor � Simone Mie Sato      � Data � 10.05.2002		���
�����������������������������������������������������������������������������������Ĵ��
���Descri��o � Monta a tela com as perguntas a serem mostradas na tela.      		���
�����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � CtbOpcao()                                                    	    ���
�����������������������������������������������������������������������������������Ĵ��
��� Uso      � SigaCtb                                                   			���
�����������������������������������������������������������������������������������Ĵ��
���Parametros� nMvParAtu	= Informa qual o grupo do SX1 a ser atualizado    	    ���
���          � cRetorno1 	= Codigo de Retorno da Entidade			         	    ���
���          � cRetorno2 	= Codigo de Retorno da Entidade         			    ���
���          � cSayEnt   	= Descrica da Entidade.                 			    ���
���          � cPerg1    	= Pergunta 1                            			    ���
���          � cPerg2    	= Pergunta 2                            			    ���
���          � cF3       	= Arquivo a ser consultado via F3	      			    ���
���          � nTotRet	   	= Numero total de Retorno        	      			    ���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
/*/
Function CtbOpcao(cRetorno1,cRetorno2,cSayEnt,cPerg1,cPerg2,cF3,nTotRet,cGrupo,cOrdRet1,cOrdRet2)

//N�o mais Utilizado

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}CB240F3
Consulta F3
@author Eduardo Ferreira Lima
@since  27/04/2017
@version 12
/*/
//-------------------------------------------------------------------

Function CB240F3()
Local cReturn

	If (readvar()=="MV_PAR06" .and. MV_PAR05= 1) ;
			.or. (readvar()$ "MV_PAR07/MV_PAR08" .and. MV_PAR03= 1) ;
			.or. (readvar()$ "MV_PAR09/MV_PAR10" .and. MV_PAR04= 1)
		cReturn:="CTT"
	Endif
	If (readvar()=="MV_PAR06" .and. MV_PAR05= 2) ;	
			.or. (readvar()$ "MV_PAR07/MV_PAR08" .and. MV_PAR03= 2) ;
			.or. (readvar()$ "MV_PAR09/MV_PAR10" .and. MV_PAR04= 2)					
		cReturn:="CTD"
	Endif	
	If (readvar()=="MV_PAR06" .and. MV_PAR05= 3) ;	
			.or. (readvar()$ "MV_PAR07/MV_PAR08" .and. MV_PAR03= 3) ;
			.or. (readvar()$ "MV_PAR09/MV_PAR10" .and. MV_PAR04= 3)
		cReturn:="CTH"					
	Endif 			
	
Return CONPAD1(,,,cReturn)		