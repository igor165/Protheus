#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA503B.CH"
#INCLUDE "APWIZARD.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TeleServiceMaintenanceºAutor³Michel Mosca     º Data ³  31/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     |Classe que contempla as funcionalidades da tela do configurador de º±± 
±±º          ³modelos de atendimento.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß     
*/
Class TeleServiceMaintenance From TeleServiceDialog 

Method new() Constructor  
Method showDialog()
Method openBrowse()
Method customizeField()
Method restoreField()
Method getAFields(table, oList, aFields)
Method updBtnBrowse(aBtns, oBrowse, toolbarList) 
Method updRelBrowse(aRel, oBrowse, oRelations, aRelIndex)
Method alterPosBtn(toolbarList, nAt, aList, nOpc, oBrowse)
Method getDesc(nOption)                     
Method dlgButton(oTSButton, lDel)
Method dlgRelation(oTSRelation, lDel)
Method QuerySX3(cTable, cRetVar) 
Method getAbstractText(cText)

EndClass
            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³New          ºAutor  ³Michel W. Mosca  º Data ³  31/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo construtor da classe.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method new() Class TeleServiceMaintenance  

Self:lReadOnly := .F.
Self:service := TeleServicing():New() 
Return Self  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³showDialog   ºAutor  ³Michel W. Mosca  º Data ³  31/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe a tela para configurar o modelo de atendimento.       º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ showDialog(ExpC1)                                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Texto a ser exibido no campo Acao do usuario.      ³±±
±±³          ³                                                            ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method showDialog(cAction) Class TeleServiceMaintenance
Local oWizard 										//Obteto principal com a tela de dialogo
Local aSizeDlg      	:= MsAdvSize(.T.,.F.,400)	//Array com as dimensoes da tela principal.
Local aInfo				:={}						//Array para utilizacao do MsAdvSize
Local aPosObj			:= {}						//Array com as coordenadas para posicionamento dos objetos
Local aObjects			:={}						//Array com os objetos da tela    
Local oPanel                                        //Variavel auxiliar utilizado na construção dos paineis
Local oFont											//Fonte utilizado nos objetos 
Local lFinish	:= .F.

//Objetos das tela
Local oName				//MSGET com nome do modelo
Local oMaster			//MSGET com o nome da tabela que contem a tabela cabecalho
Local oMasterBrowse 	//TCBrowse contendo os campos da tabela cabecalho
Local aList := {}		//Array contendo os campos da tabela cabecalho
Local oDetail       	//MSGET com o nome da tabela que contem a tabela detalhe
Local oDetailBrowse  	//TCBrowse contendo os campos da tabela detalhe	
Local aDetList := {}  	//Array contendo os campos da tabela cabecalho
Local oBmp1             //Bitmap com imagem "Pode Alterar"
Local oBmp2        		//Bitmap com imagem "Não pode alterar"
Local oWOpWin1			//MSGET com o nome da funcao a ser executado pelo Ponto de entrada na aplicação
Local oWOpWin2          //MSGET com o nome da funcao a ser executado pelo Ponto de entrada na aplicação
Local oWOpWin3          //MSGET com o nome da funcao a ser executado pelo Ponto de entrada na aplicação
Local oWOpWin4			//MSGET com o nome da funcao a ser executado pelo Ponto de entrada na aplicação
Local oWOpWin5			//MSGET com o nome da funcao a ser executado pelo Ponto de entrada na aplicação
Local oWOpWin6			//MSGET com o nome da funcao a ser executado pelo Ponto de entrada na aplicação
Local oWOpWin7			//MSGET com o nome da funcao a ser executado pelo Ponto de entrada na aplicação
Local aTopBtns := {}	//Botoes inseridos no browse da tela de botoes
						//aTopBtns[][1]='Nome'
						//aTopBtns[][2]='Ordem'
						//aTopBtns[][3]='Figura'
						//aTopBtns[][4]='Função a ser executada'
						//aTopBtns[][5]='Help do Botão'
						//aTopBtns[][6]='Código'
Local oTopBrowse
Local aSideBtns:= {}	//Botoes inseridos no browse da tela de botoes
						//aTopBtns[][1]='Nome'
						//aTopBtns[][2]='Ordem'
						//aTopBtns[][3]='Figura'
						//aTopBtns[][4]='Função a ser executada'
						//aTopBtns[][5]='Help do Botão'
						//aTopBtns[][6]='Código'    
Local oSideBrowse						
Local oButton      
Local oFieldMaster
Local cFieldMaster  
Local oFieldDet
Local cFieldDet        
Local oRelBrowse
Local aRelBrowse 
Local aRelIndex      
Local oFieldCont		//Get para capturar o campo do contato    
Local oAbstract			//GET com resumo da alteraçaõ
Local cAbstract			//Texto a ser exibido no resumo   
Local oFieldEntName		//MSGET com o nome de campo
Local oFieldEntKey		//MSGET com o nome de campo
Local oFieldEntIdx      //MSGET com o nome de campo
Local oFieldGDInit		//MSGET com o nome de campo
Local oFieldCampKey		//MSGET com o nome de campo
Local oFieldOpCode		//MSGET com o nome de campo
Local oFieldRegCod		//MSGET com o nome de campo

oWizard:= APWizard():New( 	STR0001 + cAction	,; //"Ação escolhida - "
							STR0002,; //"Informe os dados iniciais do Modelo "
						  	STR0003,; //"Configurador de Modelo de Atendimento"
							 ,;
							 {||IIf(Empty(Self:service:name),Eval({||Aviso(STR0004,STR0005, {"OK"}),.F.}),.T.)},; //"Configurador" # "Informe um nome para o modelo de atendimento"
							 {||.T.},.T., , , .T.,{aSizeDlg[7],000,aSizeDlg[6],aSizeDlg[5]} )
							 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do posicionamento dos objetos no painel    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aObjects, { 001, 020, .T., .F. } )
AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )

AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )	
								 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo de coordenadas dos objetos da tela de acordo com as coordenada do painel.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
oPanel 	:= oWizard:GetPanel(1)
aInfo   := { 0, 0, oPanel:nClientHeight, oPanel:nClientWidth, 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )	 

If !Empty(Self:service:id)
	@ aPosObj[2,1],aPosObj[2,2]  SAY STR0006 OF oPanel PIXEL SIZE 55,9 //"Código"
	@ aPosObj[3,1],aPosObj[3,2]  MSGET oName VAR Self:service:id Picture PesqPict('SKA','KA_CODIGO') OF oPanel PIXEL When .F. SIZE 70 ,9		
EndIf		
@ aPosObj[4,1],aPosObj[4,2]  SAY STR0007 OF oWizard:GETPANEL(1) COLOR CLR_BLUE PIXEL SIZE 55,9 //"Nome"
@ aPosObj[5,1],aPosObj[5,2]  MSGET oName VAR Self:service:name Picture PesqPict('SKA','KA_NOME') OF oPanel PIXEL When !Self:lReadOnly SIZE 70 ,9		


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao de painel para configurar as tabelas do modelo de atendimento    	   ³   
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard  	HEADER 	STR0001 + cAction; //"Ação escolhida - "
						MESSAGE STR0008 ;  //" Configure as tabelas do modelo de atendimento "
					 	NEXT {||IIf(Empty(Self:service:tableStructureInfo:master:alias).OR.Empty(Self:service:tableStructureInfo:detail:alias),Eval({||Aviso(STR0004,STR0009, {"OK"}),.F.}),.T.)}; //"Configurador" # "O cabeçalho e os itens do atendimento devem ser informados obrigatóriamente"
					 	FINISH {||.T.} PANEL
					    	
aObjects := {}
AAdd( aObjects, { 001, 000, .T., .F. } )

AAdd( aObjects, { 001, 005, .T., .F. } ) 
AAdd( aObjects, { 001, 010, .T., .F. } )
AAdd( aObjects, { 001, 050, .T., .F., .T. } ) 
AAdd( aObjects, { 001, 020, .T., .F., .T. } )

AAdd( aObjects, { 001, 005, .T., .F. } ) 
AAdd( aObjects, { 001, 010, .T., .F. } )
AAdd( aObjects, { 001, 050, .T., .F., .T. } ) 
AAdd( aObjects, { 001, 020, .T., .F., .T. } )		   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo de coordenadas dos objetos da tela de acordo com as coordenada do painel.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
oPanel := oWizard:GetPanel(2)
aInfo   := { 0, 0, oPanel:nClientHeight, oPanel:nClientWidth, 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )	 								    	
					    	
@ aPosObj[2,1],aPosObj[2,2]  SAY STR0010 OF oPanel COLOR CLR_BLUE PIXEL SIZE 75,9 //"Cabeçalho do atendimento"
@ aPosObj[3,1],aPosObj[3,2]  MSGET oMaster VAR Self:service:tableStructureInfo:master:alias Picture PesqPict('SKA','KA_ALIMAST') OF oPanel PIXEL VALID {||IIF(Self:service:tableStructureInfo:master:load(AllTrim(Self:service:tableStructureInfo:master:alias)),Eval({||Self:getAFields(Self:service:tableStructureInfo:master, @oMasterBrowse, @aList),.T.}),Eval({||Aviso(STR0004,STR0011,{"OK"}),.F.}))} When !Self:lReadOnly SIZE 70 ,9 F3 "HSPSX2"	//"Configurador" # "Informe corretamente o nome da tabela que será o cabeçalho do atendimento."			

