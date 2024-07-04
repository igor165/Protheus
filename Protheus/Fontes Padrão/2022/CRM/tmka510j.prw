#INCLUDE "PROTHEUS.CH"       
#INCLUDE "TMKA510J.CH"       
#INCLUDE 'FWMVCDEF.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKA510J      �Autor�Vendas Clientes   � Data �  16/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Associa o Assunto a Categoria, Causa, Origem, Efeito, Pro- ���
���          �duto e Campanha do chamado de Service Desk.                 ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                            
Function TMKA510J()
Local cFilter				// Armazena o filtro para Assunto
Local cFilterBkp    		// Armazena a copia do filtro da tabela generica
Local aCpos 		:= {}  		// Array com os campos a serem exibidos na tela
Local cAlias 		:= "SX5" 	// Alias da tabela de Assuntos	
				 	
Local oTempTable 	:= Nil

Private nOrdPesq    :=  1

Private cCadastro 	:= STR0001	// "Assuntos x Informa��es do chamado"
Private aRotina		:= {{ 	STR0002,	"AxPesqTRB" 		,0,1 },; 		// 	"Pesquisar"
						{	STR0003,	"TK510JDialog" 	,0,2 },;   		//	"Visualizar"
					 	{ 	STR0004,		"TK510JDialog" 	,0,4 }}   	//	"Alterar"

aCpos	 :=  {	{ STR0005, 	"TRB->TRB_CHAVE"		, 'C', Len( SX5->X5_CHAVE )  , 0, '@! ' },;  	// "C�digo"
                { STR0006, 	"TRB->TRB_DESCRI"	    , 'C', Len( SX5->X5_DESCRI ) , 0, '@! ' }}  		// "Descri��o"
                
//��������������������������������������������������������Ŀ
//� Monta arquivo de trabalho para armazenar os Assuntos   �				
//����������������������������������������������������������
aStruct  := {}
AAdd( aStruct, { "TRB_CHAVE" 	, "C", Len( SX5->X5_CHAVE  ), 0 } )
AAdd( aStruct, { "TRB_DESCRI"	, "C", Len( SX5->X5_DESCRI ), 0 } )                

oTempTable	:= FWTemporaryTable():New( "TRB" )

//-------------------------------------------------------------------
// Atribui o  os �ndices.  
//-------------------------------------------------------------------
oTempTable:SetFields( aStruct)
oTempTable:AddIndex("1",{"TRB_CHAVE"})
	
//------------------
//Cria��o da tabela
//------------------
oTempTable:Create()
 
dbSelectArea("TRB")

//������������������������������������������������������������������������Ŀ
//� Carrega Arquivo temporario com as informacoes do SX5.                  �				
//��������������������������������������������������������������������������
DbSelectArea("SX5")
DbSetOrder(1)
SX5->(MsSeek(xFilial('SX5')+'T1'))
While xFilial('SX5')+'T1' == SX5->X5_FILIAL+SX5->X5_TABELA
	Reclock("TRB",.T.)
	TRB_CHAVE  := SX5->X5_CHAVE
	TRB_DESCRI := X5DESCRI()	
	SX5->(DbSkip())
EndDo

DbSelectArea("TRB")
//��������������������������������������������������������������Ŀ
//� Endere�a a funcao de BROWSE                                  �
//����������������������������������������������������������������    
MBrowse(,,,,"TRB",aCpos,,,,,,,,,)


If( valtype(oTempTable) == "O")
	oTempTable:Delete()
	freeObj(oTempTable)
	oTempTable := nil
EndIf

Return .T.          

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKA510J      �Autor�Vendas Clientes   � Data �  16/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Exibe o cadastro para associar o Assunto as informacoes do ���
���          �chamaodo.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                    
Function TK510JDialog(cAlias,	nReg,	nOpc)
Local oDlg                                
Local aSize		:= {}
Local aObjects 	:= {}
Local aInfo 	:= {}
Local aPosObj 	:= {}
Local oPanelT1			// Informa��es do Assunto
Local oPanelSD			// Informa�oes do Chamado 
Local oFolder			// Folder com as informacoes a serem associadas ao chamado
Local cCodAss	
Local cDescAss	
Local aTitles	:= {} 
Local aPages	:= {}
Local oFolderCat		// Folder para Categoria
Local oFolderCau		// Folder para Causa
Local oFolderOri		// Folder para Origem
Local oFolderEfe		// Folder para Efeito
Local oFolderProd		// Folder para Produto
Local oFolderCamp		// Folder para Campanha 
Local oGetDadCat		// MSNewGetDados para Categoria
Local aHeaderCat		// Array com o cabe�alho da Categoria
Local aColsCat			// Array com os dados da categoria

Local oGetDadCau		// MSNewGetDados para causa
Local aHeaderCau		// Array com o cabe�alho da causa
Local aColsCau			// Array com os dados da causa

Local oGetDadOri		// MSNewGetDados para origem
Local aHeaderOri		// Array com o cabe�alho da origem
Local aColsOri			// Array com os dados da origem

Local oGetDadEfe		// MSNewGetDados para Efeito
Local aHeaderEfe		// Array com o cabe�alho da Efeito
Local aColsEfe			// Array com os dados da Efeito

Local oGetDadProd		// MSNewGetDados para Produto
Local aHeaderProd		// Array com o cabe�alho da Produto
Local aColsProd			// Array com os dados da Produto
                                                        
Local oGetDadCamp		// MSNewGetDados para Campanha
Local aHeaderCamp		// Array com o cabe�alho da Campanha
Local aColsCamp			// Array com os dados da Campanha

Local nOpcA		:= 0	// Indica se o usuario clicou em 1=OK ou 0=Cancelar
Local nOpcGetDad:= 0	// Op��es disponiveis para o tratamento do MsNewGetDados
Local aButtons := {}	// Bot�es a serem incluidos na tela.

Local nAltura  := 0
Local nLargura := 0
Local nRecuoCp := 10
Local oTFont	 := Nil

Private nFolder := 1 

DbSelectArea("QI0")
DbSetOrder(1)   

TRB->(DbGoTo(nReg))
DbSelectArea("SX5")    
DbSetOrder(1)    
DbSeek( xFilial("SX5")+'T1'+TRB->TRB_CHAVE )
cCodAss	:= SX5->X5_CHAVE
cDescAss:= X5DESCRI()


If nOpc == 3
	nOpc 		:= 4
	nOpcGetDad 	:= GD_UPDATE+GD_INSERT+GD_DELETE
	aAdd(aButtons, {"selectAll"	 ,	{|| Tk510Wizard(oDlg, aHeaderCat, oGetDadCat, oGetDadCau, oGetDadOri, oGetDadEfe, oGetDadProd, oGetDadCamp)}, STR0007,	STR0008}) // "Assistente para sele��o de dados." # "Assistente"
EndIf

aSize := MsAdvSize(.T.,.F.)
 
aSize[ 2 ] += 11.5
aSize[ 4 ] += 11.5

