#INCLUDE "Protheus.ch"
#INCLUDE "CSAM060.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CSAM060  ³ Autor ³ Cristina Ogura        ³ Data ³ 28/11/00      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Leitura do arquivo de Coleta de dados                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS      ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³18/07/14³TPZVUR     ³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³           ³da a limpeza.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSAM060()                                                          
Local cFiltra	:= ""			//Variavel para filtro
Local aIndFil	:= {}			//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}	//Variavel para Filtro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0003)		//"Le os arquivos da Coleta dos Dados para Pesquisa Salarial."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RB1")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RB1","1")
bFiltraBrw 	:= {|| FilBrowse("RB1",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

dbSelectArea("RB1")
dbGotop()

mBrowse(6, 1, 22, 75, "RB1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RB1",aIndFil)

dbSelectArea("RB1")
dbSetOrder(1)

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs060Ler      ³ Autor ³ Cristina Ogura   ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Leitura do arquivo dos dados para Pesquisa Salarial        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060Ler(cAlias,nReg,nOpcx)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060Ler(cAlias,nReg,nOpcx)     
Local oDlgMain
Local cDirPesq	:= ""
Local nOpca		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Private oLbx
Private aLbx		:= {}
Private aEmpresa	:= {} 
Private aDadosEmp	:= {}
Private aDadosCarg	:= {}
Private aCargosInf	:= {}
Private aFuncao		:= {}
Private cFile		:= ""
Private nHandle		:= 0
Private cPesq		:= RB1->RB1_PESQ
Private oNo 		:= LoadBitmap( GetResources(), "LBNO" )
Private oOk 		:= LoadBitmap( GetResources(), "LBOK" )

// Le as Empresas da Pesquisa Salarial
Cs060RB4(@aEmpresa)
                     
// Inicializando o listbox com valores zerados 
Aadd(aLbx,{0,"",""})

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize( , .T., 390)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T., .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE MSDIALOG oDlgMain TITLE cCadastro FROM  aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	@ aObjSize[1,1], aObjSize[1,2]		SAY OemToAnsi(STR0004)			PIXEL 	//"Indique o diretorio dos Arquivos: "
	@ aObjSize[1,1], aObjSize[1,2]+88	GET cDirPesq		 			PICTURE "@!" PIXEL SIZE 100,7;
				VALID Cs060Dir(@cDirPesq) 	
				
	@ aObjSize[1,1], aObjSize[1,2]+188	BUTTON oBtnOk PROMPT "&Ok" 	PIXEL SIZE 20,10 OF oDlgMain;
				ACTION (Cs060Monta(@aLbx,oLbx,cDirPesq),oLbx:Show(),oBtnOk:Hide())	   
	
	@ aObjSize[2,1],aObjSize[2,2] 	LISTBOX oLbx FIELDS;
				HEADER	"",OemtoAnsi(STR0005),OemToAnsi(STR0006) SIZE aObjSize[2,3],aObjSize[2,4] PIXEL;	//"Participantes"###"Status"
				FIELDSIZES 5,150,200 
	oLbx:bldblclick :={|nRow, nCol|Cs060Troca(aLbx,oLbx)}
	oLbx:SetArray(aLbx)
	oLbx:bLine:= {||{	If(aLbx[oLbx:nAt,1]==0,oNo,oOK),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3]}}
	
ACTIVATE MSDIALOG oDlgMain ON INIT 	(	EnchoiceBar(oDlgMain,{||nOpca:=1,oDlgMain:End()},;
									{|| nOpca := 2,oDlgMain:End()}),;
									oLbx:Hide()) CENTERED	

If nOpca == 1             
	Cs060Grava()
EndIf

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs060Monta   ³ Autor ³ Cristina Ogura   ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta array com os arquivos da Pesquisa Salariarl (.RET)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060Monta(nQual,aArray,aDados)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM060                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs060Monta(aArray,oObj,cDirPesq)
Local cNomeArq	:= ""
Local cStatus	:= ""                 
Local cFile		:= ""
Local cEmpresa	:= ""                               
Local cAuxCargo	:= ""
Local nLidos 	:= 0
Local nTamArq	:= 0
Local nMarcado	:= 0
Local nStatus	:= 0
Local nHdlArq	:= 0
Local xBuffer 	:= ""
Local lStatus	:= .F.       
Local nOk  		:= 0 
Local cCodPesq	:= ""         
Local cNome		:= ""
Local nx		:= 0 

//-- Tratamento de Leitura de arquivo
Private nTam	//Tamanho da linha do arquivo texto

//Verifica se Server = Linux
If IsSrvUnix()					
	nTam  := 201
Else
	nTam:= 202
EndIf

aArray := {}                          

cDirPesq := Alltrim(cDirPesq) + If( !(Substr(Alltrim(cDirPesq),Len(cDirPesq),1) $ "\/"), "\", "" )

For nx := 1 To Len(aEmpresa)
	cNomeArq := "PSAL"+aEmpresa[nx][1]+".RET"
	cNome	 := "PSAL"+aEmpresa[nx][1]
	cFile    := UPPER(cDirPesq)+ALLTRIM(cNomeArq)
	nLidos	 := 0		
	cCodPesq := ""
	
	If !FILE(cFile)
		nStatus := 1
	Else
		nHdlArq:=FOPEN(cFile,2+16)		// 2-Leitura e gravacao   16-Exclusivo
		FSEEK(nHdlArq,0,0)
		nTamArq := FSEEK(nHdlArq,0,2)
		FSEEK(nHdlArq,0,0)
		
		While nLidos <= nTamArq

			xBuffer := Space(nTam)
			FREAD(nHdlArq,@xBuffer,nTam)
			
			If 	Substr(xBuffer,1,2) == "00"						
				cCodPesq:= Substr(xBuffer,3,4)					// Codigo da pesquisa Salarial
			ElseIf 	Substr(xBuffer,1,3) == "301"
				Aadd(aFuncao,{	Substr(xBuffer,04,05),;			// Codigo do Cargo
								Substr(xBuffer,39,FWGETTAMFILIAL),;			// Codigo da Filial
								Substr(xBuffer,41,05)})			// Codigo da Funcao

			ElseIf Substr(xBuffer,1,2) == "60"				// Dados Informados da Empresas Participante	
				cEmpresa:= Substr(xBuffer,53,04)
				Aadd(aDadosEmp,{	cEmpresa,;					// Codigo da Empresa
									Substr(xBuffer,03,50),;		// Nome da Empresa
									Substr(xBuffer,57,01),;		// Porte
									Substr(xBuffer,58,04),;		// Regiao
									Substr(xBuffer,62,03),;		// Faturamento
									Substr(xBuffer,65,03),;		// Atividade
									Substr(xBuffer,68,06),;		// Nr de Funcionarios
									Substr(xBuffer,74,30),;		// Contato
									Substr(xBuffer,104,60),;	// Email
									Substr(xBuffer,164,15)})	// Fone	
									
			ElseIf Substr(xBuffer,1,2) == "70"		// Dados Informados do Cargo
				lStatus := .T.
				cAuxCargo := Substr(xBuffer,3,5)
				Aadd(aDadosCarg,{	cEmpresa,;							// Codigo da Empresa
									cAuxCargo,;							// Codigo Cargo
									Val(Substr(xBuffer,8,5)),;		// Frequencia		
									Val(Substr(xBuffer,13,12)),;		// Salario			
									Val(Substr(xBuffer,25,12)),;		// Vl Beneficio	
									Val(Substr(xBuffer,37,12)),;		// Adicionais 		
									Val(Substr(xBuffer,49,06)),;		// %Antecipacao  	
									Val(Substr(xBuffer,55,07)),;		// Horas  			
									Substr(xBuffer,62,02),;			// Dissidio			
									CtoD(Substr(xBuffer,64,08)),;		// Data Base 
									Substr(xBuffer,72,5)})				// Cod. Funcao

			ElseIf Substr(xBuffer,1,2) == "99"	// Dados Informados do Cargo						
				nStatus := 2
			EndIf
			nLidos += 200
		EndDo	                	
	EndIf	
	                        

	If !Empty(cCodPesq) .And. cCodPesq # cPesq
		cStatus := STR0012  // "ARQUIVO PERTENCE A OUTRA PESQUISA SALARIAL	          
		nMarcado:= 0
		nOK		:= 0     
	ElseIf nStatus == 1
		cStatus := STR0007	//"ARQUIVO NAO ENCONTRADO NO DIRETORIO ESPECIFICADO"
		nMarcado:= 0
		nOK		:= 0
	ElseIf nStatus == 2 .And. lStatus
		cStatus := STR0008	//"ARQUIVO GERADO OK"
		nMarcado:= 1
		nOK		:= 1
	ElseIf nStatus == 2 .And. !lStatus	
		cStatus := STR0009	//"ARQUIVO GERADO SEM DADOS DA COLETA"
		nMarcado:= 0
		nOK		:= 0
	EndIf
	
	Aadd(aArray,{	nMarcado,;				// 1-Marcado ou 0-desmarcado
					aEmpresa[nx][2],;		// Razao Social do Participante
					cStatus,;				// Status
					nOK,;					// 1-ok 0-Nok 
					aEmpresa[nx][1],;		// Codigo da Empresa Participante
					aEmpresa[nx][3],;		// Filial 
					cNome})					// Nome do Arquivo sem a extensao .Ret
	FClose(nHdlArq)
		
Next nx

oObj:SetArray(aArray)
oObj:bLine:= {||{	If(aArray[oObj:nAt,1]==0,oNo,oOK),aArray[oObj:nAt,2],aArray[oObj:nAt,3]}}
oObj:Refresh(.T.)

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs060RB4     ³ Autor ³ Cristina Ogura   ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta array da Empresa Participantes                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060RB4()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM060                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs060RB4()
Local aSaveArea := GetArea()

dbSelectArea("RB4")
dbSetOrder(1)
If dbSeek(xFilial("RB4")+cPesq)
	While !Eof() .And.	xFilial("RB4")+cPesq ==;
				        RB4->RB4_FILIAL+RB4->RB4_PESQ
                
		If !Empty(RB4->RB4_EMPRES)
			dbSelectArea("RB0")
			dbSetOrder(1)
			If 	dbSeek(xFilial("RB0")+RB4->RB4_EMPRES)
				Aadd(aEmpresa,{RB4->RB4_EMPRES,RB0->RB0_NOME,RB4->RB4_FILIAL})
			EndIf	
		EndIf	
		
		dbSelectArea("RB4")
		dbSetOrder(1)		
		dbSkip()
	EndDo					         
EndIf

RestArea(aSaveArea)

Return Nil      

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs060Troca   ³ Autor ³ Cristina Ogura   ³ Data ³ 04/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controle de marca/desmarca dos arquivos selecionados      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060Troca()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM060                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs060Troca(aLbx,oLbx)

If aLbx[oLbx:nAt,1]==0
	aLbx[oLbx:nAt,1]:=1
Else			        
	aLbx[oLbx:nAt,1]:=0
EndIf
		  
oLbx:SetArray(aLbx)
oLbx:bLine:= {||{	If(aLbx[oLbx:nAt,1]==0,oNo,oOK),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3]}}
oLbx:Refresh(.T.)

Return .T.
                           
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs060Grava   ³ Autor ³ Cristina Ogura   ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os dados da empresa participante e dados coletados  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs060Grava()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM060                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs060Grava()      
Local cEmpresa	:= ""
Local nPos 		:= nPos1 := 0
Local nx           
Local cNomeOrig	:= ""
Local cNomeDest	:= ""            
Local lAtu		:= .T.

For nx:= 1 To Len(aLbx)
	If aLbx[nx][1]==1 .And. aLbx[nx][4]==1			// Marcado e gerado OK
		cEmpresa:= aLbx[nx][5]                     
		
		//Buscar dados da Empresa no array aDadosEmp e atualiza RB0 - Empresas Participantes
		nPos:= 0
		nPos:= Ascan(aDadosEmp,{|x| x[1]== cEmpresa })		
		If nPos > 0                                               
			dbSelectArea("RB0")
			dbSetOrder(1)
			If dbSeek(xFilial("RB0")+cEmpresa)
				RecLock("RB0",.F.)
					Replace RB0->RB0_NOME		With	aDadosEmp[nPos][2]
					Replace RB0->RB0_PORTE		With	aDadosEmp[nPos][3]
					Replace RB0->RB0_REGIAO		With	aDadosEmp[nPos][4]
					Replace RB0->RB0_FATURA		With	aDadosEmp[nPos][5]
					Replace RB0->RB0_ATIVID		With	aDadosEmp[nPos][6]
					Replace RB0->RB0_NRFUNC		With	Val(aDadosEmp[nPos][7])
					Replace RB0->RB0_CONTAT		With	aDadosEmp[nPos][8]
					Replace RB0->RB0_EMAIL		With	aDadosEmp[nPos][9]
					Replace RB0->RB0_FONE		With	aDadosEmp[nPos][10]
				MsUnlock()
			EndIf
		EndIf		
		
		// Flag de inclusao de Dados da Coleta
		lAtu := .T.

		//Buscar dados dos Cargos no array aDadosCarg			
		nPos 	:=0
		nPos	:= Ascan(aDadosCarg,{|x| x[1]== cEmpresa })				
		While nPos > 0 .And. nPos <= Len(aDadosCarg) .And. aDadosCarg[nPos][1]==cEmpresa
		            
			// Buscar no array de funcao os cargos correspondentes
			nPos1 	:=0
			nPos1	:= Ascan(aFuncao,{|x| x[1]== aDadosCarg[nPos][2]})				
					                                     
			// Achou no array e os dados da frequencia for > 0 					
			If nPos1 > 0 .And. aDadosCarg[nPos][3] > 0
				dbSelectArea("RB2")
				RecLock("RB2",.T.)
					Replace RB2->RB2_EMPRES		With	aDadosCarg[nPos][1]
					Replace RB2->RB2_FUNCAO		With	aDadosCarg[nPos][11]
					Replace RB2->RB2_DTBASE		With	aDadosCarg[nPos][10]
					Replace RB2->RB2_FREQ		With	aDadosCarg[nPos][3]
					Replace RB2->RB2_SALARI		With	aDadosCarg[nPos][4]
					Replace RB2->RB2_DISSID		With	aDadosCarg[nPos][9]
					Replace RB2->RB2_VLBENE		With	aDadosCarg[nPos][5]
					Replace RB2->RB2_ADICIO		With	aDadosCarg[nPos][6]
					Replace RB2->RB2_ANTECI		With	aDadosCarg[nPos][7]
					Replace RB2->RB2_HORAS		With	aDadosCarg[nPos][8]				
				MsUnlock()
			EndIf	
			nPos:= nPos + 1			
		EndDo				
		           
		// Apos atualizado o nome do arquivo e' renomeado para .OK
		cNomeOrig := aLbx[nx][7]+".RET"                         
		cNomeDest := aLbx[nx][7]+".OK"		
		
		If 	FILE(cNomeDest)
			FErase(cNomeDest)
		EndIf	
		
		FRename(cNomeOrig,cNomeDest)
	
	EndIf
Next nx

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs060Dir     ³ Autor ³ Cristina Ogura   ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o diretorio selecionado pelo usuario.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs0460ir(cDirPesq)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM060                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs060Dir(cDirPesq)

_oWnd := GetWndDefault()

cDirPesq:=cGetFile(OemtoAnsi(STR0010),OemToAnsi(STR0011),0,,.F.,GETF_RETDIRECTORY) //"Arquivos retorno da Pesquisa Salarial"###"Selecione Diretorio"

If _oWnd != Nil
	GetdRefresh()
EndIf

Return .T.                                 

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³28/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³CSAM060                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   

Static Function MenuDef()

 Local aRotina :=  {	{ STR0001,'PesqBrw',0,1,,.F.},;		//"Pesquisar"
						{ STR0002,'Cs060Ler', 0,4}}	//"Ler Dados"						

Return aRotina