Define Font oFont Name 'Courier New' Size 0, -12		
oMasterBrowse := TCBrowse():New( aPosObj[4,1],aPosObj[4,2], aPosObj[4,3],aPosObj[4,4],, {'', STR0012,STR0013, STR0014, STR0015,STR0016,STR0017},{20,50,50,50,50,50,50},; //"Ordem" # "Nome" # "Titulo" # "Descrição" # "Nível" # "Tipo"
                            oPanel,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,,, )

aList := Self:getAFields(Self:service:tableStructureInfo:master, @oMasterBrowse, @aList)

@ aPosObj[5,1],aPosObj[5,2]	BUTTON STR0066	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION Self:customizeField(1,oMasterBrowse) //"Alterar"
@ aPosObj[5,1],aPosObj[5,2]+45	BUTTON STR0098	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION Self:restoreField(1,oMasterBrowse)   //"Restaurar"
  		
@ aPosObj[5,1],275 BITMAP oBmp1 ResName "BR_VERDE" OF oPanel Size 10,10 NoBorder When .F. Pixel 
@ aPosObj[5,1],285 SAY STR0099 OF oPanel Color CLR_BLACK PIXEL		//"Configuração padrão"

@ aPosObj[5,1],345 BITMAP oBmp2 ResName "BR_VERMELHO" OF oPanel Size 10,10 NoBorder When .F. Pixel 
@ aPosObj[5,1],355 SAY STR0100 OF oPanel Color CLR_BLACK PIXEL	//"Configuração específica"

@ aPosObj[6,1],aPosObj[6,2]  SAY STR0020 OF oPanel COLOR CLR_BLUE PIXEL SIZE 55,9 //"Itens do atendimento"
@ aPosObj[7,1],aPosObj[7,2]  MSGET oDetail VAR Self:service:tableStructureInfo:detail:alias Picture PesqPict('SKA','KA_ALIDET') OF oPanel PIXEL VALID {||IIF(Self:service:tableStructureInfo:detail:load(AllTrim(Self:service:tableStructureInfo:detail:alias)),Eval({||Self:getAFields(Self:service:tableStructureInfo:detail, @oDetailBrowse, @aDetList),.T.}),Eval({||Aviso(STR0004,STR0021,{"OK"}),.F.}))} When !Self:lReadOnly SIZE 70 ,9 F3 'HSPSX2'				//"Configurador" # "Informe corretamente o nome da tabela que deverá conter os itens do atendimento." #

oDetailBrowse := TCBrowse():New( aPosObj[8,1],aPosObj[8,2], aPosObj[8,3],aPosObj[8,4],, {'', STR0012,STR0013, STR0014, STR0015,STR0016,STR0017},{20,50,50,50,50,50,50},; //"Ordem" # "Nome" # "Titulo" # "Descrição" # "Nível" # "Tipo"
                            oPanel,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,,, )

aDetList := Self:getAFields(Self:service:tableStructureInfo:detail, @oDetailBrowse, @aDetList)

@ aPosObj[9,1],aPosObj[9,2]	BUTTON STR0066	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION Self:customizeField(2,oDetailBrowse) //"Alterar"
@ aPosObj[9,1],aPosObj[9,2]+45	BUTTON STR0098	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION Self:restoreField(2,oDetailBrowse)   //"Restaurar"
  		
@ aPosObj[9,1],275 BITMAP oBmp1 ResName "BR_VERDE" OF oPanel Size 10,10 NoBorder When .F. Pixel 
@ aPosObj[9,1],285 SAY STR0099 OF oPanel Color CLR_BLACK PIXEL 		//"Configuração padrão"

@ aPosObj[9,1],345 BITMAP oBmp2 ResName "BR_VERMELHO" OF oPanel Size 10,10 NoBorder When .F. Pixel 
@ aPosObj[9,1],355 SAY STR0100 OF oPanel Color CLR_BLACK PIXEL	//"Configuração específica"
					 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao de painel para informar o relacionamento de tabelas.             	   ³   
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard  	HEADER 	STR0001 + cAction; //"Ação escolhida - "
						MESSAGE STR0022 ;  //" Define os campos utilizados no relacionamento de tabelas do modelo de atendimento  "
					 	NEXT {||IIf(Len(Self:service:tableStructureInfo:aRelations)<=0,Eval({||Aviso(STR0004,STR0023, {"OK"}),.F.}),.T.)};//"Configurador" # "Informe os campos utilizados no relacionamento das tabelas" # 
					 	FINISH {||.T.} PANEL
					    	
aObjects := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do posicionamento dos objetos no painel    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aObjects, { 001, 020, .T., .F. } )
AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 200, 050, .T., .F., .T. } )
AAdd( aObjects, { 001, 015/*030*/, .T., .F. } )  

AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )

AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )

AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )

AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )

AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )

								 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo de coordenadas dos objetos da tela de acordo com as coordenada do painel.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
oPanel 	:= oWizard:GetPanel(3)
aInfo   := { 0, 0, oPanel:nClientHeight, oPanel:nClientWidth, 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )	 
                        

@ aPosObj[2,1],aPosObj[2,2]  SAY STR0024 OF oPanel COLOR CLR_BLUE PIXEL SIZE 200,9 //"Relacionamentos existentes" #
oRelBrowse := TCBrowse():New( aPosObj[3,1],aPosObj[3,2], aPosObj[3,3],aPosObj[3,4],, {STR0025, STR0026},{50,50},; //"Campo na tabela do Cabeçalho" # "Campos na tabela de Itens"
                            oPanel,,,,,{||},,oFont,,,,,.T./*lUpdate*/,,.T.,,.T./*lDesign*/,,, )  

Self:updRelBrowse(@aRelBrowse, @oRelBrowse, Self:service:tableStructureInfo, @aRelIndex)

@ aPosObj[4,1],aPosObj[4,2]	 	BUTTON STR0027	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION Eval({||oRelation:=TSRelation():New(),IIf(Self:dlgRelation(oRelation),Eval({||Self:service:tableStructureInfo:addRelation(oRelation),Self:updRelBrowse(@aRelBrowse, @oRelBrowse, Self:service:tableStructureInfo, @aRelIndex),oRelBrowse:goBottom()}),)}) //"Incluir"
@ aPosObj[4,1],aPosObj[4,2]+45	 	BUTTON STR0028 	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION IIf(Len(aRelIndex)>0,Eval({||IIf(Self:dlgRelation(@Self:service:tableStructureInfo:aRelations[aRelIndex[oRelBrowse:nAt]]),Self:updRelBrowse(@aRelBrowse, @oRelBrowse, Self:service:tableStructureInfo, @aRelIndex),)}),) //"Alterar"
@ aPosObj[4,1],aPosObj[4,2]+90		BUTTON STR0029 	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION IIf(Len(aRelIndex)>0,Eval({||IIf(Self:dlgRelation(Self:service:tableStructureInfo:aRelations[aRelIndex[oRelBrowse:nAt]], .T.),Eval({||Self:service:tableStructureInfo:delRelation(Self:service:tableStructureInfo:aRelations[aRelIndex[oRelBrowse:nAt]]),Self:updRelBrowse(@aRelBrowse, @oRelBrowse, Self:service:tableStructureInfo, @aRelIndex),oRelBrowse:goBottom()}),)}),) //"Apagar"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao de painel para informar os campos utilizados no TeleAtendimento  	   ³   
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard  	HEADER 	STR0001 + cAction; //"Ação escolhida - "
						MESSAGE STR0022 ;  //" Define os campos utilizados no relacionamento de tabelas do modelo de atendimento  "
					 	NEXT {||IIf(Empty(Self:service:tableStructureInfo:contactField:name)	, Eval({||Aviso(STR0004,STR0073,{"OK"}),.F.}),;
								IIF(Empty(Self:service:tableStructureInfo:entityName:name)		, Eval({||Aviso(STR0004,STR0090,{"OK"}),.F.}),; //"Informe o nome do campo para armazenar o nome da entidade"
								IIF(Empty(Self:service:tableStructureInfo:entityKey:name)		, Eval({||Aviso(STR0004,STR0091,{"OK"}),.F.}),; //"Informe o nome do campo para armazenar a chave de busca da entidade"
								IIF(Empty(Self:service:tableStructureInfo:entityIndex:name)		, Eval({||Aviso(STR0004,STR0092,{"OK"}),.F.}),; //"Informe o nome do campo para armazenar o número do indice utilizado na chave da entidade"
								IIF(Empty(Self:service:tableStructureInfo:registerCode:name)	, Eval({||Aviso(STR0004,"Informe o nome do campo para armazenar o código do atendimento",{"OK"}),.F.}),.T.)))))}/*{||}*/; //"Informe o nome do campo para armazenar o código do atendimento"
					 	FINISH {||.T.} PANEL
					    	