AAdd( aObjects, { 480, 040, .F., .F. } )   
AAdd( aObjects, { 020, 020, .F., .F. } )  
AAdd( aObjects, { 480, 080, .F., .F. } )   

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj	:= MsObjSize( aInfo, aObjects ) 

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL 
	 
	 nAltura  := oDlg:nHeight
	 nLargura := ( oDlg:nWidth / 2 ) - 5
	 oTFont   := TFont():New(,,16,.T.,.T.,,,,,,)
	 
	 oPanelT1 := tPanel():New( aPosObj[1,1], aPosObj[1,2],  " "+CRLF+" " + STR0009, oDlg, oTFont, .F.,,CLR_GRAY,, nLargura,  nAltura * 0.3, .T.) // "Assunto" 	 
	 oPanelSD := tPanel():Create( oDlg, aPosObj[3,1], aPosObj[3,2], " "+CRLF+" " + " "+CRLF+" " + STR0010,oTFont,,, CLR_GRAY,, nlargura,  nAltura * 0.35, .T.) // "Informa��es de chamado" 
	 
	 aObjects := {}                      
	 AAdd( aObjects, { 005, 005, .F., .F. } )
     AAdd( aObjects, { 002, 002, .F., .F. } )
	 AAdd( aObjects, { 005, 005, .F., .F. } )  
	 
	aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	aPosObj	:= MsObjSize( aInfo, aObjects )	 
		
	 @ aPosObj[01,01]-nRecuoCp,aPosObj[01,02]   SAY STR0005 PIXEL SIZE 55,9 OF oPanelT1  // "C�digo"
	 @ aPosObj[01,01]-nRecuoCp,aPosObj[01,02]+40 GET oCodAss VAR cCodAss SIZE 40,08 PIXEL OF oPanelT1 WHEN .F. CENTER
	 
	 @ aPosObj[03,01]-nRecuoCp,aPosObj[03,02]   SAY STR0006 PIXEL SIZE 55,9 OF oPanelT1  // "Descri��o"
	 @ aPosObj[03,01]-nRecuoCp,aPosObj[03,02]+40 GET oDescAss VAR cDescAss SIZE 80,08 PIXEL OF oPanelT1 WHEN .F. CENTER
		
	aAdd(aTitles, STR0011)		// "Campanha"
	aAdd(aTitles, STR0012)		// "Produto"
	aAdd(aTitles, STR0013)		// "Categoria"
	aAdd(aTitles, STR0014)		// "Origem"
	aAdd(aTitles, STR0015)		// "Causa"
	aAdd(aTitles, STR0016)		// "Efeito"
	
	aPages	:= {"HEADER","HEADER","HEADER","HEADER","HEADER","HEADER"}

	aObjects := {}                      
	Aadd( aObjects, { 450, 120, .F., .F. } ) 
	 
	aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	aPosObj	:= MsObjSize( aInfo, aObjects )	 	

	oFolder := TFolder():New(aPosObj[1,1] -nRecuoCp , aPosObj[1,2],aTitles, aPages,oPanelSD,,,,.T.,.F., nLargura, nAltura * 0.31 )
	oFolder:bSetOption	:= {|nAtu| Tk510JChangeFolder(	nAtu		,oFolder:nOption)}

	oFolderCamp := oFolder:aDialogs[1]
	oFolderProd := oFolder:aDialogs[2]	
	oFolderCat  := oFolder:aDialogs[3]
	oFolderOri  := oFolder:aDialogs[4]	
	oFolderCau  := oFolder:aDialogs[5]
	oFolderEfe  := oFolder:aDialogs[6]
	
	aObjects := {}                      
	Aadd( aObjects, { 440, 105, .F., .F. } )
	 
	aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	aPosObj	:= MsObjSize( aInfo, aObjects )	 

	//���������������������������Ŀ
	//�Cria o folder para Campanha�
	//�����������������������������					
	Tk510JACols(	1,				aPosObj[1,1],			aPosObj[1,2],	aPosObj[1,3],;
					aPosObj[1,4],	"0", 	SX5->X5_CHAVE, 	nOpc,; 
					nOpcGetDad, 	"SUO", 					oFolderCamp, 	@oGetDadCamp,; 
					@aHeaderCamp, 	@aColsCamp)

	//��������������������������Ŀ
	//�Cria o folder para Produto�
	//����������������������������					
	Tk510JACols(	2,				aPosObj[1,1],			aPosObj[1,2],	aPosObj[1,3],;
					aPosObj[1,4],	"9", 	SX5->X5_CHAVE, 	nOpc,; 
					nOpcGetDad, 	"SB1", 					oFolderProd, 	@oGetDadProd,; 
					@aHeaderProd, 	@aColsProd) 					        	  
	
	//����������������������������Ŀ
	//�Cria o folder para Categoria�
	//������������������������������
	Tk510JACols(	3,				aPosObj[1,1],			aPosObj[1,2],	aPosObj[1,3],;
					aPosObj[1,4],	"4", 	SX5->X5_CHAVE, 	nOpc,; 
					nOpcGetDad, 	"QID", 					oFolderCat, 	@oGetDadCat,; 
					@aHeaderCat, 	@aColsCat)

	//�������������������������Ŀ
	//�Cria o folder para Origem�
	//���������������������������					
	Tk510JACols(	4,				aPosObj[1,1],			aPosObj[1,2],	aPosObj[1,3],;
					aPosObj[1,4],	"3", 	SX5->X5_CHAVE, 	nOpc,; 
					nOpcGetDad, 	"QIC", 					oFolderOri, 	@oGetDadOri,; 
					@aHeaderOri, 	@aColsOri) 	
	
	//�������������������������Ŀ
	//�Cria o folder para Causa �
	//���������������������������					
	Tk510JACols(	5,				aPosObj[1,1],			aPosObj[1,2],	aPosObj[1,3],;
					aPosObj[1,4],	"1", 	SX5->X5_CHAVE, 	nOpc,; 
					nOpcGetDad, 	"QIA", 					oFolderCau, 	@oGetDadCau,; 
					@aHeaderCau, 	@aColsCau) 					        	  

	//�������������������������Ŀ
	//�Cria o folder para Efeito�
	//���������������������������					
	Tk510JACols(	6,				aPosObj[1,1],			aPosObj[1,2],	aPosObj[1,3],;
					aPosObj[1,4],	"2", 	SX5->X5_CHAVE, 	nOpc,; 
					nOpcGetDad, 	"QIB", 					oFolderEfe, 	@oGetDadEfe,; 
					@aHeaderEfe, 	@aColsEfe) 					        	  

			
	nFolder := 1 					        	  

ACTIVATE MSDIALOG oDlg CENTER ON INIT(EnchoiceBar(oDlg,	{||If(TK510ValOK( {{STR0013,oGetDadCat}, {STR0015,oGetDadCau}, {STR0014,oGetDadOri}, {STR0016,oGetDadEfe}, {STR0012,oGetDadProd}, {STR0011,oGetDadCamp} } ), (oDlg:End(), nOpcA:=1,Tk510JRestore(aColsCat,	oGetDadCat:aCols,	aColsCau,	oGetDadCau:aCols,	aColsOri,	oGetDadOri:aCols,	aColsEfe,	oGetDadEfe:aCols,	aColsProd,	oGetDadProd:aCols,	aColsCamp,	oGetDadCamp:aCols)),)},{||oDlg:End()},,aButtons)) 
     
//����������������������������Ŀ
//�Realiza a grava��o dos dados�
//������������������������������
If nOpcA >= 1 
	Tk510JGrvAG8(SX5->X5_CHAVE, "4", aHeaderCat, 	aColsCat)
	Tk510JGrvAG8(SX5->X5_CHAVE, "1", aHeaderCau, 	aColsCau)
	Tk510JGrvAG8(SX5->X5_CHAVE, "3", aHeaderOri, 	aColsOri)
	Tk510JGrvAG8(SX5->X5_CHAVE, "2", aHeaderEfe, 	aColsEfe)
	Tk510JGrvAG8(SX5->X5_CHAVE, "9", aHeaderProd, 	aColsProd)
	Tk510JGrvAG8(SX5->X5_CHAVE, "0", aHeaderCamp, 	aColsCamp)
EndIf

Return .T. 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk510JRestore �Autor�Vendas Clientes   � Data �  16/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Restaura o valor de acols.                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Static Function Tk510JRestore(	aColsCat,		oGetDadCatACols,	aColsCau,	oGetDadCauACols,;	
								aColsOri,		oGetDadOriACols,	aColsEfe,	oGetDadEfeACols,;	
								aColsProd,		oGetDadProdACols,	aColsCamp,	oGetDadCampACols)

aColsCat 	:= {}
aColsCau 	:= {}
aColsOri 	:= {}
aColsEfe  	:= {}
aColsProd 	:= {}
aColsCamp 	:= {}
								
aColsCat	:= aClone(oGetDadCatACols)								
aColsCau	:= aClone(oGetDadCauACols)
aColsOri	:= aClone(oGetDadOriACols)
aColsEfe	:= aClone(oGetDadEfeACols)
aColsProd	:= aClone(oGetDadProdACols)
aColsCamp	:= aClone(oGetDadCampACols)

Return .T.
          
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk510JChangeFo�Autor�Vendas Clientes   � Data �  16/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao executada sempre que ha mudancas de folder.         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Function Tk510JChangeFolder(nAtu, nActualOption) 
nFolder := nAtu
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk510JACols   �Autor�Vendas Clientes   � Data �  16/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta o acols para os itens do atendimento.                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Static Function Tk510JACols(	nFolderAux, 	nTop, 	nLeft, 		nBotton,; 
								nRight, 		nTipo, 	cAssunto, 	nOpc,; 	
								nOpcGetDad, 	cF3, 	oFolder,	oGetDados,; 
								aHeaderAux, 	aColsAux)
Local nPosCod   := 0	// Posicao do campo Codigo
Local nItens	:= 0	// Variavel para controle de loop
Local nLinGD    := 95  // Quantidade m�xima de linhas na GetDados 

// Quantidade de itens na GetDados
nFolder := nFolderAux

//������������������������������������������������������������Ŀ
//� Verifica se existem as novas consultas padr�es que filtram �
//� por query, para poder liberar mais linhas na GetDados.     �
//��������������������������������������������������������������

If nFolder == 1			//Campanha
	nLinGD := 95
ElseIf nFolder == 2		//Produto
	dbSelectArea("SX3")
	dbSetOrder(2)	
	If ( (SX3->(dbSeek("ADE_CODSB1")) .And. SX3->X3_F3 == "TMKAG8") .And. (SXB->(dbSeek("TMKAG8"))) )
		nLinGD := 999
	EndIf
ElseIf nFolder == 3		//Categoria
	dbSelectArea("SX3")
	dbSetOrder(2)	
	If ( (SX3->(dbSeek("ADE_CODCAT")) .And. SX3->X3_F3 == "TMKQI0") .And. (SXB->(dbSeek("TMKQI0"))) )
		nLinGD := 999
	EndIf    
ElseIf nFolder == 4		//Origem
	dbSelectArea("SX3")
	dbSetOrder(2)	
	If ( (SX3->(dbSeek("ADE_CODORI")) .And. SX3->X3_F3 == "TMKQI0") .And. (SXB->(dbSeek("TMKQI0"))) )
		nLinGD := 999
	EndIf
ElseIf nFolder == 5		//Causa
	dbSelectArea("SX3")
	dbSetOrder(2)	
	If ( (SX3->(dbSeek("ADE_CODCAU")) .And. SX3->X3_F3 == "TMKQI0") .And. (SXB->(dbSeek("TMKQI0"))) )
		nLinGD := 999
	EndIf    
ElseIf nFolder == 6		//Efeito
	dbSelectArea("SX3")
	dbSetOrder(2)	
	If ( (SX3->(dbSeek("ADE_CODEFE")) .And. SX3->X3_F3 == "TMKQI0") .And. (SXB->(dbSeek("TMKQI0"))) )
		nLinGD := 999
	EndIf	                  
EndIf

DbSelectArea("AG8")
DbCloseArea()        

cSeek	:= xFilial("AG8") + SX5->X5_CHAVE + nTipo
cWhile	:= "AG8->AG8_FILIAL+AG8->AG8_ASSUNT+AG8->AG8_TIPO"	
bCond	:= {||IIf(AG8->AG8_FILIAL+AG8->AG8_ASSUNT+AG8->AG8_TIPO == xFilial("AG8") + cAssunto + nTipo ,.T.,.F.)}    

aHeaderAux 	:= {}
aColsAux	:= {}
FillGetDados(	nOpc /*nOpcX*/, "AG8"/*cAlias*/, 1/*nIndex*/, cSeek/*cSeek*/,; 
				{||&(cWhile)}/*{||&cWhile}*/, bCond/*{|| bCond,bAct1,bAct2}*/, /*aNoFields*/,; 
				/*aYesFields*/, /*lOnlyYes*/, /*cQuery*/, /*bMontAcols*/, IIf(nOpc == 3, .T.,.F.)/*lEmpty*/,; 
				aHeaderAux/*aHeaderAux*/, aColsAux/*aColsAux*/, /*bAfterCols*/, /*bBeforeCols*/,;
				/*bAfterHeader*/, /*cAliasQry*/)	
                                                             
nPosCod 	:= aScan(aHeaderAux, {|x| AllTrim(Upper(x[2]))=="AG8_COD"})
                            
// Atribui a consulta padr�o para Categoria
aHeaderAux[nPosCod][9] := cF3

//�������������������������������������������������������������Ŀ
//�A limita��o de 95 itens a GetDados, se deve ao fato do limite�
//�de caracteres permitidos no filtro utilizado nas consultas   �
//�padr�es:                                                     �
//�TMK006                                                       �
//�TMK007                                                       �
//�TMK008                                                       �
//�TMK009                                                       �
//�TMK0010                                                      �
//�TMK0011                                                      �
//�Se houver mais que 95 itens ocorrer� estouro de filtro.      �
//�Se for necess�rio aumentar esse n�mero dever� ser feito      �
//�um consulta padr�o manualmente.                              �
//���������������������������������������������������������������
oGetDados := MsNewGetDados():New(nTop, nLeft, nBotton, nRight,nOpcGetDad,"AlwaysTrue","AlwaysTrue",,,,nLinGD,,,,oFolder,aHeaderAux,aColsAux)
oGetDados:bLinhaOK := {|x| !TK510ValLine(x, oGetDados) }

oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Return Nil  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk510JGrv     �Autor�Vendas Clientes   � Data �  16/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Grava os dados relacionados ao assunto.                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/   
Static Function Tk510JGrvAG8(cCodAssunto, cTipo, aHeaderCat, aColsCat)
Local nItens 	:= 0	// Variavel para controle do Loop
Local aAreaAG8 	:= AG8->(GetArea())
Local nPosCod	:= 0	// Armazena a posicao do c�digo

//���������������������Ŀ
//�Apaga todos os dados �
//�����������������������
DbSelectArea("AG8")
DbSetOrder(1) // AG8_FILIAL+AG8_ASSUNT+AG8_TIPO+AG8_COD
If DbSeek( xFilial("AG8")+cCodAssunto+cTipo )

	While AG8->(!EOF()) .AND.; 
		AG8_ASSUNT == cCodAssunto .AND.;
		AG8_TIPO == cTipo
		
		RecLock("AG8",.F.,.T.)
		DbDelete()
		MsUnlock()			
		AG8->(DbSkip())
	End
EndIf    
       
nPosCod 	:= aScan(aHeaderCat, {|x| AllTrim(Upper(x[2]))=="AG8_COD"})

//����������������������������������������������Ŀ
//�Grava��o das informa��es associadas ao assunto�
//������������������������������������������������
For nItens := 1 To Len(aColsCat)
	If !aColsCat[nItens][Len(aColsCat[nItens])] .And. !Empty(aColsCat[nItens][nPosCod])

		//����������������������������������������Ŀ
		//�Valida��o para n�o permitir duplicidades�
		//������������������������������������������
		DbSelectArea("AG8")
		DbSetOrder(1) // AG8_FILIAL+AG8_ASSUNT+AG8_TIPO+AG8_COD
		If !DbSeek( xFilial("AG8")+cCodAssunto+cTipo+aColsCat[nItens][nPosCod] )	
	
			RecLock("AG8", .T.)	
			REPLACE AG8->AG8_FILIAL	WITH xFilial("AG8")
			REPLACE AG8->AG8_ASSUNT	WITH cCodAssunto
			REPLACE AG8->AG8_TIPO 	WITH cTipo  
			REPLACE AG8->AG8_COD 	WITH aColsCat[nItens][nPosCod]  
			MsUnlock()                                              	
		EndIf
	EndIf