aObjects := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do posicionamento dos objetos no painel    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aObjects, { 001, 020, .T., .F. } )

AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )

AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )

AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )

AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )

AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )

AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )

AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )

AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )

								 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo de coordenadas dos objetos da tela de acordo com as coordenada do painel.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
oPanel 	:= oWizard:GetPanel(4)
aInfo   := { 0, 0, oPanel:nClientHeight, oPanel:nClientWidth, 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )	 

@ aPosObj[2,1],aPosObj[2,2]  SAY STR0072 OF oPanel COLOR CLR_BLUE PIXEL SIZE 200,9 //"Campo na tabela cabeçalho para armazenar o código do contato"
@ aPosObj[3,1],aPosObj[3,2]  MSGET oFieldCont VAR Self:service:tableStructureInfo:contactField:name Picture PesqPict('SKA','KA_CPCONT') OF oPanel PIXEL  When .F. SIZE 70 ,9  				 	
@ aPosObj[3,1],aPosObj[3,2]+ 75  BUTTON STR0052 	SIZE 60,12 OF oPanel PIXEL WHEN Eval({||!Self:lReadOnly}) ACTION Self:QuerySX3(Self:service:tableStructureInfo:master:alias, @Self:service:tableStructureInfo:contactField:name) //"Consulta campos"							 

@ aPosObj[4,1],aPosObj[4,2]  SAY STR0087 OF oPanel COLOR CLR_BLUE PIXEL SIZE 300,9 //"Campo na tabela cabeçalho para armazenar o nome da entidade associada ao contato"
@ aPosObj[5,1],aPosObj[5,2]  MSGET oFieldEntName VAR Self:service:tableStructureInfo:entityName:name Picture PesqPict('SKA','KA_CPNMENT') OF oPanel PIXEL  When .F. SIZE 70 ,9  				 	
@ aPosObj[5,1],aPosObj[5,2]+ 75  BUTTON STR0052 	SIZE 60,12 OF oPanel PIXEL WHEN Eval({||!Self:lReadOnly}) ACTION Self:QuerySX3(Self:service:tableStructureInfo:master:alias, @Self:service:tableStructureInfo:entityName:name) //"Consulta campos"							 

@ aPosObj[6,1],aPosObj[6,2]  SAY STR0088 OF oPanel COLOR CLR_BLUE PIXEL SIZE 300,9 //"Campo na tabela cabeçalho para armazenar a chave de busca da entidade associada ao contato"
@ aPosObj[7,1],aPosObj[7,2]  MSGET oFieldEntKey VAR Self:service:tableStructureInfo:entityKey:name Picture PesqPict('SKA','KA_CPCHAVE') OF oPanel PIXEL  When .F. SIZE 70 ,9  				 	
@ aPosObj[7,1],aPosObj[7,2]+ 75  BUTTON STR0052 	SIZE 60,12 OF oPanel PIXEL WHEN Eval({||!Self:lReadOnly}) ACTION Self:QuerySX3(Self:service:tableStructureInfo:master:alias, @Self:service:tableStructureInfo:entityKey:name) //"Consulta campos"							 

@ aPosObj[8,1],aPosObj[8,2]  SAY STR0089 OF oPanel COLOR CLR_BLUE PIXEL SIZE 300,9 //"Campo na tabela cabeçalho para armazenar o número do indice da entidade associada ao contato"
@ aPosObj[9,1],aPosObj[9,2]  MSGET oFieldEntIdx VAR Self:service:tableStructureInfo:entityIndex:name Picture PesqPict('SKA','KA_CPIDXCH') OF oPanel PIXEL  When .F. SIZE 70 ,9  				 	
@ aPosObj[9,1],aPosObj[9,2]+ 75  BUTTON STR0052 	SIZE 60,12 OF oPanel PIXEL WHEN Eval({||!Self:lReadOnly}) ACTION Self:QuerySX3(Self:service:tableStructureInfo:master:alias, @Self:service:tableStructureInfo:entityIndex:name) //"Consulta campos"							 

@ aPosObj[10,1],aPosObj[10,2]  SAY "Campo na tabela cabeçalho que contém o Código de Atendimento" OF oPanel COLOR CLR_BLUE PIXEL SIZE 300,9 //"Campo na tabela cabeçalho que contém o Código da Campanha"
@ aPosObj[11,1],aPosObj[11,2]  MSGET oFieldRegCod VAR Self:service:tableStructureInfo:registerCode:name Picture PesqPict('SKA','KA_REGCOD') OF oPanel PIXEL  When .F. SIZE 70 ,9  				 	
@ aPosObj[11,1],aPosObj[11,2]+ 75  BUTTON STR0052 	SIZE 60,12 OF oPanel PIXEL WHEN Eval({||!Self:lReadOnly}) ACTION Self:QuerySX3(Self:service:tableStructureInfo:master:alias, @Self:service:tableStructureInfo:registerCode:name) //"Consulta campos"							                           

@ aPosObj[12,1],aPosObj[12,2]  SAY "Campo na tabela cabeçalho que contém o Código da Campanha" OF oPanel PIXEL SIZE 300,9 //"Campo na tabela cabeçalho que contém o Código da Campanha"
@ aPosObj[13,1],aPosObj[13,2]  MSGET oFieldCampKey VAR Self:service:tableStructureInfo:campaignKey:name Picture PesqPict('SKA','KA_CMPKEY') OF oPanel PIXEL  When .F. SIZE 70 ,9  				 	
@ aPosObj[13,1],aPosObj[13,2]+ 75  BUTTON STR0052 	SIZE 60,12 OF oPanel PIXEL WHEN Eval({||!Self:lReadOnly}) ACTION Self:QuerySX3(Self:service:tableStructureInfo:master:alias, @Self:service:tableStructureInfo:campaignKey:name) //"Consulta campos"							 

@ aPosObj[14,1],aPosObj[14,2]  SAY "Campo na tabela cabeçalho que contém o Tipo de Atendimento. Normalmente: 1-Receptivo e 2-Ativo" OF oPanel PIXEL SIZE 300,9 //"Campo na tabela cabeçalho que contém o Código da Campanha"
@ aPosObj[15,1],aPosObj[15,2]  MSGET oFieldOpCode VAR Self:service:tableStructureInfo:operationCode:name Picture PesqPict('SKA','KA_OPCODI') OF oPanel PIXEL  When .F. SIZE 70 ,9  				 	
@ aPosObj[15,1],aPosObj[15,2]+ 75  BUTTON STR0052 	SIZE 60,12 OF oPanel PIXEL WHEN Eval({||!Self:lReadOnly}) ACTION Self:QuerySX3(Self:service:tableStructureInfo:master:alias, @Self:service:tableStructureInfo:operationCode:name) //"Consulta campos"							                           

@ aPosObj[16,1],aPosObj[16,2]  SAY STR0093 OF oPanel PIXEL SIZE 300,9 //"Campo que deve ser inicializado no MsGetDados"
@ aPosObj[17,1],aPosObj[17,2]  MSGET oFieldGDInit VAR Self:service:tableStructureInfo:initGDField:name Picture PesqPict('SKA','KA_CPGDINI') OF oPanel PIXEL  When .F. SIZE 70 ,9  				 	
@ aPosObj[17,1],aPosObj[17,2]+ 75  BUTTON STR0052 	SIZE 60,12 OF oPanel PIXEL WHEN Eval({||!Self:lReadOnly}) ACTION Self:QuerySX3(Self:service:tableStructureInfo:detail:alias, @Self:service:tableStructureInfo:initGDField:name) //"Consulta campos"							 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao de painel para configurar os pontos de entrada da aplicacao.     	   ³   
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard  	HEADER 	STR0001 + cAction; //"Ação escolhida - "
						MESSAGE STR0030 ;  //" Define as funções a serem executadas pelo modelo de atendimento "
					 	NEXT /*{||}*/;
					 	FINISH {||.T.} PANEL
					    	
aObjects := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do posicionamento dos objetos no painel    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aObjects, { 001, 020, .T., .F. } )
AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )
AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )
AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )
AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )
AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )
AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )
AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )	
AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 010, .T., .F. } )	
								 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo de coordenadas dos objetos da tela de acordo com as coordenada do painel.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
oPanel 	:= oWizard:GetPanel(5)
aInfo   := { 0, 0, oPanel:nClientHeight, oPanel:nClientWidth, 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )	 

@ aPosObj[2,1],aPosObj[2,2]  SAY STR0031 OF oPanel PIXEL SIZE 200,9 //"Ao abrir a tela de atendimento:"
@ aPosObj[3,1],aPosObj[3,2]  MSGET oWOpWin1 VAR Self:service:whenOpenWindow:codeBlock Picture PesqPict('SKA','KA_ABRTELA') OF oPanel PIXEL VALID {||IIF(Self:service:whenOpenWindow:setCodeBlock(Self:service:whenOpenWindow:codeBlock).OR.Empty(Self:service:whenOpenWindow:codeBlock),.T.,Eval({||Aviso(STR0004,STR0032,{"OK"}),.F.}))} When !Self:lReadOnly SIZE 70 ,9 	//"Configurador" # 	"Função não encontrada no repositório do Protheus." # 