Next nItens

RestArea(aAreaAG8)
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk510JRetDesc �Autor�Vendas Clientes   � Data �  16/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna a descricao do campo.                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 = Tipo de acao (1-Inic Padr�o, 2-Gatilho)             ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Function Tk510JRetDesc(nTipo)
Local cRet 		:= ""           
Local cValor 	:= ""

DbSelectArea("QI0")
DbSetOrder(1)    

If nTipo == 1 

	cValor := AG8->AG8_COD
Else                  

	cValor := M->AG8_COD
EndIf

If !Empty(cValor)
	If nFolder == 1
	    
	    cRet := POSICIONE('SUO',1,xFilial('SUO') + cValor, 'UO_DESC')
	ElseIf nFolder == 2
	                
		cRet := POSICIONE('SB1',1,xFilial('SB1') + cValor, 'B1_DESC')    
	ElseIf nFolder == 3   
	
		cRet := FQNCNTAB('4',cValor)
	ElseIf nFolder == 4
	
		cRet := FQNCNTAB('3',cValor)
	ElseIf nFolder == 5	
	
		cRet := FQNCNTAB('1',cValor)
	ElseIf nFolder == 6
	
		cRet := FQNCNTAB('2',cValor)
	EndIf
EndIf
Return cRet   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk510JValid   �Autor�Vendas Clientes   � Data �  16/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida a digitacao no campo.                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Function Tk510JValid(nTipo)
Local lRet := .T. 
Local cValor := &(ReadVar()) 

Default nTipo := nFolder

If !Empty(cValor)
	DbSelectArea("QI0")
	DbSetOrder(1)            

	If nTipo == 1	
		
		lRet := ExistCpo("SUO", cValor)
	ElseIf nTipo == 2	

		lRet := ExistCpo("SB1", cValor)
	ElseIf nTipo == 3   

		lRet := FQNCNTAB('4',cValor, .T.)
	ElseIf nTipo == 4	

		lRet := FQNCNTAB('3',cValor, .T.)	
	ElseIf nTipo == 5

		lRet := FQNCNTAB('1',cValor, .T.)	
	ElseIf nTipo == 6	                    

		lRet := FQNCNTAB('2',cValor, .T.)	
	EndIf  	

	If lRet .AND. !IsInCallStack("TMKA510J")
		lRet := Tk510JVal(nTipo, cValor)
		If !lRet
			Help(" ",1,"REGNOIS")	
		EndIf
	EndIf
EndIf
cValor := ""
Return lRet        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk510Wizard   �Autor�Vendas Clientes   � Data �  27/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Assistente para selecao de dados.                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
Static Function Tk510Wizard(oDlgSuper, 	aHeaderCat, oGetDadCat, 	oGetDadCau,; 
							oGetDadOri, oGetDadEfe, oGetDadProd, 	oGetDadCamp)
Local oDlg      
Local nOpcA 		:= 0
Local oMark     
Local aObjects 		:= {}
Local aSize    		:= {}
Local aInfo 		:= {}
Local aPosObj 		:= {}
Local lInverte 		:= .F.
Local aCpos 		:= {}  
Local aStruct 		:= {}
Local aAreaQI0 		:= QI0->(GetArea()) 
Local nPosCod		:= 0
Local nPosDesc		:= 0
Local nScan			:= 0 
Local aColsAux 		:= {} 
Local oGetDadAux   
Local cTipo			:= ""
Local oTmpTab2 		:= Nil


//��������������������������������������������������������Ŀ
//� Monta arquivo de trabalho para armazenar os Assuntos   �				
//����������������������������������������������������������
aStruct  := {}   
AAdd( aStruct, { "TRB_OK"    	, "C", 						1, 0 } )
AAdd( aStruct, { "TRB_CHAVE" 	, "C", TamSX3("AG8_COD")[1], 0 } )
AAdd( aStruct, { "TRB_DESCR"	, "C", TamSX3("AG8_DESCRI")[1], 0 } )                

aCpos := {	{"TRB_OK"    	, "", "OK"    		, ""},;
			{"TRB_CHAVE"	, "", STR0005 		, ""},; 	// "C�digo"
			{"TRB_DESCR"  	, "", STR0006	, ""}} 			// "Descri��o"	

oTmpTab2	:= FWTemporaryTable():New( "TRB1" )

//-------------------------------------------------------------------
// Atribui o  os �ndices.  
//-------------------------------------------------------------------
oTmpTab2:SetFields( aStruct)
oTmpTab2:AddIndex("1",{"TRB_CHAVE"})
	
//------------------
//Cria��o da tabela
//------------------
oTmpTab2:Create()

dbSelectArea("TRB1")

nPosCod		:= aScan(aHeaderCat, {|x| AllTrim(Upper(x[2]))=="AG8_COD"})                                             
nPosDesc	:= aScan(aHeaderCat, {|x| AllTrim(Upper(x[2]))=="AG8_DESCRI"})                                             

//������������������������������������������������������������������������Ŀ
//� Carrega Arquivo temporario com as informacoes                          �				
//��������������������������������������������������������������������������
If nFolder == 1 
	oGetDadAux 	:= oGetDadCamp
	aColsAux 	:= oGetDadAux:aCols

	DbSelectArea("SUO")  
	DbSetOrder(1)
	DbSeek(xFilial("SU0"))
	While SUO->(!EOF()) .AND. SU0->U0_FILIAL == xFilial("SU0")
		Reclock("TRB1",.T.)
		TRB_CHAVE  	:= SUO->UO_CODCAMP
		TRB_DESCR 	:= SUO->UO_DESC		   
		nScan := aScan(aColsAux, {|x|AllTrim(x[nPosCod])==AllTrim(SUO->UO_CODCAMP)})
		If nScan > 0 
			TRB_OK := "x"
		EndIf	   
		SUO->(DbSkip())
	End
	
ElseIf nFolder == 2  
	oGetDadAux 	:= oGetDadProd
	aColsAux 	:= oGetDadAux:aCols

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1"))
	While SB1->(!EOF()) .AND. SB1->B1_FILIAL == xFilial("SB1")
		Reclock("TRB1",.T.)
		TRB_CHAVE  	:= SB1->B1_COD
		TRB_DESCR 	:= SB1->B1_DESC
		nScan := aScan(aColsAux, {|x|AllTrim(x[nPosCod])==AllTrim(SB1->B1_COD)})
		If nScan > 0 
			TRB_OK := "x"
		EndIf	   	   
		SB1->(DbSkip())
	End

ElseIf nFolder >= 3 .AND. nFolder <= 6 

	If nFolder == 3 
		oGetDadAux 	:= oGetDadCat
		cTipo 		:= "4"
	ElseIf nFolder == 4 
		oGetDadAux 	:= oGetDadOri
		cTipo 		:= "3"
	ElseIf nFolder == 5 
		oGetDadAux 	:= oGetDadCau		
		cTipo 		:= "1"
	ElseIf nFolder == 6 
		oGetDadAux 	:= oGetDadEfe		
		cTipo 		:= "2"
	EndIf			
	aColsAux 	:= oGetDadAux:aCols 	     	
	

	DbSelectArea("QI0")
	DbSetOrder(1)
	DbSeek( xFilial("QI0")+cTipo )
	While QI0->(!EOF()) .AND. QI0->QI0_FILIAL == xFilial("QI0") .AND. QI0->QI0_TIPO == cTipo
		Reclock("TRB1",.T.)
		TRB_CHAVE  	:= QI0->QI0_CODIGO
		TRB_DESCR 	:= QI0->QI0_DESC		   
		nScan := aScan(aColsAux, {|x|AllTrim(x[nPosCod])==AllTrim(QI0->QI0_CODIGO)})
		If nScan > 0 
			TRB_OK := "x"
		EndIf
		QI0->(DbSkip())
	End 	

EndIf   

TRB1->(DbGoTop())                

DEFINE MSDIALOG oDlg Title STR0008 From 000, 000 To 025, 050 // "Assistente"

	Aadd(aObjects,{190,160,.F.,.F.,.F.}) 
	
	aSize:=MsAdvSize()
	aInfo:={aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	aPosObj:=MsObjSize(aInfo,aObjects,.T.)
	
	oMark := MsSelect():New("TRB1","TRB_OK",,aCpos,@lInverte,"x", aPosObj[1])
	oMark:oBrowse:lHasMark := .T.
	oMark:oBrowse:lCanAllMark:=.T.
	oMark:oBrowse:bAllMark := {|| Tk510JMarkAll(oDlg)}	

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar (oDlg, {	|| nOpcA := 1, oDlg:End()},	{|| nOpcA := 0, oDlg:End()} ) )

If nOpcA >= 1 
	aColsAux := {}
	TRB1->(DbGoTop())
	While TRB1->(!EOF())
		If TRB1->TRB_OK == "x"
		   	aAdd(aColsAux, Array(Len(aHeaderCat)+1))
		   	aColsAux[Len(aColsAux)][nPosCod] 	:= TRB1->TRB_CHAVE
		   	aColsAux[Len(aColsAux)][nPosDesc] 	:= TRB1->TRB_DESCR
		   	aColsAux[Len(aColsAux)][Len(aHeaderCat)+1] := .F.
		EndIf
		TRB1->(DbSkip())
	End     
	
	If Len(aColsAux) <= 0 
	   	aAdd(aColsAux, Array(Len(aHeaderCat)+1))
	   	aColsAux[Len(aColsAux)][nPosCod] 	:= Space(TamSX3("AG8_COD")[1])
	   	aColsAux[Len(aColsAux)][nPosDesc] 	:= ""
	   	aColsAux[Len(aColsAux)][Len(aHeaderCat)+1] := .F.	
	EndIF
	oGetDadAux:SetArray(aColsAux, .F.)
	oGetDadAux:ForceRefresh()
	oDlgSuper:Refresh()	
EndIf

If( valtype(oTmpTab2) == "O")
	oTmpTab2:Delete()
	freeObj(oTmpTab2)
	oTmpTab2 := nil
EndIf

RestArea(aAreaQI0)
Return .T.    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk510JMarkAll �Autor�Vendas Clientes   � Data �  27/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Inverte a selecao dos dados.                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
Function Tk510JMarkAll(oDlg)
Local nReg := RecNo()
dbGoTop()
dbEval({|| TRB1->TRB_OK := If(Empty(TRB1->TRB_OK), "x", " ")})
dbGoto(nReg)
oDlg:Refresh()
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk510JFilter  �Autor�Vendas Clientes   � Data �  27/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Filtra os itens que ser�o exibidos nas consultas padr�o.   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
Function Tk510JFilter(nTipo)
Local cRet		:= "@#@#"
Local cTipo		:= AllTrim(Str(nTipo))
Local aArea		:= GetArea()
Local cCampo	:= ""
Local cQryTrb	:= "TK510JFIL"
Local cQuery	:= ""

If nTipo == 1		
	cCampo 	:= "SUO->UO_CODCAMP"	 
ElseIf nTipo == 2              		
	cCampo := "SB1->B1_COD"	
ElseIf nTipo >= 3 .AND. nTipo <= 6  			
	cCampo := "QI0->QI0_CODIGO"		
EndIf     

If nTipo == 1
	cTipo 	:= "0"
ElseIf nTipo == 2              
	cTipo 	:= "9"
ElseIf nTipo >= 3 .AND. nTipo <= 6  	
	If nTipo == 3
		cTipo := "4"
	ElseIf nTipo == 4
		cTipo := "3"
	ElseIf nTipo == 5	
		cTipo := "1"
	ElseIf nTipo == 6	
		cTipo := "2"			
	EndIf
EndIf     

  
cQuery := "SELECT AG8.AG8_COD" 
cQuery += "	 FROM " + RetSQLName("AG8") + " AG8 " 
cQuery += "	 WHERE "
cQuery += "		AG8.AG8_ASSUNT = '" + M->ADE_ASSUNT + "' AND "
cQuery += "		AG8.AG8_TIPO = '" + cTipo + "' AND "
cQuery += "		AG8.D_E_L_E_T_ = ''"

cQuery := ChangeQuery( cQuery )
If Select(cQryTrb) >0
	(cQryTrb)->(DbCloseArea())
EndIf
DbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cQryTrb, .F., .F. )
		
If (cQryTrb)->(!EOF())
	cCods := ""
	While (cQryTrb)->(!EOF())
		If !Empty(cCods)
			cCods += "/"
		EndIf
		cCods += PadR((cQryTrb)->AG8_COD,TamSx3(SubStr(cCampo,6))[1])
		(cQryTrb)->(DbSkip())					
	End
	If !Empty(cCods)
		cCods := cCampo + " $ '" + cCods + "'"
	EndIf
	If nTipo >= 3 .And. nTipo <= 6
		cRet := "@#QI0->QI0_TIPO=='" + cTipo + "' .And. (" + cCods + ")@#"
	Else
		cRet := "@#" + cCods + "@#"
	EndIf
Else
	If nTipo >= 3 .And. nTipo <= 6
		cRet := "@#QI0->QI0_TIPO=='" + cTipo + "'@#"
	Else
		cRet := "@#@#"
	EndIf
EndIf	

	
RestArea( aArea )


Return cRet       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Tk510JVal    �Autor� Vendas CRM       � Data �  21/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o dos campos que fazem parte do filtro.            ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
Function Tk510JVal(nTipo, cValor)
Local lRet		:= .T.
Local cTipo		:= AllTrim(Str(nTipo))
Local cCampo	:= "" 
Local cAlias	:= Alias()
Local cQryTrb	:= "TK510JFIL"
Local cQuery	:= ""

If cValor == NIL	
	If nTipo == 1	
		cCampo 	:= "SUO->UO_CODCAMP"	 
	ElseIf nTipo == 2              
		cCampo := "SB1->B1_COD"	
	ElseIf nTipo >= 3 .AND. nTipo <= 6  	
		cCampo := "QI0->QI0_CODIGO"		
	EndIf     
	cValor := &(cCampo)
EndIf

If nTipo == 1
	cTipo 	:= "0"
ElseIf nTipo == 2              
	cTipo 	:= "9"
ElseIf nTipo >= 3 .AND. nTipo <= 6  	
	If nTipo == 3
		cTipo := "4"
	ElseIf nTipo == 4
		cTipo := "3"
	ElseIf nTipo == 5
		cTipo := "1"
	ElseIf nTipo == 6
		cTipo := "2"			
	EndIf