@ aPosObj[4,1],aPosObj[4,2]  SAY STR0033 OF oPanel PIXEL SIZE 200,9 
@ aPosObj[5,1],aPosObj[5,2]  MSGET oWOpWin2 VAR Self:service:whenSelectContact:codeBlock Picture PesqPict('SKA','KA_CONTSEL') OF oPanel PIXEL VALID {||IIF(Self:service:whenSelectContact:setCodeBlock(Self:service:whenSelectContact:codeBlock).OR.Empty(Self:service:whenSelectContact:codeBlock),.T.,Eval({||Aviso(STR0004,STR0032,{"OK"}),.F.}))} When !Self:lReadOnly SIZE 70 ,9 		//"Configurador" # "Função não encontrada no repositório do Protheus."

@ aPosObj[6,1],aPosObj[6,2]  SAY STR0034 OF oPanel PIXEL SIZE 200,9 //"Antes de gravar o atendimento:"
@ aPosObj[7,1],aPosObj[7,2]  MSGET oWOpWin3 VAR Self:service:whenRecord:codeBlock Picture PesqPict('SKA','KA_ANTGRAV') OF oPanel PIXEL VALID {||IIF(Self:service:whenRecord:setCodeBlock(Self:service:whenRecord:codeBlock).OR.Empty(Self:service:whenRecord:codeBlock),.T.,Eval({||Aviso(STR0004,STR0032,{"OK"}),.F.}))} When !Self:lReadOnly SIZE 70 ,9 		// "Configurador" # "Função não encontrada no repositório do Protheus."

@ aPosObj[8,1],aPosObj[8,2]  SAY STR0035 OF oPanel PIXEL SIZE 200,9 //"Após gravar o atendimento:"
@ aPosObj[9,1],aPosObj[9,2]  MSGET oWOpWin4 VAR Self:service:whenRecorded:codeBlock Picture PesqPict('SKA','KA_APOGRAV') OF oPanel PIXEL VALID {||IIF(Self:service:whenRecorded:setCodeBlock(Self:service:whenRecorded:codeBlock).OR.Empty(Self:service:whenRecorded:codeBlock),.T.,Eval({||Aviso(STR0004,STR0032,{"OK"}),.F.}))} When !Self:lReadOnly SIZE 70 ,9 // "Configurador" # "Função não encontrada no repositório do Protheus."		

@ aPosObj[10,1],aPosObj[10,2]  SAY STR0036 OF oPanel PIXEL SIZE 200,9 //"Ao fechar a tela de atendimento:"
@ aPosObj[11,1],aPosObj[11,2]  MSGET oWOpWin5 VAR Self:service:whenCloseWindow:codeBlock Picture PesqPict('SKA','KA_ENCTELA') OF oPanel PIXEL VALID {||IIF(Self:service:whenCloseWindow:setCodeBlock(Self:service:whenCloseWindow:codeBlock).OR.Empty(Self:service:whenCloseWindow:codeBlock),.T.,Eval({||Aviso(STR0004,STR0032,{"OK"}),.F.}))} When !Self:lReadOnly SIZE 70 ,9 // "Configurador" # "Função não encontrada no repositório do Protheus."		

@ aPosObj[12,1],aPosObj[12,2]  SAY STR0037 OF oPanel PIXEL SIZE 200,9 //"Ao pressionar o botão OK da tela de atendimento:"
@ aPosObj[13,1],aPosObj[13,2]  MSGET oWOpWin6 VAR Self:service:whenPressedOKBtn:codeBlock Picture PesqPict('SKA','KA_PEBTNOK') OF oPanel PIXEL VALID {||IIF(Self:service:whenPressedOKBtn:setCodeBlock(Self:service:whenPressedOKBtn:codeBlock).OR.Empty(Self:service:whenPressedOKBtn:codeBlock),.T.,Eval({||Aviso(STR0004,STR0032,{"OK"}),.F.}))} When !Self:lReadOnly SIZE 70 ,9 // "Configurador" # "Função não encontrada no repositório do Protheus."		

@ aPosObj[14,1],aPosObj[14,2]  SAY STR0038 OF oPanel PIXEL SIZE 200,9 //"Ao pressionar o botão Histórico da tela de atendimento:"
@ aPosObj[15,1],aPosObj[15,2]  MSGET oWOpWin7 VAR Self:service:whenPressedHistory:codeBlock Picture PesqPict('SKA','KA_PEHIST') OF oPanel PIXEL VALID {||IIF(Self:service:whenPressedHistory:setCodeBlock(Self:service:whenPressedHistory:codeBlock).OR.Empty(Self:service:whenPressedHistory:codeBlock),.T.,Eval({||Aviso(STR0004,STR0032,{"OK"}),.F.}))} When !Self:lReadOnly SIZE 70 ,9 // "Configurador" # "Função não encontrada no repositório do Protheus."		

@ aPosObj[16,1],aPosObj[16,2]  SAY STR0094 OF oPanel PIXEL SIZE 200,9 //"Validar a linha digitada no MSGETDADOS:"
@ aPosObj[17,1],aPosObj[17,2]  MSGET oWOpWin7 VAR Self:service:validGDItem:codeBlock Picture PesqPict('SKA','KA_PEGDIT') OF oPanel PIXEL VALID {||IIF(Self:service:validGDItem:setCodeBlock(Self:service:validGDItem:codeBlock).OR.Empty(Self:service:validGDItem:codeBlock),.T.,Eval({||Aviso(STR0004,STR0032,{"OK"}),.F.}))} When !Self:lReadOnly SIZE 70 ,9 // "Configurador" # "Função não encontrada no repositório do Protheus."		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao de painel para criar os botoes da tela de atendimento.           	   ³   
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard  	HEADER 	STR0001 + cAction; //"Ação escolhida - "
						MESSAGE STR0039 ;  //" Define os botões que deverão aparecer na tela de atendimento do modelo "
					 	NEXT {||Self:getAbstractText(@cAbstract)};
					 	FINISH {||lFinish:=.T.} PANEL
					    	
aObjects := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do posicionamento dos objetos no painel    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aObjects, { 001, 020, .T., .F. } )
AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 050, .T., .F., .T. } )
AAdd( aObjects, { 200, 020, .T., .F. } )

AAdd( aObjects, { 001, 005, .T., .F. } )
AAdd( aObjects, { 001, 050, .T., .F., .T. } )
AAdd( aObjects, { 200, 020, .T., .F. } )
								 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo de coordenadas dos objetos da tela de acordo com as coordenada do painel.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
oPanel 	:= oWizard:GetPanel(6)
aInfo   := { 0, 0, oPanel:nClientHeight, oPanel:nClientWidth, 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )	 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BARRA DE FERRAMENTAS SUPERIOR ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPosObj[2,1],aPosObj[2,2]  SAY STR0040 OF oPanel PIXEL SIZE 200,9  //"Barra de ferramentas Superior"
oTopBrowse := TCBrowse():New( aPosObj[3,1],aPosObj[3,2], aPosObj[3,3],aPosObj[3,4],, {STR0013, STR0012,STR0041, STR0042, STR0043, STR0006},{50,50,50,50,50,50},; //"Nome" # "Ordem" # "Figura" # "Função a ser executada" # "Help do Botão" # "Código"
                            oPanel,,,,,{||},,oFont,,,,,.T./*lUpdate*/,,.T.,,.T./*lDesign*/,,, )  

Self:updBtnBrowse(@aTopBtns, @oTopBrowse, Self:service:toolbarTop)
                    	
@ aPosObj[4,1],aPosObj[4,2]	 	BUTTON STR0027 	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION Eval({||oNewButton:=TSToolbarButton():New(),IIf(Self:dlgButton(oNewButton),Eval({||Self:service:toolbarTop:add(oNewButton),Self:updBtnBrowse(@aTopBtns, @oTopBrowse, @Self:service:toolbarTop),oTopBrowse:goBottom()}),)}) //"Incluir"
@ aPosObj[4,1],aPosObj[4,2]+45		BUTTON STR0028 	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION IIf(Len(Self:service:toolbarTop:aButtons)>0,Eval({||IIf(Self:dlgButton(@Self:service:toolbarTop:aButtons[AScan(Self:service:toolbarTop:aButtons,{|x| x:id == aTopBtns[oTopBrowse:nAt][6]})]),Self:updBtnBrowse(@aTopBtns, @oTopBrowse, @Self:service:toolbarTop),)}),) //"Alterar"
@ aPosObj[4,1],aPosObj[4,2]+90 	BUTTON STR0029 	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION IIf(Len(Self:service:toolbarTop:aButtons)>0,Eval({||oNewButton:=Self:service:toolbarTop:aButtons[AScan(Self:service:toolbarTop:aButtons,{|x| x:id == aTopBtns[oTopBrowse:nAt][6]})],IIf(Self:dlgButton(oNewButton, .T.),Eval({||Self:service:toolbarTop:delete(oNewButton),Self:updBtnBrowse(@aTopBtns, @oTopBrowse, @Self:service:toolbarTop)}),)}),) //"Apagar"
@ aPosObj[4,1],aPosObj[4,2]+135 	BUTTON STR0044 	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION Eval({||Self:alterPosBtn(@Self:service:toolbarTop, oTopBrowse:nAt, aTopBtns, 1, oTopBrowse),Self:updBtnBrowse(@aTopBtns, @oTopBrowse, @Self:service:toolbarTop)})  //"Subir"
@ aPosObj[4,1],aPosObj[4,2]+180 	BUTTON STR0045 	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION Eval({||Self:alterPosBtn(@Self:service:toolbarTop, oTopBrowse:nAt, aTopBtns, 2, oTopBrowse),Self:updBtnBrowse(@aTopBtns, @oTopBrowse, @Self:service:toolbarTop)}) //"Descer" 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BARRA DE FERRAMENTAS LATERAL  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPosObj[5,1],aPosObj[5,2]  SAY STR0046 OF oPanel PIXEL SIZE 200,9        //"Barra de ferramentas Lateral"
oSideBrowse := TCBrowse():New( aPosObj[6,1],aPosObj[6,2], aPosObj[6,3],aPosObj[6,4],, {STR0013, STR0012,STR0041, STR0042, STR0043, STR0006},{50,50,50,50,50,50},;  //"Nome" # "Ordem" # "Figura" # "Função a ser executada" # "Help do Botão" # "Código"
                            oPanel,,,,,{||},,oFont,,,,,.T./*lUpdate*/,,.T.,,.T./*lDesign*/,,, )  