EndIf     

  
If !Empty(cValor)
	If !("OPENEDGE" $ TCGetDB())
		lRet := .F.
		
		cQuery := "SELECT "
		cQuery += "		(SELECT COUNT(*) " 
		cQuery += "		 FROM " + RetSQLName("AG8") + " AG8 " 
		cQuery += " 	 WHERE "
		cQuery += "			AG8.AG8_ASSUNT = '" + M->ADE_ASSUNT + "' AND "
		cQuery += "			AG8.AG8_TIPO = '" + cTipo + "' AND "
		cQuery += "			AG8.AG8_COD = '" + cValor + "' AND "
		cQuery += "			AG8.D_E_L_E_T_ = '') AS C1 "
		cQuery += " FROM " + RetSQLName("AG8") + " AG8 "
		cQuery += " WHERE "
		cQuery += "		AG8.AG8_ASSUNT = '" + M->ADE_ASSUNT + "' AND "
		cQuery += "		AG8.AG8_TIPO = '" + cTipo + "' AND "
		cQUery += "		AG8.D_E_L_E_T_ = '' "
				
		cQuery := ChangeQuery( cQuery )
		
		If Select(cQryTrb) >0
			(cQryTrb)->(DbCloseArea())
		EndIf
		DbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cQryTrb, .F., .F. )
		
		//��������������������������������������������������������������Ŀ
		//�Se n�o tiver regra, por qualquer que seja, espec�fica para o  �
		//�"tipo" significa que n�o h� controle sobre os itens amarrados �
		//�ao assunto.                                                   �
		//����������������������������������������������������������������
		If (cQryTrb)->(EOF())
			lRet := .T.
		//��������������������������������������������������������������Ŀ
		//�Se tiver uma regra para qualquer item do tipo, s� ser� exibido�
		//�aqueles que est�o cadastrados explicitamente.                 �
		//����������������������������������������������������������������
		Else
			//��������������������������������������������������������������Ŀ
			//�C1 � maior que zero quando foi encontrado o item em espec�fico�
			//�cadastrado na tabela.                                         �
			//����������������������������������������������������������������
			If (cQryTrb)->C1 > 0
				lRet := .T.
			//����������������������������������������������������������Ŀ
			//�Se C1 igual a zero, significa que o item em espec�fico n�o�
			//�est� cadastrado.                                          �
			//������������������������������������������������������������
			Else
				lRet := .F.
			EndIf
		EndIF
		(cQryTrb)->(DbCloseArea())
	Else
		lRet := Tk510JVal2(cTipo, cValor)
	EndIf
EndIf


DbSelectArea(cAlias)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Tk510JVal2   �Autor� Vendas CRM       � Data �  31/01/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o dos campos que fazem parte do filtro.            ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
Function Tk510JVal2(cTipo, cValor)
Local lRet		:= .T.
Default cTipo	:= ''
Default cValor	:= ''

DbSelectArea("AG8")
DbSetOrder(1) // AG8_FILIAL+AG8_ASSUNT+AG8_TIPO+AG8_COD
//���������������������������'���������������������������Ŀ
//�Se n�o houver nenhum informa��o associado ao assunto, �
//�assume que tudo � valido.                             �
//��������������������������������������������������������
If DbSeek( xFilial("AG8") + M->ADE_ASSUNT + cTipo ) .AND. !Empty(AG8->AG8_COD) 
	AG8->(DbGoTop())
	If !DbSeek( xFilial("AG8") + M->ADE_ASSUNT + cTipo + cValor )
		lRet := .F.
	EndIf
EndIf

Return lRet




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk510JVT1     �Autor�Vendas Clientes   � Data �  27/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida a integridade dos campos Produto, Campanha, Catego- ���
���          �-ria, Origem, Causa e Efeito ap�s a digitacao do assunto.   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/    
Function Tk510JVT1() 
If !Tk510JVal(1, M->ADE_CODCAM)
	M->ADE_CODCAM 	:= Space(TamSX3("ADE_CODCAM")[1])
	M->ADE_DSCCAMP	:= Space(TamSX3("ADE_DSCCAMP")[1])
EndIf

If !Tk510JVal(2, M->ADE_CODSB1)
	M->ADE_CODSB1 	:= Space(TamSX3("ADE_CODSB1")[1])
	M->ADE_NMPROD	:= Space(TamSX3("ADE_NMPROD")[1])
EndIf

If !Tk510JVal(3, M->ADE_CODCAT)
	M->ADE_CODCAT 	:= Space(TamSX3("ADE_CODCAT")[1])
	M->ADE_NCATEG	:= Space(TamSX3("ADE_NCATEG")[1])
EndIf

If !Tk510JVal(4, M->ADE_CODORI)
	M->ADE_CODORI 	:= Space(TamSX3("ADE_CODORI")[1])
	M->ADE_NORIGE	:= Space(TamSX3("ADE_NORIGE")[1])
EndIf

If !Tk510JVal(5, M->ADE_CODCAU)
	M->ADE_CODCAU 	:= Space(TamSX3("ADE_CODCAU")[1])
	M->ADE_NCAUSA	:= Space(TamSX3("ADE_NCAUSA")[1])
EndIf

If !Tk510JVal(6, M->ADE_CODEFE)
	M->ADE_CODEFE 	:= Space(TamSX3("ADE_CODEFE")[1])
	M->ADE_NEFEIT	:= Space(TamSX3("ADE_NEFEIT")[1])
EndIf
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � TK510ValOK   �Autor� Vendas CRM       � Data �  19/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se as getdados tem conte�do em duplicidade.       ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Function TK510ValOK( aGetDados )
	Local nCount	:= 1 
	Local cMsg		:= "As seguintes ocorr�ncias foram encontradas no cadastro:" + CRLF
	Local lInvalid	:= .F.
	
	For nCount := 1 To Len( aGetDados )
		If !TK510ValGetDados( aGetDados[nCount,2] )
			cMsg += "- H� itens duplicados na aba '" + aGetDados[nCount,1] + "'" + CRLF
			lInvalid := .T.
		EndIF
	Next
	
	If lInvalid
		Aviso("Aten��o!", cMsg, {"OK"})
	EndIf
Return !lInvalid
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TK510ValGetDados �Autor� Vendas CRM    � Data �  19/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se uma getdados tem conte�do em duplicidade.      ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Function TK510ValGetDados( oGetDados )
	Local nCount	:= 1
	Local lFindDup	:= .F.
	
	For nCount := 1 To Len(oGetDados:aCols)
		If !aTail(oGetDados:aCols[nCount]) .And. TK510ChkDup( nCount, oGetDados:aHeader, oGetDados:aCols )
			lFindDup := .T.
			Exit
		EndIf
	Next
Return !lFindDup

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � TK510ValLine �Autor� Vendas CRM       � Data �  19/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se uma determinada linha tem seu conte�do em      ���
���          � duplicidade. (Com informa��o visual)                       ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Function TK510ValLine( nLine, oGetDados )
	Local lFindDup	:= .F.
	
	lFindDup := TK510ChkDup( oGetDados:nAt, oGetDados:aHeader, oGetDados:aCols )
	
	If lFindDup
		Aviso("Aten��o!", "A informa��o digitada j� existe em outra linha", {"OK"})
	EndIf
Return lFindDup

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � TK510ChkDup  �Autor� Vendas CRM       � Data �  19/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se uma determinada linha tem seu conte�do em      ���
���          � duplicidade.                                               ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Function TK510ChkDup( nLine, aHeader, aCols )
	Local nCount		:= 1
	Local nPos			:= aScan( aHeader, {|x| AllTrim(x[2]) == "AG8_COD"})
	Local lDuplicado	:= .F.
	
	If nPos > 0
		For nCount := 1 To Len (aCols)
			//���������������������������Ŀ
			//�N�o verifica a linha atual.�
			//�����������������������������
			If nCount == nLine .Or. aTail(aCols[nCount])
				Loop
			EndIf

			//�����������������������������������������������������Ŀ
			//�Verifica se a linha em an�lise � igual a linha atual.�
			//�������������������������������������������������������
			If aCols[nLine][nPos] == aCols[nCount][nPos]
				lDuplicado := .T.
				Exit
			EndIf
		Next
	EndIf
Return lDuplicado

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � TMKAG8		�Autor� Vendas CRM       � Data �  24/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o utilizada na consulta padr�o do ADE_CODSB1, para    ���
���          � filtrar os produtos, conforme o cadastro do AG8.           ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Function TMKAG8()
                  
Local lRet 		:= .F.
Local nRetorno 	:= 0
Local aSearch  	:= {"B1_COD","B1_DESC"} 
Local cQuery   	:= ""
Local lProd		:= .F.		//Variavel para verificar a existencia de produtos na AG8

If !Empty(M->ADE_ASSUNT)
	//Verifico se h� amarra��o junto a AG8 - Chamado TQKCZK
	lProd := TmkJoinAG8(M->ADE_ASSUNT,"9")	
EndIf

If !lProd
	cQuery := "SELECT SB1.B1_COD, SB1.B1_DESC, SB1.R_E_C_N_O_ SB1RECNO" 
	cQuery += "	 FROM " + RetSQLName("SB1") + " SB1 "
	cQuery += "	 WHERE "
	cQuery += "	    SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
	cQuery += "		SB1.D_E_L_E_T_ = '' "
Else
	cQuery := "SELECT SB1.B1_COD, SB1.B1_DESC, SB1.R_E_C_N_O_ SB1RECNO" 
	cQuery += "	 FROM " + RetSQLName("SB1") + " SB1, "
	cQuery += RetSqlName("AG8")+" AG8 "	 
	cQuery += "	 WHERE "
	cQuery += "		AG8.AG8_FILIAL = '"+xFilial("AG8")+"' AND "	
	cQuery += "	    SB1.B1_FILIAL  = '"+xFilial("SB1")+"' AND "
	cQuery += "		AG8.AG8_ASSUNT = '" + M->ADE_ASSUNT + "' AND "
	cQuery += "		AG8.D_E_L_E_T_ = ''  AND "
	cQuery += "		AG8.AG8_COD = SB1.B1_COD AND "  
	cQuery += "		AG8.AG8_COD = SB1.B1_COD AND "
   	cQuery += "		AG8.AG8_TIPO ='9' AND "
	cQuery += "		SB1.D_E_L_E_T_ = '' "
EndIf

If Tk510F3Qry( cQuery, "TMKAG8", "SB1RECNO", @nRetorno,, aSearch, "SB1" )
	SB1->(dbGoto(nRetorno))
	lRet := .T.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � TMKQI0		�Autor� Vendas CRM       � Data �  06/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o utilizada para consulta padr�o dos campos 	      ���
���          � ADE_CODCAU, ADE_CODEFE, ADE_CODORI e ADE_CODCAT para	      ���
���          � filtrar os tipos, conforme o cadastro da tabela AG8.       ���
���          �     														  ���
���          � nTipo:												      ���
���          � 1 - Possiveis Causas    									  ���
���          � 2 - Efeitos Causados    									  ���
���          � 3 - Origem da NC    										  ���
���          � 4 - Categoria Problema    								  ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Function TMKQI0(nTipo)
                  
Local lRet 		:= .F.
Local nRetorno 	:= 0
Local aSearch  	:= {"QI0_CODIGO","QI0_DESC"} 
Local cQuery   	:= ""
Local lQI0		:= .F.	//Variavel para verificar a existencia de amarra��o na AG8

If !Empty(M->ADE_ASSUNT)
	//Verifico se h� amarra��o junto a AG8 - Chamado TQKCZK
	lQI0 := TmkJoinAG8(M->ADE_ASSUNT,cValToChar(nTipo))	
EndIf

If !lQI0
	cQuery := "SELECT QI0.QI0_CODIGO, QI0.QI0_DESC, QI0.R_E_C_N_O_ QI0RECNO" 
	cQuery += "	 FROM " + RetSQLName("QI0") + " QI0 "
	cQuery += "	 WHERE "
	cQuery += "	    QI0.QI0_FILIAL = '" + xFilial("QI0") + "' AND "
	cQuery += "	    QI0.QI0_TIPO   = '" + AllTrim(Str(nTipo)) + "' AND "
	cQuery += "		QI0.D_E_L_E_T_ = ' ' "
Else
	cQuery := "SELECT QI0.QI0_CODIGO, QI0.QI0_DESC, QI0.R_E_C_N_O_ QI0RECNO" 
	cQuery += "	 FROM " + RetSQLName("QI0") + " QI0, "
	cQuery += RetSqlName("AG8")+" AG8 "	 
	cQuery += "	 WHERE "
	cQuery += "		AG8.AG8_FILIAL = '" + xFilial("AG8") + "' AND "	
	cQuery += "	    QI0.QI0_FILIAL = '" + xFilial("QI0") + "' AND "
	cQuery += "		AG8.AG8_ASSUNT = '" + M->ADE_ASSUNT  + "' AND "
	cQuery += "		AG8.AG8_TIPO   = '" + AllTrim(Str(nTipo)) + "' AND "
	cQuery += "		AG8.AG8_TIPO   = QI0.QI0_TIPO AND "
	cQuery += "		AG8.AG8_COD    = QI0.QI0_CODIGO AND "
	cQuery += "		AG8.D_E_L_E_T_ = ' '  AND "
	cQuery += "		QI0.D_E_L_E_T_ = ' ' "
EndIf

If Tk510F3Qry( cQuery, "TMKQI0", "QI0RECNO", @nRetorno,, aSearch, "QI0" )
	QI0->(dbGoto(nRetorno))
	lRet := .T.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Tk510F3Qry  �Autor� Vendas Clientes    � Data �  24/06/10  ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o gen�rica para montagem de tela de consulta padrao   ���
���          � baseado em query especifica.  				              ���
���          � Obs: Mesma consulta utilizada pelo SIGAJURI	              ���
�������������������������������������������������������������������������͹��
���Parametros� cQuery    - Query a ser executada                          ���
���          � cCodCon 	 - Codigo da consulta  							  ���
���          � cCpoRecno - Campo com o Recno()							  ���
���          � nRetorno  - Campo onde sera retornado o recno() do  		  ���
���          �  		   registro selecionado							  ���
���          � aCoord    - Coordenadas da tela, se nao espeficicado ser�  ���
���          � 			   usado o tamanho padr�o						  ���
���          � aSearch   - Array de campos que serao os indices 		  ���
���          � 			   utilizados para pesquisa						  ���
���          � cAlias    - Tabela principal que ser� utilizada para 	  ���
���          � 			   visualiza��o (AxVisual).						  ���
�������������������������������������������������������������������������͹��
���Uso       �TMKA510                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/            
Function Tk510F3Qry( cQuery, cCodCon, cCpoRecno, nRetorno, aCoord, aSearch, cAlias )

Local aArea       := GetArea()
Local aCampos     := {}
Local aProdF3     := {}
Local aStru       := {}
Local aSeek	  	  := {}
Local aIndex      := {}
Local cIdBrowse   := ''
Local cIdRodape   := ''
Local cTrab       := GetNextAlias()
Local lRet        := .F.
Local nAt         := 0
Local nI          := 0
Local oBrowse, oColumn, oDlg, oBtnOk, oBtnCan, oTela, oPnlBrw, oPnlRoda
Local aCamposFilt := {}
Local cTitCpo     :=  ''
Local cPicCpo     :=  ''
Local cNomeTab	  := ""
      
DEFAULT cQuery    := ""
DEFAULT cCodCon   := ""
DEFAULT cCpoRecno := ""
DEFAULT nRetorno  := 0
DEFAULT aCoord    := { 0, 0, 390, 515 }
DEFAULT aSearch   := {}
DEFAULT cAlias	  := ""

//Verifica se o alias existe no dicion�rio de dados
If !Empty(cAlias)
    dbSelectArea("SX2")
    dbSetOrder(1)
	If !dbSeek(cAlias)
		cAlias := ""
	Else
		cNomeTab := X2Nome()
	EndIf
EndIf

//-------------------------------------------------------------------
// Indica as chaves de Pesquisa
//-------------------------------------------------------------------
//[1] - Nome do Campo
//[2] - Titulo do Campo
//[3] - Tipo do Campo
//[4] - Tamanho do Campo
//[5] - Casas decimais
//-------------------------------------------------------------------
If !Empty (aSearch)
	For nI:= 1 to Len(aSearch)
		aAdd( aIndex, aSearch[nI] )
		aAdd( aSeek, { AvSX3(aSearch[nI],5), {{"",AvSX3(aSearch[nI],2),AvSX3(aSearch[nI],3),AvSX3(aSearch[nI],4),AvSX3(aSearch[nI],5),,}} } )

		If nI == 1
			cQuery += " ORDER BY "+aSearch[nI]
		EndIf
	Next