Self:updBtnBrowse(@aSideBtns, @oSideBrowse, Self:service:toolbarSide)
                    	
@ aPosObj[7,1],aPosObj[7,2]	 	BUTTON STR0027 	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION Eval({||oNewButton:=TSToolbarButton():New(),IIf(Self:dlgButton(oNewButton),Eval({||Self:service:toolbarSide:add(oNewButton),Self:updBtnBrowse(@aSideBtns, @oSideBrowse, @Self:service:toolbarSide),oSideBrowse:goBottom()}),)}) //"Incluir"
@ aPosObj[7,1],aPosObj[7,2]+45		BUTTON STR0028 	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION IIf(Len(Self:service:toolbarSide:aButtons)>0,Eval({||IIf(Self:dlgButton(@Self:service:toolbarSide:aButtons[AScan(Self:service:toolbarSide:aButtons,{|x| x:id == aSideBtns[oSideBrowse:nAt][6]})]),Self:updBtnBrowse(@aSideBtns, @oSideBrowse, @Self:service:toolbarSide),)}),) //"Alterar"
@ aPosObj[7,1],aPosObj[7,2]+90 	BUTTON STR0029 	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION IIf(Len(Self:service:toolbarSide:aButtons)>0,Eval({||oNewButton:=Self:service:toolbarSide:aButtons[AScan(Self:service:toolbarSide:aButtons,{|x| x:id == aSideBtns[oSideBrowse:nAt][6]})],IIf(Self:dlgButton(oNewButton),Eval({||Self:service:toolbarSide:delete(oNewButton),Self:updBtnBrowse(@aSideBtns, @oSideBrowse, @Self:service:toolbarSide)}),)}),) //"Apagar"
@ aPosObj[7,1],aPosObj[7,2]+135 	BUTTON STR0044 	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION Eval({||Self:alterPosBtn(Self:service:toolbarSide, oSideBrowse:nAt, aSideBtns, 1, oSideBrowse),Self:updBtnBrowse(@aSideBtns, @oSideBrowse, @Self:service:toolbarSide)})  //"Subir"
@ aPosObj[7,1],aPosObj[7,2]+180 	BUTTON STR0045 	SIZE 40,12 OF oPanel PIXEL WHEN !Self:lReadOnly ACTION Eval({||Self:alterPosBtn(Self:service:toolbarSide, oSideBrowse:nAt, aSideBtns, 2, oSideBrowse),Self:updBtnBrowse(@aSideBtns, @oSideBrowse, @Self:service:toolbarSide)})   //"Descer"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao de painel para criar os botoes da tela de atendimento.           	   ³   
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard  	HEADER 	STR0001 + cAction; //"Ação escolhida - "
						MESSAGE STR0095 ;  //"Resumo das alterações a serem realizadas pelo configurador"
					 	NEXT /*{||}*/;
					 	FINISH {||lFinish:=.T.} PANEL
					    	
aObjects := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do posicionamento dos objetos no painel    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aObjects, { 001, 020, .T., .F. } )
AAdd( aObjects, { 800, 200, .T., .F., .T. } )
								 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo de coordenadas dos objetos da tela de acordo com as coordenada do painel.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
oPanel 	:= oWizard:GetPanel(7)
aInfo   := { 0, 0, oPanel:nClientHeight, oPanel:nClientWidth, 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )	       

//Self:getAbstractText(@cAbstract)
cAbstract := ""

@ aPosObj[2,1],aPosObj[2,2] GET oAbstract VAR cAbstract MEMO SIZE aPosObj[2,3],aPosObj[2,4] FONT oFont READONLY OF oPanel PIXEL 
oAbstract:Align := CONTROL_ALIGN_TOP

ACTIVATE WIZARD oWizard WHEN {||.T.}							 

Return lFinish                   
         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³getAbstractTextºAutor³Michel W. Mosca  º Data ³  07/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe uma tela de dialogo para preencher os dados do        º±±
±±º          ³relacionamento de tabelas                                   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ getAbstractText(ExpC1)                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Retorno do texto a ser exibido               	  ³±±
±±³          ³                                                            ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method getAbstractText(cText) Class TeleServiceMaintenance 
Local nCount
Default cText := ""

cText := "" + CRLF
cText += STR0074 + Self:service:name + CRLF //"Nome do modelo de Atendimento: "
cText += "" + CRLF
cText += STR0075 + Self:service:tableStructureInfo:master:alias + CRLF //"Tabela definida para cabeçalho do atendimento : "
cText += STR0076 + Self:service:tableStructureInfo:detail:alias + CRLF //"Tabela definida para os itens do atendimento  : "
cText += "" + CRLF
cText += STR0077 + CRLF //"Relacionamentos incluidos: "
For nCount := 1 To Len(Self:service:tableStructureInfo:aRelations)
	cText += " - " + Self:service:tableStructureInfo:aRelations[nCount]:master:name + " -> " + Self:service:tableStructureInfo:aRelations[nCount]:detail:name	 + CRLF
Next nCount       
cText += "" + CRLF
cText += STR0078 + Self:service:tableStructureInfo:contactField:name + CRLF //"Campo para armazenar o código do contato do atendimento : "
cText += "" + CRLF
cText += STR0079 + CRLF //"Ação a ser executada : "
cText += STR0080 + IIF(!Empty(Self:service:whenOpenWindow:codeBlock),Self:service:whenOpenWindow:codeBlock,STR0097) + CRLF 			//" - Ao abrir a tela de atendimento                 : " # "<Não usado>"
cText += STR0081 + IIF(!Empty(Self:service:whenSelectContact:codeBlock),Self:service:whenSelectContact:codeBlock,STR0097) + CRLF 		//" - Ao selecionar um contato                       : " # "<Não usado>"
cText += STR0082 + IIF(!Empty(Self:service:whenRecord:codeBlock),Self:service:whenRecord:codeBlock,STR0097) + CRLF 					//" - Antes de gravar o atendimento                  : " # "<Não usado>"
cText += STR0083 + IIF(!Empty(Self:service:whenRecorded:codeBlock),Self:service:whenRecorded:codeBlock,STR0097) + CRLF 				//" - Após gravar o atendimento                      : " # "<Não usado>"
cText += STR0084 + IIF(!Empty(Self:service:whenCloseWindow:codeBlock),Self:service:whenCloseWindow:codeBlock,STR0097) + CRLF 			//" - Ao fechar a tela de atendimento                : " # "<Não usado>"
cText += STR0085 + IIF(!Empty(Self:service:whenPressedOKBtn:codeBlock),Self:service:whenPressedOKBtn:codeBlock,STR0097) + CRLF   		//" - Ao pressionar o botão OK da tela de atendimento: " # "<Não usado>"
cText += STR0086 + IIF(!Empty(Self:service:whenPressedHistory:codeBlock),Self:service:whenPressedHistory:codeBlock,STR0097) + CRLF 	//" - Ao iniciar o histórico de atendimentos         : " # "<Não usado>"
cText += STR0096 + IIF(!Empty(Self:service:validGDItem:codeBlock),Self:service:validGDItem:codeBlock,STR0097) + CRLF 					//" - Validar a linha digitada no MSGetDados         : " # "<Não usado>"
Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³dlgRelation  ºAutor  ³Michel W. Mosca  º Data ³  07/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe uma tela de dialogo para preencher os dados do        º±±
±±º          ³relacionamento de tabelas                                   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ dlgRelation(ExpO1, ExpN2, ExpA3,ExpN4)                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = TSRelation a ser editado							  ³±±
±±³          ³ ExpL2 = Flag indicando se sera apagado 			          ³±±
±±³          ³                                                            ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method dlgRelation(oTSRelation, lDel) Class TeleServiceMaintenance  
Local oDlg    
Local aObjects := {}
Local aInfo := {}   
Local aPosObj := {}
Local lRet := .F.						//Flag indicando se o usuario realizou alguma alteração
Local bConfirm 	:= {||.T.}			  	//Code block para confirmacao da alteracao
Local oClone := oTSRelation:clone()    	//Armazena um clone do objeto antes das alterações 