EndIf

Define MsDialog oDlg FROM aCoord[1], aCoord[2] To aCoord[3], aCoord[4] Title STR0017 + " - " + cNomeTab Pixel Of oMainWnd		//"Consulta Padr�o"
nAt := aScan( aProdF3, { | aX | aX[1] == PadR( cCodCon, 10 ) } )

oTela     := FWFormContainer():New( oDlg )
cIdBrowse := oTela:CreateHorizontalBox( 85 )
cIdRodape := oTela:CreateHorizontalBox( 15 )
oTela:Activate( oDlg, .F. )

oPnlBrw   := oTela:GeTPanel( cIdBrowse )
oPnlRoda  := oTela:GeTPanel( cIdRodape )

If !Empty( cCodCon )
	
	If nAt == 0
		aAdd( aProdF3, { PadR( cCodCon, 10 ) , cQuery, {} } )
	Else
		cQuery  := aProdF3[nAt][2]
	EndIf
	
EndIf

//-------------------------------------------------------------------
// Define o Browse
//-------------------------------------------------------------------
Define FWBrowse oBrowse DATA QUERY ALIAS cTrab QUERY cQuery ;
DOUBLECLICK { || lRet := .T., nRetorno := (cTrab)->( FieldGet( FieldPos( cCpoRecno ) ) ), oDlg:End() } ;
NO LOCATE FILTER SEEK ORDER aSeek INDEXQUERY aIndex Of oPnlBrw

//-------------------------------------------------------------------
// Monta Estrutura de campos
//-------------------------------------------------------------------
If !Empty( cCodCon )
	
	If nAt == 0
		
		aStru := ( cTrab )->( dbStruct() )
		
		For nI := 1 To Len( aStru )

			//-------------------------------------------------------------------
			// Campos
			//-------------------------------------------------------------------
			// Estrutura do aFields
			//				[n][1] Campo
			//				[n][2] T�tulo
			//				[n][3] Tipo
			//				[n][4] Tamanho
			//				[n][5] Decimal
			//				[n][6] Picture
			//-------------------------------------------------------------------

			cTitCpo := aStru[nI][1]
			cPicCpo := ''
					
			If AvSX3( aStru[nI][1],, cTrab, .T. )
				cTitCpo := RetTitle( aStru[nI][1] )
				cPicCpo := AvSX3( aStru[nI][1], 6, cTrab )
				
				If cPicCpo $ '@!'
					cPicCpo := ''
				EndIf
			EndIf
			
			If !PadR( cCpoRecno, 15 ) == PadR( aStru[nI][1], 15 )
				aAdd( aCampos, { aStru[nI][1], cTitCpo,  aStru[nI][2], aStru[nI][3], aStru[nI][4], cPicCpo } )
			EndIf
			
		Next
		
		If !Empty( cCodCon )
			aProdF3[Len( aProdF3 )][3] := aCampos
		EndIf
		
	Else
		aCampos := aClone( aProdF3[nAt][3] )
	EndIf
	
EndIf

//-------------------------------------------------------------------
// Adiciona as colunas do Browse
//-------------------------------------------------------------------
For nI := 1 To Len( aCampos )
	ADD COLUMN oColumn DATA &( '{ || ' + aCampos[nI][1] + ' }' ) Title aCampos[nI][2]  PICTURE aCampos[nI][6] Of oBrowse
Next

//-------------------------------------------------------------------
// Adiciona as colunas do Filtro
//-------------------------------------------------------------------
oBrowse:SetFieldFilter( aCampos )
oBrowse:SetUseFilter()

//-------------------------------------------------------------------
// Ativa��o do Browse
//-------------------------------------------------------------------
Activate FWBrowse oBrowse
                
@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 003 Button oBtnOk  Prompt STR0018 Size 25, 12 Of oPnlRoda Pixel Action ( lRet := .T., nRetorno := ( cTrab )->( FieldGet( FieldPos( cCpoRecno ) ) ) , oDlg:End() )	//"Ok"
@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 033 Button oBtnCan Prompt STR0019  Size 25, 12 Of oPnlRoda Pixel Action ( lRet := .F., oDlg:End() )		//"Cancelar"
@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 063 Button oBtnCan Prompt STR0003 Size 25, 12 Of oPnlRoda Pixel Action ( IIf( !Empty(cAlias) .And. ((cTrab)->(FieldGet(FieldPos(cCpoRecno))) > 0), Tk510VisCad( cAlias, (cTrab)->(FieldGet(FieldPos(cCpoRecno)))), .T. ) )	//"Visualizar"

//-------------------------------------------------------------------
// Ativa��o do janela
//-------------------------------------------------------------------
Activate MsDialog oDlg Centered

RestArea( aArea )

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Tk510VisCad  �Autor� Vendas CRM       � Data �  08/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Visualiza o cadastro.								      ���
���          �															  ���
�������������������������������������������������������������������������͹��
���Uso       � Service Desk                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Static Function Tk510VisCad(cAlias,nRecno)

Local aArea := GetArea()

dbSelectArea(cAlias)
dbGoto(nRecno)
AxVisual( cAlias, nRecno, 2 )

RestArea( aArea )

Return	.T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AxPesqTRB �Autor  �Vendas&CRM Figueira � Data �  03/16/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Janela de pesquisa de item                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Vendas&CRM                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function AxPesqTRB()
Local cCampo 	:= SPACE(30)
Local cArqTrab 	:= SPACE(30)
Local cCodigo	:= "C�digo"
Local cDescri	:= "Descri��o"
Local nPos		:= 10
Local aCpos 	:= {}
Local oBigGet	:= NIL
Local oCBX     	:= NIL
Local oDlgPesq  := NIL
Local nOpcao  := 0

AAdd( aCpos, cCodigo)
AAdd( aCpos, cDescri)

DEFINE MSDIALOG oDlgPesq FROM 00,00 TO 100,490 PIXEL TITLE OemToAnsi(STR0002) //"Pesquisa"

@05,05 COMBOBOX oCBX VAR cArqTrab ITEMS aCpos SIZE 206,36 PIXEL OF oDlgPesq FONT oDlgPesq:oFont;
   			ON CHANGE (nOrdPesq:= oCBX:nAt)

@22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 PIXEL ENABLE OF oDlgPesq ;
				ACTION (nOpcao:=1,oDlgPesq:End())          
				
DEFINE SBUTTON FROM 20,215 TYPE 2 PIXEL ENABLE OF oDlgPesq ;
				ACTION oDlgPesq:End()

oCBX:nAt:= nOrdPesq

ACTIVATE MSDIALOG oDlgPesq CENTERED

If nOpcao == 1
	If TRB->(IndexOrd()) <> nOrdPesq
		TRB->(DbSetOrder(nOrdPesq))
	EndIf
	If !Empty(AllTrim(cCampo))
		TRB->(DbSeek(RTrim(cCampo)))
	EndIf
EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TmkJoinAG8
Verifico a existencia de produtos amarrados a AG8
 
@author CRM & Servi�os
@since 16/09/2014	
@version P11 R8
 
@param cAssunto, caracter, Codigo do Assunto
@param cTipo, caracter, codigo do tipo para consulta na AG8
 
@return Booleano, Retorna .T. se houve amarra��o da AG8 com o Assunto
/*/
//------------------------------------------------------------------------
Static Function TmkJoinAG8(cAssunto,cTipo)
Local lRetorno 	:= .F.
Local aArea		:= GetArea() 

Default cAssunto	:= ""
Default cTipo 		:= ""

If !Empty(cAssunto) .And. !Empty(cTipo)
	DbSelectArea("AG8")
	DbSetOrder(1)
	If AG8->(DbSeek(xFilial("AG8") + cAssunto + cTipo))
		lRetorno := .T.
	EndIf
EndIf

RestArea(aArea)

Return(lRetorno)