Default lDel := .F.

If !lDel 
	If Val(oTSRelation:id) > 0 
		bConfirm := {||TmkOK(STR0047)} //"Confirma a alteação nas informações do relacionamento de tabela?"
	Else	
		bConfirm := {||TmkOK(STR0048)} //"Confirma a inclusão de um novo relacionamento de tabela?"
	EndIf
Else
	bConfirm := {||TmkOK(STR0049)} //"Confirma a exclusão do relacionamento de tabela?"
EndIf

DEFINE MSDIALOG oDlg Title STR0050 FROM 0,0 TO 340,500 PIXEL //"Informações de relacionamento de tabelas"

		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo do posicionamento dos objetos no painel    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aObjects, { 001, 020, .T., .F. } )
	AAdd( aObjects, { 001, 005, .T., .F. } )
	AAdd( aObjects, { 001, 010, .T., .F. } )
	AAdd( aObjects, { 001, 005, .T., .F. } )
	AAdd( aObjects, { 001, 010, .T., .F. } )
	AAdd( aObjects, { 001, 005, .T., .F. } )
	AAdd( aObjects, { 001, 010, .T., .F. } )
	AAdd( aObjects, { 001, 005, .T., .F. } )
	AAdd( aObjects, { 001, 010, .T., .F. } )		
	AAdd( aObjects, { 001, 005, .T., .F. } )
	AAdd( aObjects, { 001, 010, .T., .F. } )	
									 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo de coordenadas dos objetos da tela de acordo com as coordenada do painel.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	
	aInfo   := { 0, 0, oDlg:nClientHeight, oDlg:nClientWidth, 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	@ aPosObj[2,1],aPosObj[2,2]  SAY STR0051 OF oDlg PIXEL SIZE 200,9 //"Campo na tabela cabeçalho:"
	@ aPosObj[3,1],aPosObj[3,2]  MSGET oWOpWin1 VAR oTSRelation:master:name Picture PesqPict('SKB','KB_CPOMAST') OF oDlg PIXEL  When .F. SIZE 70 ,9  				 		
	@ aPosObj[3,1],aPosObj[3,2]+ 75  BUTTON STR0052 	SIZE 60,12 OF oDlg PIXEL WHEN Eval({||!Self:lReadOnly .AND. !lDel}) ACTION Self:QuerySX3(Self:service:tableStructureInfo:master:alias, @oTSRelation:master:name) //"Consulta campos"
	
	@ aPosObj[4,1],aPosObj[4,2]  SAY STR0053 OF oDlg PIXEL SIZE 200,9 //"Campo na tabela itens do atendimento:"
	@ aPosObj[5,1],aPosObj[5,2]  MSGET oWOpWin1 VAR oTSRelation:detail:name Picture PesqPict('SKB','KB_CPODET') OF oDlg PIXEL  When .F. SIZE 70 ,9  				 	
	@ aPosObj[5,1],aPosObj[5,2]+ 75  BUTTON STR0052 	SIZE 60,12 OF oDlg PIXEL WHEN Eval({||!Self:lReadOnly .AND. !lDel}) ACTION Self:QuerySX3(Self:service:tableStructureInfo:detail:alias, @oTSRelation:detail:name) //"Consulta campos"
	
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End(),lRet:=Eval(bConfirm) }, {|| oDlg:End() }) 

//Restaura o objeto
If !lRet
	oTSRelation := oClone
EndIf

Return lRet
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³updRelBrowse ºAutor  ³Michel W. Mosca  º Data ³  07/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o browse de relacionamentos de tabelas             º±±
±±º          ³                                                            º±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ updRelBrowse(ExpA1, ExpO2, ExpO3)                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = array com lista de registros do Browse.            ³±±
±±³          ³ ExpO2 = MSBrowse                                           ³±±
±±³          ³ ExpO3 = TsToolbarlist                                      ³±±
±±³          ³                                                            ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method updRelBrowse(aRel, oBrowse, oRelations, aRelIndex) Class TeleServiceMaintenance
Local nCount //Contador

//Reinicia o array de exibicao no Browse
aRel := {}   
aRelIndex := {}
//toolbarList:sort()
For nCount:=1 To Len(oRelations:aRelations)
	If !oRelations:aRelations[nCount]:deleted
		AAdd(aRelIndex, nCount) 
		AAdd(aRel,; 
		{	AllTrim(oRelations:aRelations[nCount]:master:name),;     
			AllTrim(oRelations:aRelations[nCount]:detail:name)})
	EndIf
Next    

If Len(aRel) <= 0
	aRel := {{"",""}}
EndIf
                            
oBrowse:SetArray(aRel)
oBrowse:bLine := {||{	aRel[oBrowse:nAt,01],;
                    	aRel[oBrowse:nAt,02]}} 
Return Nil  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³dlgButton    ºAutor  ³Michel W. Mosca  º Data ³  06/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe uma tela de dialogo para preencher os dados do botao  º±±
±±º          ³da toolbar.                                                 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ dlgButton(ExpO1, ExpN2, ExpA3,ExpN4)                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = TSButton a ser editado 							  ³±±
±±³          ³ ExpL2 = Flag indicando se um botao sera apagado            ³±±
±±³          ³                                                            ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method dlgButton(oTSButton, lDel) Class TeleServiceMaintenance  
Local oDlg    
Local aObjects := {}
Local aInfo := {}   
Local aPosObj := {}
Local lRet := .F.						//Flag indicando se o usuario realizou alguma alteração
Local bConfirm 	:= {||.T.}			  	//Code block para confirmacao da alteracao
Local oClone := oTSButton:clone()    	//Armazena um clone do objeto antes das alterações

Default lDel := .F.

If !lDel 
	If Val(oTSButton:id) > 0 
		bConfirm := {||TmkOK(STR0054 + AllTrim(oTSButton:name) + "?")} //"Confirma a alteação nas informações do botão "
	Else	
		bConfirm := {||TmkOK(STR0055)} //"Confirma a inclusão de um novo botão?"
	EndIf
Else
	bConfirm := {||TmkOK(STR0056)} //"Confirma a exclusão do botão?"
EndIf

DEFINE MSDIALOG oDlg Title STR0057 FROM 0,0 TO 340,500 PIXEL  //"Informações de botão da toolbar"

	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo do posicionamento dos objetos no painel    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aObjects, { 001, 020, .T., .F. } )
	AAdd( aObjects, { 001, 005, .T., .F. } )
	AAdd( aObjects, { 001, 010, .T., .F. } )
	AAdd( aObjects, { 001, 005, .T., .F. } )
	AAdd( aObjects, { 001, 010, .T., .F. } )
	AAdd( aObjects, { 001, 005, .T., .F. } )
	AAdd( aObjects, { 001, 010, .T., .F. } )
	AAdd( aObjects, { 001, 005, .T., .F. } )
	AAdd( aObjects, { 001, 010, .T., .F. } )		
	AAdd( aObjects, { 001, 005, .T., .F. } )
	AAdd( aObjects, { 001, 010, .T., .F. } )	
	AAdd( aObjects, { 001, 005, .T., .F. } )
	AAdd( aObjects, { 001, 010, .T., .F. } )		
									 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo de coordenadas dos objetos da tela de acordo com as coordenada do painel.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	
	aInfo   := { 0, 0, oDlg:nClientHeight, oDlg:nClientWidth, 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	@ aPosObj[2,1],aPosObj[2,2]  SAY STR0006 OF oDlg PIXEL SIZE 200,9 //"Código:"
	@ aPosObj[3,1],aPosObj[3,2]  MSGET oWOpWin1 VAR oTSButton:id Picture PesqPict('SKJ','KJ_CODIGO') OF oDlg PIXEL  When .F. SIZE 70 ,9 				 		
	
	@ aPosObj[4,1],aPosObj[4,2]  SAY STR0007 OF oDlg PIXEL SIZE 200,9 //"Nome:"
	@ aPosObj[5,1],aPosObj[5,2]  MSGET oWOpWin1 VAR oTSButton:name Picture PesqPict('SKJ','KJ_NOME') OF oDlg PIXEL  When !Self:lReadOnly SIZE 70 ,9 				 	
	
	@ aPosObj[6,1],aPosObj[6,2]  SAY STR0041 OF oDlg PIXEL SIZE 200,9  //"Figura:"
	@ aPosObj[7,1],aPosObj[7,2]  MSGET oWOpWin1 VAR oTSButton:imageName Picture PesqPict('SKJ','KJ_IMAGEM') OF oDlg PIXEL  When !Self:lReadOnly SIZE 70 ,9 				 		

	@ aPosObj[8,1],aPosObj[8,2]  SAY STR0058 OF oDlg PIXEL SIZE 200,9 //"Função a ser executada quando pressionado o botão:"
	@ aPosObj[9,1],aPosObj[9,2]  MSGET oWOpWin1 VAR oTSButton:codeBlock Picture PesqPict('SKJ','KJ_CDBLOCK') OF oDlg PIXEL When !Self:lReadOnly VALID {||IIF(oTSButton:setCodeBlock(oTSButton:codeBlock),.T.,Eval({||Aviso(STR0004,STR0032,{"OK"}),.F.}))}  SIZE 70 ,9 	//"Configurador" # "Função não encontrada no repositório do Protheus."			 		                                                                                      

	@ aPosObj[10,1],aPosObj[10,2]  SAY STR0059 OF oDlg PIXEL SIZE 200,9 //"Texto de ajuda:"
	@ aPosObj[11,1],aPosObj[11,2]  MSGET oWOpWin1 VAR oTSButton:toolTipText Picture PesqPict('SKJ','KJ_AJUDA') OF oDlg PIXEL  When !Self:lReadOnly SIZE 70 ,9 				 		
	
	@ aPosObj[12,1],aPosObj[12,2]  SAY "Nível:" OF oDlg PIXEL SIZE 200,9 //"Nível:"
	@ aPosObj[13,1],aPosObj[13,2]  MSGET oWOpWin1 VAR oTSButton:userLevel Picture PesqPict('SKJ','KJ_USRLEVL') OF oDlg PIXEL  When !Self:lReadOnly SIZE 70 ,9 				 			
	
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End(),lRet:=Eval(bConfirm) }, {|| oDlg:End() })

//Restaura o objeto
If !lRet
	oTSButton := oClone
EndIf

Return lRet
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³alterPosBtn  ºAutor  ³Michel W. Mosca  º Data ³  06/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Posiciona botao uma posicao acima.                          º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ alterPosBtn(ExpO1, ExpN2, ExpA3,ExpN4,ExpO5)               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Toolbarlist            							  ³±±
±±³          ³ ExpN2 = posicao selecionada no browse.                     ³±±
±±³          ³ ExpA3 = array com lista de registros do Browse.            ³±±
±±³          ³ ExpN4 = Opcao Selecionada(1-Subir/2-Descer)                ³±±
±±³          ³ ExpO5 = Objeto browse                                      ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method alterPosBtn(toolbarList, nAt, aList, nOpc, oBrowse) Class TeleServiceMaintenance
Local nId
Local nCount             
Local oBfre := Nil	//Botao anterior
Local oAftr := Nil	//Botão posterior 
Local lFound:= .F.	//Encontrou o botao 
Local nAux			//Auxiliar na troca de posicao


If Len(aList)>0
	nID := AllTrim(aList[nAt][2]) 	
	For nCount:=1 To Len(toolbarList:aButtons)
		If nID == AllTrim(toolbarList:aButtons[nCount]:pos)
			lFound := .T.
			If nCount+1 <= Len(toolbarList:aButtons)
				oAftr := toolbarList:aButtons[nCount+1]
			EndIf  
			Exit
		EndIf
		oBfre := toolbarList:aButtons[nCount]
	
			
	Next nCount  
	If lFound
		If nOpc == 1 //Subir
			If oBfre != Nil
				nAux := oBfre:pos
			    oBfre:pos := toolbarList:aButtons[nCount]:pos			
				toolbarList:aButtons[nCount]:pos := nAux 
				oBrowse:goUp()			    
			Else
				Aviso(STR0004, STR0060, {"OK"})			// "Configurador" # "O botão já encontra-se na primeira posicao"
			EndIf		
		ElseIf nOpc == 2 //Descer
			If oAftr != Nil
				nAux := oAftr:pos
			    oAftr:pos := toolbarList:aButtons[nCount]:pos			
				toolbarList:aButtons[nCount]:pos := nAux  
				oBrowse:goDown()			    
			Else
				Aviso(STR0004, STR0061, {"OK"}) //	"Configurador" # "O botão já encontra-se na última posicao" 		
			EndIf		
		EndIf	
		toolbarList:sort()
	EndIf			
EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³updBtnBrowse ºAutor  ³Michel W. Mosca  º Data ³  06/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o browse de botoes.                                º±±
±±º          ³                                                            º±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ updBtnBrowse(ExpA1, ExpO2, ExpO3)                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = array com lista de registros do Browse.            ³±±
±±³          ³ ExpO2 = MSBrowse                                           ³±±
±±³          ³ ExpO3 = TsToolbarlist                                      ³±±
±±³          ³                                                            ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method updBtnBrowse(aBtns, oBrowse, toolbarList) Class TeleServiceMaintenance
Local nCount //Contador

//Reinicia o array de exibicao no Browse
aBtns := {}   
toolbarList:sort()
For nCount:=1 To Len(toolbarList:aButtons)
	AAdd(aBtns,; 
	{	AllTrim(toolbarList:aButtons[nCount]:name),;     
		AllTrim(toolbarList:aButtons[nCount]:pos),;	
		AllTrim(toolbarList:aButtons[nCount]:imagename),;
		AllTrim(toolbarList:aButtons[nCount]:codeblock),;
		AllTrim(toolbarList:aButtons[nCount]:toolTipText),;
		toolbarList:aButtons[nCount]:id})
Next    

If Len(aBtns) <= 0
	aBtns := {{"","","","","","",}}
EndIf
                            
oBrowse:SetArray(aBtns)
oBrowse:bLine := {||{	aBtns[oBrowse:nAt,01],;
                    	aBtns[oBrowse:nAt,02],;
                    	aBtns[oBrowse:nAt,03],;     
                    	aBtns[oBrowse:nAT,04],;
                    	aBtns[oBrowse:nAT,05]}} 
Return Nil  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³openBrowse   ºAutor  ³Michel W. Mosca  º Data ³  31/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe a tela de escolha do modelo de atendimento.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method openBrowse() Class TeleServiceMaintenance   
Local aCores1    	:= {	{"(.F.)" , "BR_VERMELHO" },;	//  "Pendente"
   						    {"(.T.)" , "BR_VERDE"    }}		//  "Encerrado"
Private cCadastro 	:= STR0062 								//	"Cadastro de modelos de atendimento"
Private aRotina		:= {{ STR0063	,"AxPesqui" ,0,1 },; 	// 	"Pesquisar"
						{ STR0064  	,"TK503Opc" ,0,2 },; 	// 	"Visualizar"
						{ STR0065   ,"TK503Opc" ,0,3 },; 	// 	"Incluir"
					 	{ STR0066  	,"TK503Opc" ,0,4 },;   	//	"Alterar"
					 	{ STR0067  	,"TK503Opc" ,0,5 }} 	// 	"Excluir"

   


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
MBrowse(,,,,"SKA",,,,,,aCores1,,,,)

Return Nil          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³getAFields   ºAutor  ³Michel W. Mosca  º Data ³  05/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Converte o objeto fields em array para o TCBrowse           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                              
Method getAFields(table, oList, aFields) Class TeleServiceMaintenance 

Local aArea 	:= GetArea()
Local lCustomSrc:= Len(GetApoInfo("TMKA500Q.PRW")) > 0
Local nCount

Default aFields := {}		//{'', 'Ordem','Nome', 'Titulo', 'Descrição','Nível','Tipo'}

aFields := {}
For nCount := 1 To Len(table:Fields)
	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek(table:Fields[nCount]:name)
		If lCustomSrc
			aAdd(aFields,{table:Fields[nCount]:Customized, SX3->X3_ORDEM, table:Fields[nCount]:name, Self:getDesc(1), Self:getDesc(2), SX3->X3_NIVEL, SX3->X3_TIPO})		
		Else 
			aAdd(aFields,{.F., SX3->X3_ORDEM, table:Fields[nCount]:name, Self:getDesc(1), Self:getDesc(2), SX3->X3_NIVEL, SX3->X3_TIPO})		
		EndIf
	EndIf	
Next nCount   

If Len(aFields) <= 0
	aAdd(aFields,{.F., "", "", "", "", "", ""})    
EndIf
oList:SetArray(aFields)
oList:bLine := {||{	If(aFields[oList:nAt,01],LoadBitmap(GetResources(),"BR_VERMELHO"), LoadBitmap(GetResources(),"BR_VERDE")),;
                    aFields[oList:nAt,02],;
                    aFields[oList:nAt,03],;     
                    aFields[oList:nAT,04],;
                    aFields[oList:nAT,05],;
                    aFields[oList:nAT,06],;
                    aFields[oList:nAT,07]}}  	
                    
oList:Refresh(.T.)
RestArea(aArea)
Return aFields

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³getDesc      ºAutor  ³Michel W. Mosca  º Data ³  05/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtem o titulo e descricao localizado.                      º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ getDesc(ExpN1)                                             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao (1-Titulo/2-Descricao)                       ³±±
±±³          ³                                                            ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      
Method getDesc(nOption) Class TeleServiceMaintenance   
Local cValue := "" 

If nOption == 1 
	cValue := X3Titulo()
ElseIf nOption == 2
 	cValue := X3Descric()
EndIf

Return cValue              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QuerySX3     ºAutor  ³Michel W. Mosca  º Data ³  08/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta ao Sx3                                             º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QuerySX3(ExpC1,ExpC2)                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = nome da tabela consultada                          ³±±
±±³          ³ ExpC2 = retorno do campo selecionado pelo usuario          ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Method QuerySX3(cTable, cRetVar) Class TeleServiceMaintenance 
Local lRet    := .F.
Local nUsado  := 0
Local nOpcA   := 0
Local nSX3Campo := 0
Local oDlgCons
Local oGetCons   
Local aSx3Fields := {}
Local nAt      


DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cTable)
While !Eof() .And. (SX3->X3_ARQUIVO == cTable)
	aAdd(aSx3Fields, {SX3->X3_CAMPO })
	SX3->(DbSkip())
End

 
Define MsDialog oDlgCons Title OemToAnsi(STR0068) From 000, 000 To 450, 295 /*Of oMainWnd*/ PIXEL //"Consulta de campos"

	Define Font oFont Name 'Courier New' Size 0, -12		
	oGetCons := TCBrowse():New( 030, 005, 145, 195,, {STR0069},{200},; //"Nome do Campo"
	                            oDlgCons,,,,,{||},,oFont,,,,,.T./*lUpdate*/,,.T.,,.T./*lDesign*/,,, )  	

	oGetCons:SetArray(aSx3Fields)
	oGetCons:bLine := {||{	aSx3Fields[oGetCons:nAt,01]}} 	                            
	oGetCons:blDblClick := {||nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End()}

Activate MsDialog oDlgCons Centered ON INIT EnchoiceBar (oDlgCons, {	|| nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End()},	{|| nOpcA := 0, oDlgCons:End()} )

If nOpcA == 1
	cRetVar := aSx3Fields[nAt,01]
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³customizeFieldºAutor  ³Vendas CRM      º Data ³  30/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Customiza a exibicao de um campo                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method customizeField(nType,oBrowse) Class TeleServiceMaintenance

Local lConf		:= .F.
Local aButtons	:= {}
Local lInclui	:= .T.
Local aPos	  	:= {014,001,145,264}
Local nOpc		:= 3
Local oDlg								// Dialog Principal
Local oEnch								// Enchoice
Local cField	:= AllTrim(oBrowse:aArray[oBrowse:nAt][3])
Local oField	:= Nil
Local cId		:= self:service:id
Local nPos		:= 0
Local lCustomSrc:= Len(GetApoInfo("TMKA500Q.PRW")) > 0
Local aCpsADQ	:={}

If  lCustomSrc

	DbSelectArea("ADQ")
	DbSetOrder(1)
	If Dbseek(xFilial("ADQ") + cID + cField)
		lInclui := .F.
	Else
		lInclui := .T.
	EndIf

    //Se for alteração nos campos dos itens e se forem padrões do sistema, não permite tira-los de uso.
	If nType == 2 .And. Tk503X3Propri(cField) <> "U"
		aCpsADQ := {"ADQ_TITPOR","ADQ_TITSPA","ADQ_TITENG","ADQ_INIPAD","ADQ_OBRIGA"}
	Else
		aCpsADQ := {"ADQ_TITPOR","ADQ_TITSPA","ADQ_TITENG","ADQ_INIPAD","ADQ_OBRIGA","ADQ_USADO"}
	EndIf

	DEFINE MSDIALOG oDlg TITLE STR0101 FROM 0,0 TO 300,526 PIXEL //"Editar campo"
	
	// Cria RegToMemory das Enchoices
	// INCLUI = True  --> Traz Enchoice vazia pronta para Inclusao
	// INCLUI = False --> Traz Enchoice com o Registro definido pela variavel nReg
	RegToMemory("ADQ", lInclui, .F.)
	oEnch := MsMGet():New("ADQ",/*nReg*/,nOpc,,,,aCpsADQ,aPos,,,,,,oDlg,,.T.,.T.,NIL,.F.)
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||lConf:=.T.,oDlg:End()},{||oDlg:End()},,aButtons)
	
	If lConf
	
		If nType == 1 //Cabecalho
			nPos := aScan(self:service:tableStructureInfo:master:Fields,{|o| AllTrim(o:name)==AllTrim(cField) })
			oField := self:service:tableStructureInfo:master:Fields[nPos]
		Else
			nPos := aScan(self:service:tableStructureInfo:detail:Fields,{|o| AllTrim(o:name)==AllTrim(cField) })
			oField := self:service:tableStructureInfo:detail:Fields[nPos]
		EndIf
	
		oField:titleSpa	 	:= M->ADQ_TITSPA
		oField:titleEng		:= M->ADQ_TITENG
		oField:titlePor 	:= M->ADQ_TITPOR
		oField:defValue 	:= M->ADQ_INIPAD
		oField:use 			:= M->ADQ_USADO
		oField:required 	:= M->ADQ_OBRIGA
		oField:Customized	:= .T.
	
		If nType == 1
			self:service:tableStructureInfo:master:oPersist:save(oField,cId)
		Else
			self:service:tableStructureInfo:detail:oPersist:save(oField,cId)
		EndIf
		
		oBrowse:aArray[oBrowse:nAt][1] := .T.
		oBrowse:Refresh()
		
	EndIf
	
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³restoreField  ºAutor  ³Vendas CRM      º Data ³  30/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Restaura dados da exibicao original do campo                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method restoreField(nType,oBrowse) Class TeleServiceMaintenance

Local lConf		:= .F.
Local cField	:= AllTrim(oBrowse:aArray[oBrowse:nAt][3])
Local oField	:= Nil
Local cId		:= self:service:id
Local nPos		:= 0           
Local lCustomSrc:= Len(GetApoInfo("TMKA500Q.PRW")) > 0

If lCustomSrc
	
	DbSelectArea("ADQ")
	DbSetOrder(1)

	If Dbseek(xFilial("ADQ") + cID + cField)
		
		lConf := MsgYesNo(STR0102,STR0071) //"Confirma a restauração dos dados deste campo?"###"Atenção"
		
		If lConf
		
			If nType == 1 //Cabecalho
				nPos := aScan(self:service:tableStructureInfo:master:Fields,{|o| AllTrim(o:name)==AllTrim(cField) })
				oField := self:service:tableStructureInfo:master:Fields[nPos]
				self:service:tableStructureInfo:master:oPersist:delete(oField,cId)
			Else //Item
				nPos := aScan(self:service:tableStructureInfo:detail:Fields,{|o| AllTrim(o:name)==AllTrim(cField) })
				oField := self:service:tableStructureInfo:detail:Fields[nPos] 
				self:service:tableStructureInfo:detail:oPersist:delete(oField,cId)
			EndIf
	
			oBrowse:aArray[oBrowse:nAt][1] := .F.
			oBrowse:Refresh()
			
		EndIf

	EndIf

EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA503B     ºAutor  ³Michel W. Mosca  º Data ³  31/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe a tela do configurador.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKA503B()    
Static oObj := TeleServiceMaintenance():New()

oObj:openBrowse()
Return .T.   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CFGX503B     ºAutor  ³Michel W. Mosca  º Data ³  12/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe a tela do configurador a partir do SigaCfg.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CFGX503B()    
Return TMKA503B()   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK503Add     ºAutor  ³Michel W. Mosca  º Data ³  31/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe a tela para configurar um novo modelo de atendimento  º±±
±±º          ³conforme a opcao selecionada.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK503Opc(cAlias,	nReg,	nOpc,	aEnchoice)   


If nOpc == 2
	oObj:lReadOnly := .T.	
	oObj:service := TeleServicing():New() 
	oObj:service:load(SKA->KA_CODIGO)   
	oObj:showDialog(STR0064)	//"Visualizar"
ElseIf nOpc == 3
	oObj:lReadOnly := .F.                 
	oObj:service := TeleServicing():New() 
	If oObj:showDialog(STR0065) //"Incluir"
		oObj:service:save()	
	EndIf
ElseIf nOpc == 4	     
	oObj:lReadOnly := .F. 
	oObj:service := TeleServicing():New() 
	oObj:service:load(SKA->KA_CODIGO)   
	If oObj:showDialog(STR0066)	//"Alterar"
		oObj:service:save()
	EndIf 
ElseIf nOpc == 5	     
	oObj:lReadOnly := .T.                 
	oObj:service := TeleServicing():New() 
	oObj:service:load(SKA->KA_CODIGO)   
	If oObj:showDialog(STR0067) //"Excluir"
		If MsgYesNo(STR0070 + AllTrim(oObj:service:name) + "'?", STR0071)	//"Deseja realmente excluir o modelo de atendimento '" # "Atenção"
			oObj:service:delete()
		EndIf
	EndIf	
EndIf
Return .T.                                         


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³_TMKA500      ºAutor  ³Michel W. Mosca º Data ³  09/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao dummy apenas para o programa aparecer no inspetor de º±±
±±º          ³objetos                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                   
FUNCTION _TMKA503B()
RETURN NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |Tk503X3Propri	³ Autor ³ Vendas Clientes   ³ Data ³ 12/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o campo X3_PROPRI                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ X3_PROPRI                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk503X3Propri(cField)

Local aArea := GetArea()
Local cRet	:= ""

DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek(cField)
	cRet := SX3->X3_PROPRI
EndIf                

RestArea(aArea)

Return cRet
