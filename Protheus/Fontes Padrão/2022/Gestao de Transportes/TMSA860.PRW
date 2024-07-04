#INCLUDE "tmsa860.ch"
#include "Protheus.ch"
#include "DBTREE.CH"

Static lTMA010His := ExistBlock("TMA010HIS")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA860  ³ Autor ³ Patricia Antar Salomao³ Data ³ 30.12.04   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclusao de Tabelas de Frete                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSA860()

Local aPosObj    := {} 
Local aObjects   := {}                        
Local aSize      := MsAdvSize( .F. )             

Local aCombo     := {STR0001,STR0002} //"Sim"###"Nao"
Local cCombo     := ""
Local nCombo                                             
Local oCombo
Local oDlg                     

Local cTabela    := CriaVar("DT0_TABFRE",.F.)
Local cTipo      := CriaVar("DT0_TIPTAB",.F.)
Local cCdrOri    := CriaVar("DT0_CDRORI",.F.)
Local cCdrDes    := CriaVar("DT0_CDRDES",.F.)
Local cCodPro    := CriaVar("DT0_CODPRO",.F.) 
Local lTMALogGrv := ExistBlock("TMALOGGRV")
Local nOpca	 	  := 0
Local aButtons   := {}
Local oSize		:= FwDefSize():New( .T. )

Private cCadastro := STR0003 //"Exclusao de Tabelas de Frete"
Private aSetKey   := {}
Private aTabFre   := {}
Private aOrigem   := {}
Private aDestino  := {}
Private cSqlOri   := ''
Private cSqlDes   := ''
Private cAliasTop := ''
Private oTree                      

Aadd(aSetKey, { VK_F4 , { || TmsA860Leg() } } )                     

//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

AAdd( aButtons, {"PLNPROP", {||TmsA860Leg()},STR0015 , STR0016 }) //"Legenda da categoria do grupo de regioes - <F4>"

Inclui  := .T.

aRotina := {	{STR0004, "AxPesqui", 0, 1 },;	//"Pesquisar"
					{ STR0005, "AxVisual", 0, 2 },;	//"Visualizar"
					{ STR0006, "AxInclui", 0, 3 },;	//"Incluir"
					{ STR0007, "AxAltera", 0, 4 },;	//"Alterar"
					{ STR0008, "AxExclui", 0, 5 }} 	//"Excluir"

oSize:lLateral:= .F.  // Calculo vertical

// adiciona Enchoice
oSize:AddObject( "ENCHOICE", 100, 10, .T., .T. ) // Adiciona enchoice

// adiciona grid
oSize:AddObject( "Tree",100, 90, .T., .T. ) // Adiciona Grid

// Dispara o calculo
oSize:Process()

DEFINE MSDIALOG oDlg TITLE cCadastro From	oSize:aWindSize[1],oSize:aWindSize[2] TO ;
												oSize:aWindSize[3],oSize:aWindSize[4] Of oDlg PIXEL 
  
	@ oSize:GetDimension("ENCHOICE","LININI")   ,oSize:GetDimension("ENCHOICE","COLINI") SAY RetTitle("DT0_TABFRE") SIZE 50,7 OF oDlg PIXEL
	@ oSize:GetDimension("ENCHOICE","LININI")   ,oSize:GetDimension("ENCHOICE","COLINI")+37 MsGet cTabela VALID ExistCpo("DT0",cTabela+AllTrim(cTipo),1) PICTURE "@!" F3 "DTL" SIZE 32,7 OF oDlg PIXEL   			
	@ oSize:GetDimension("ENCHOICE","LININI")   ,oSize:GetDimension("ENCHOICE","COLINI")+70 SAY RetTitle("DT0_TIPTAB") SIZE 30,7 OF oDlg PIXEL
	@ oSize:GetDimension("ENCHOICE","LININI")   ,oSize:GetDimension("ENCHOICE","COLINI")+85 MsGet cTipo VALID ExistCpo("DT0",cTabela+cTipo,1) PICTURE "@!" SIZE 20,7 OF oDlg PIXEL
	@ oSize:GetDimension("ENCHOICE","LININI")+18,oSize:GetDimension("ENCHOICE","COLINI") SAY RetTitle("DT0_REGORI") SIZE 50,7 OF oDlg PIXEL
	@ oSize:GetDimension("ENCHOICE","LININI")+18,oSize:GetDimension("ENCHOICE","COLINI")+37 MsGet cCdrOri VALID (Vazio(cCdrOri) .Or. ExistCpo("DUY",cCdrOri)) .And. TMS860Clear(aOrigem) PICTURE "@!" F3 "DUY" SIZE 37,7 OF oDlg PIXEL			
	@ oSize:GetDimension("ENCHOICE","LININI")+18,oSize:GetDimension("ENCHOICE","COLINI")+85 MsGet Posicione("DUY",1,xFilial("DUY")+cCdrOri,"DUY_DESCRI") When .F. SIZE 090,7 OF oDlg PIXEL			
	@ oSize:GetDimension("ENCHOICE","LININI")+18,oSize:GetDimension("ENCHOICE","COLINI")+180 SAY RetTitle("DT0_REGDES") SIZE 50,7 OF oDlg PIXEL
	@ oSize:GetDimension("ENCHOICE","LININI")+18,oSize:GetDimension("ENCHOICE","COLINI")+213 MsGet cCdrDes VALID (Vazio(cCdrDes) .Or. ExistCpo("DUY",cCdrDes)) .And. TMS860Clear(aDestino) PICTURE "@!" F3 "DUY" SIZE 32,7 OF oDlg PIXEL			
	@ oSize:GetDimension("ENCHOICE","LININI")+18,oSize:GetDimension("ENCHOICE","COLINI")+247 MsGet Posicione("DUY",1,xFilial("DUY")+cCdrDes,"DUY_DESCRI")  When .F. SIZE 090,7 OF oDlg PIXEL
	@ oSize:GetDimension("ENCHOICE","LININI")+30,oSize:GetDimension("ENCHOICE","COLINI") SAY RetTitle("DT0_CODPRO") SIZE 50,7 OF oDlg PIXEL	
	@ oSize:GetDimension("ENCHOICE","LININI")+30,oSize:GetDimension("ENCHOICE","COLINI")+37 MsGet cCodPro VALID Vazio(cCodPro) .Or. ExistCpo("SB1",cCodPro) PICTURE "@!" F3 "SB1" SIZE 37,7 OF oDlg PIXEL
	@ oSize:GetDimension("ENCHOICE","LININI")+30,oSize:GetDimension("ENCHOICE","COLINI")+85 MsGet Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_DESC")  When .F. SIZE 090,7 OF oDlg PIXEL							
	@ oSize:GetDimension("ENCHOICE","LININI")+42,oSize:GetDimension("ENCHOICE","COLINI") SAY STR0009 SIZE 50,7 OF oDlg PIXEL 
	@ oSize:GetDimension("ENCHOICE","LININI")+42,oSize:GetDimension("ENCHOICE","COLINI")+37 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo VALID TMS860Clear(aOrigem) .And. TMS860Clear(aDestino) SIZE 32 ,7 OF oDlg PIXEL

    Eval(oCombo:bChange := {|| nCombo := oCombo:nAt})

	oTree:= dbTree():New(oSize:GetDimension("ENCHOICE","LININI")+60, oSize:GetDimension("Tree","COLINI"), oSize:GetDimension("Tree","LINEND"),oSize:GetDimension("Tree","COLEND"),oDlg,,,.T.)                 
	
	oTree:LShowHint := .F.                                                              
   
	DEFINE SBUTTON oBtn  FROM oSize:GetDimension("ENCHOICE","LININI")+42,87 TYPE 15 ACTION ( TMSA860Qry(cTabela,cTipo,cCdrOri,cCdrDes,cCodPro,nCombo, .T.) ) ENABLE OF oDlg PIXEL
	                                                               		
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, If(TMSA860Ok(cTabela,cTipo),oDlg:End(),nOpcA := 0)},{||oDlg:End()},, aButtons )        			
	
If ( nOpcA == 1 ) 
	Processa({ || TMSA860Exc(cTabela,cTipo,cCdrOri,cCdrDes,cCodPro,nCombo) })
	If lTMALogGrv
		//-- Ponto de entrada comum entre todas as rotinas que manipulam tabela de frete e ajustes.
		//-- O ponto tem o objetivo de possibilitar a criacao de um LOG informando o  usuario  e  a
		//-- operação que foi realizada em uma tabela de frete ou ajuste de cliente.
		ExecBlock("TMALOGGRV",.F.,.F.,{ "DT0", "5",cUserName, 0 })
	EndIf				
EndIf

MsUnlockAll()
	
dbSelectArea("DT0")
dbSetOrder(1)

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA860Qry ³ Autor ³Patricia Antar Salomao³ Data ³ 30.12.04   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa a Query para delecao e Mostra Tree contendo as Tabelas³±±
±±³          ³a serem excluidas                                             ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA860Qry()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tabela                                               ³±±
±±³          ³ ExpC2 - Tipo da Tabela                                       ³±±
±±³          ³ ExpC3 - Regiao Origem                                        ³±±
±±³          ³ ExpC4 - Regiao Destino                                       ³±±
±±³          ³ ExpC5 - Produto                                              ³±± 
±±³          ³ ExpC6 - Variantes ? Sim / Nao                                ³±±
±±³          ³ ExpL1 - Monta e Mostra Tree na Tela ? Sim / Nao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA860                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function TMSA860Qry(cTabela,cTipo,cCdrOri,cCdrDes,cCodPro,nCombo,lVisTree)

Local nCount   := 0
Local cQuery   := ''
Local cArqTRB  := CriaTrab(NIL,.F.)
Local cDesc    := ''

Default lVisTree := .T. 

aTabFre  := {}
cSqlOri  := ''
cSqlDes  := ''

If !Tmsa860Ok(cTabela,cTipo)
	Return .F.
EndIf
                                     
//-- Se Variantes igual a 'Sim', pesquisa todas as regioes que estao abaixo da regiao Origem informada 
If Empty(aOrigem)
	If nCombo == 1 .And. !Empty(cCdrOri) 
		Aadd(aOrigem,{cCdrOri})		
		TmsNivInf(cCdrOri,aOrigem,,.T.)    
	ElseIf !Empty(cCdrOri)
		Aadd(aOrigem,{cCdrOri})		
	EndIf	
EndIf	                 

//-- Se Variantes igual a 'Sim', pesquisa todas as regioes que estao abaixo da regiao Destino informada 	
If Empty(aDestino)
	If nCombo == 1 .And. !Empty(cCdrDes)
		Aadd(aDestino,{cCdrDes})			
		TmsNivInf(cCdrDes,aDestino,,.T.)    
	ElseIf !Empty(cCdrDes)
		Aadd(aDestino,{cCdrDes})			
	EndIf	
EndIf	

If Len(aOrigem) > 0
	For nCount := 1 To Len(aOrigem)
	   cSqlOri += "'" + aOrigem[nCount][1] + "',"
	Next
	cSqlOri := Substr(cSqlOri,1,Len(cSqlOri) - 1)	
EndIf	

If Len(aDestino) > 0 
	For nCount := 1 To Len(aDestino)
	   cSqlDes += "'" + aDestino[nCount][1] + "',"
	Next
	cSqlDes := Substr(cSqlDes,1,Len(cSqlDes) - 1)
EndIf	
                
cAliasTop := GetNextAlias() 
cQuery := "SELECT DT0_FILIAL, DT0_TABFRE, DT0_TIPTAB, DT0_CDRORI, DT0_CDRDES, DT0_CODPRO, R_E_C_N_O_ NRECNO FROM " + RetSqlName( "DT0" ) 
cQuery += " WHERE "
cQuery += "DT0_FILIAL = '" + xFilial( "DT0" ) + "' AND "
cQuery += "DT0_TABFRE = '" + cTabela  + "' AND "							
cQuery += "DT0_TIPTAB = '" + cTipo    + "'"				
If Empty(cSqlOri)
	cQuery += " AND DT0_CDRORI BETWEEN '"+Space(Len(DT0->DT0_CDRORI)) +"'AND'"+Replicate("Z",Len(DT0->DT0_CDRORI))+"'"
EndIf
If Empty(cSqlDes)
	cQuery += " AND DT0_CDRDES BETWEEN '"+Space(Len(DT0->DT0_CDRDES)) +"'AND'"+Replicate("Z",Len(DT0->DT0_CDRDES))+"'"
EndIf
If ! Empty(cCodPro)
	cQuery += " AND DT0_CODPRO = '" + cCodPro + "'"
Endif	      		                                 	
cQuery += " AND D_E_L_E_T_ = ' '"     
		
cQuery += " ORDER BY DT0_FILIAL,DT0_CDRORI, DT0_CDRDES"
cQuery := ChangeQuery( cQuery )   

dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasTop, .F., .T. ) 
                                       
(cAliasTop)->(dbGoTop())
        
//-- So' executa a funcao TMSA860Monta(), se for mostrar o Tree na Tela
If lVisTree           
	MsgRun(STR0012 + cTabela + '/' +cTipo,,{|| xRet := TMA860Monta(lVisTree)  })  //"Aguarde, verificando a estrutura da Tabela de Frete : "
EndIf	

Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMA860Monta ³ Autor ³Patricia Antar Salomao³ Data ³03.01.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o tree                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA860Monta()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Visualiza o Tree na Tela ?                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMA860Monta(lVisTree)                            

Local cTexto   := ''
Local cCargo	:= ''
Local cSeek    := ''
Local cSeek1   :=     ''
Local cCatTab  :=  Posicione('DTL',1,xFilial('DTL')+(cAliasTop)->DT0_TABFRE+(cAliasTop)->DT0_TIPTAB,"DTL_CATTAB")
Local cFolderA := 'FOLDER5'
Local cFolderB := 'FOLDER6'
Local lSeek    := .F.
Local lContHis := GetMv("MV_CONTHIS",.F.,.T.) //-- Controla Historico da Tabela de Frete              
Local lAux     := .T.
                    
cTexto   := PadR(STR0014+(cAliasTop)->DT0_TABFRE + '/'+(cAliasTop)->DT0_TIPTAB, 150) //'Tabela de Frete : '

If lVisTree //-- Mostra Tree na Tela           
	oTree:BeginUpdate()
	oTree:Reset()  
	oTree:AddTree(Padr(cTexto, 150),.T.,,,'FOLDER5','FOLDER6',Padr('0MA-MAINGR', 40))						
EndIf
	
While !(cAliasTop)->(Eof())
	
	If !(cAliasTop)->DT0_CDRORI $ cSqlOri
		(cAliasTop)->(dbSkip())
		Loop
	EndIf
	
	If !(cAliasTop)->DT0_CDRDES $ cSqlDes
		(cAliasTop)->(dbSkip())
		Loop
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controla Historico de Tabela            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	//-- O Objetivo deste Ponto de Entrada, e' validar se sera' permitido Alterar/Excluir (independente
	//-- do conteudo do parametro MV_CONTHIS).
	If lTMA010His
		lAux := ExecBlock("TMA010HIS",.F.,.F.,{5,(cAliasTop)->DT0_TABFRE,(cAliasTop)->DT0_TIPTAB})
		If ValType(lAux) <> "L"
			lAux :=.T.
		EndIf   
		lContHis := lAux
	EndIf   
   If lContHis    
      //-- Verifica se a tabela de frete esta em uso por um CTRC, AWB ou cotacao de frete nao cancelada.
		If	TmsTabUso((cAliasTop)->DT0_TABFRE,(cAliasTop)->DT0_TIPTAB,(cAliasTop)->DT0_CDRORI,(cAliasTop)->DT0_CDRDES,.F.,cCatTab)
			(cAliasTop)->(dbSkip()) 		   
			Loop
		EndIf
	EndIf                  	
	If lVisTree 
	   cCargo   := "01" + (cAliasTop)->DT0_CDRORI 
		//-- Define a cor da Pasta da Regiao Origem 
		TMSA860Cor((cAliasTop)->DT0_CDRORI,@cFolderA, @cFolderB )				
		//-- Descricao da pasta
		cDesc:= Pad((cAliasTop)->DT0_CDRORI + '-' + Capital( DUY->DUY_DESCRI ), 150 )
		//-- Adiciona a Regiao Origem no Tree 
		oTree:AddTree(cDesc,.T.,,,cFolderA,cFolderB,cCargo)			     
		cSeek:= xFilial('DT0')+(cAliasTop)->DT0_CDRORI
	   While  !(cAliasTop)->(Eof()) .And. (cAliasTop)->DT0_FILIAL+(cAliasTop)->DT0_CDRORI == cSeek

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Controla Historico de Tabela            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		   If lContHis    
		      //-- Verifica se a tabela de frete esta em uso por um CTRC, AWB ou cotacao de frete nao cancelada.
				If	TmsTabUso((cAliasTop)->DT0_TABFRE,(cAliasTop)->DT0_TIPTAB,(cAliasTop)->DT0_CDRORI,(cAliasTop)->DT0_CDRDES,.F.,cCatTab)
					(cAliasTop)->(dbSkip()) 		   
					Loop
				EndIf
			EndIf
			   
	   	cCargo  := "02"+(cAliasTop)->DT0_CDRORI+(cAliasTop)->DT0_CDRDES 
			//-- Define a cor da Pasta da Regiao Destino
			TMSA860Cor((cAliasTop)->DT0_CDRDES,@cFolderA, @cFolderB )					   			
			//-- Descricao da pasta.
			cDesc:= Pad( (cAliasTop)->DT0_CDRDES + '-' + Capital( DUY->DUY_DESCRI ), 150 )				
			//-- Adiciona a Regiao Destino no Tree 	
			oTree:AddTree(cDesc,.T.,,,cFolderA,cFolderB,cCargo)			
			cSeek1:= xFilial('DT0')+(cAliasTop)->DT0_CDRORI+(cAliasTop)->DT0_CDRDES
		   While !(cAliasTop)->(Eof()) .And. (cAliasTop)->DT0_FILIAL+(cAliasTop)->DT0_CDRORI+(cAliasTop)->DT0_CDRDES == cSeek1
				lSeek := .T.
				If !Empty((cAliasTop)->DT0_CODPRO)        
					cCargo := '03' + (cAliasTop)->DT0_CDRORI+(cAliasTop)->DT0_CDRDES+(cAliasTop)->DT0_CODPRO						
				   //-- Descricao da Pasta
					cDesc := Posicione("SB1",1,xFilial("SB1")+ (cAliasTop)->DT0_CODPRO,"B1_DESC")
					//-- Adiciona os Produtos da Regiao Destino no Tree 					
					oTree:AddTreeItem(cDesc,'FOLDER5','FOLDER6',cCargo)
				EndIf
			   (cAliasTop)->(dbSkip())                                                                                             	   					
		   EndDo           
			oTree:EndTree()					   
		   If !lSeek
			   (cAliasTop)->(dbSkip())                                                                                             	   
		   EndIf 
		EndDo          
		oTree:EndTree()			               						
	Else
	   (cAliasTop)->(dbSkip())                                                                                             	   		
	EndIf	
EndDo

If Empty(cSqlOri) .Or. Empty(cSqlDes)
	Help( " ", 1, "TMSA86003" ) //--"Região de Origem ou de Destino devem ser preenchidas !!"
EndIf 

If lVisTree //-- Mostra Tree na Tela           
	oTree:EndUpdate()    
	dbEndtree oTree
EndIf

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA860Ok ³ Autor ³Patricia Antar Salomao ³ Data ³ 30.12.04   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao geral da Tela                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA860Ok()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Tabela de Frete                                      ³±±
±±³          ³ ExpC2 : Tipo da Tabela de Frete                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA860                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Tmsa860Ok(cTabela,cTipo)

Local lRet := .T.

If Empty(cTabela) .Or. Empty(cTipo)
	Help(" ",1,"OBRIGAT") //Um ou alguns campos obrigatorios nao foram preenchidos.xxxxxxxxxxxxxxxxxx -> xxxxxxxxxx Pasta
	Return (.F.)
Endif	

Return(lRet)                                    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA860Exc   ³ Autor ³Patricia Antar Salomao  ³ Data ³ 30/12/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a delecao                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA860Exc()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Tabela                                                    ³±±
±±³          ³ExpC2 - Tipo da Tabela                                            ³±±
±±³          ³ExpC3 - Codigo do Produto                                         ³±±
±±³          ³ExpC4 - Combo Variantes                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA860                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSA860Exc(cTabela,cTipo,cCdrOri,cCdrDes,cCodPro,nCombo)

Local aArea      := GetArea()
Local cCatTab    := ""
Local lContHis   := GetMv("MV_CONTHIS",.F.,.T.) //-- Controla Historico da Tabela de Frete

TMSA860Qry(cTabela,cTipo,cCdrOri,cCdrDes,cCodPro,nCombo, .F.)
cCatTab := Posicione('DTL',1,xFilial('DTL')+(cAliasTop)->DT0_TABFRE+(cAliasTop)->DT0_TIPTAB,"DTL_CATTAB")

Begin Transaction
	(cAliasTop)-> ( dbGoTop() )	
	While (cAliasTop)-> ( !Eof() )

		If !(cAliasTop)->DT0_CDRORI $ cSqlOri
			(cAliasTop)->(dbSkip())
			Loop
		EndIf
	
		If !(cAliasTop)->DT0_CDRDES $ cSqlDes
			(cAliasTop)->(dbSkip())
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controla Historico de Tabela            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		//-- O Objetivo deste Ponto de Entrada, e' validar se sera' permitido Alterar/Excluir (independente
		//-- do conteudo do parametro MV_CONTHIS).
		If lTMA010His
			lAux := ExecBlock("TMA010HIS",.F.,.F.,{5,(cAliasTop)->DT0_TABFRE,(cAliasTop)->DT0_TIPTAB})
			If ValType(lAux) <> "L"
				lAux :=.T.
			EndIf   
			lContHis := lAux
		EndIf   
	   If lContHis    
	      //-- Verifica se a tabela de frete esta em uso por um CTRC, AWB ou cotacao de frete nao cancelada.
			If	TmsTabUso((cAliasTop)->DT0_TABFRE,(cAliasTop)->DT0_TIPTAB,(cAliasTop)->DT0_CDRORI,(cAliasTop)->DT0_CDRDES,.F.,cCatTab)
				(cAliasTop)->(dbSkip()) 		   
				Loop
			EndIf
		EndIf
		
		DBSelectArea("DVC")
		DVC->(DbSetOrder(1)) //-- DVC_FILAL+DVC_TABFRE+DVC_TIPTAB+DVC_CDRORI+DVC_CDRDES+DVC_CODCLI+DVC_LOJCLI+DVC_SEQTAB+DVC_CODPRO+DVC_SERVIC
		If MsSeek(xFilial("DVC")+cTabela+cTipo)
			Help( " ", 1, "TMSA86001" ) //--Existem ajustes da tabela de frete relacionados a esse registro.Favor excluir o(s) ajuste(es) da tabela de frete.
			Exit			
		EndIf
		
		DBSelectArea("DUX")
		DUX->(DbSetOrder(3))
		If MsSeek(xFilial("DUX")+cTabela+cTipo)
			Help( " ", 1, "TMSA86002" ) //--Existem contratos de cliente relacionados a esse registro.Favor excluir o contrato do cliente
			Exit			
		EndIf
		                  	
		If TmsA860Del( 'DT0', cTabela, cTipo, (cAliasTop)->DT0_CODPRO,(cAliasTop)->DT0_CDRORI,(cAliasTop)->DT0_CDRDES )
			TmsA860Del( 'DT1', cTabela, cTipo, (cAliasTop)->DT0_CODPRO,(cAliasTop)->DT0_CDRORI,(cAliasTop)->DT0_CDRDES )
			TmsA860Del( 'DTK', cTabela, cTipo, (cAliasTop)->DT0_CODPRO,(cAliasTop)->DT0_CDRORI,(cAliasTop)->DT0_CDRDES )
			TmsA860Del( 'DW1', cTabela, cTipo, (cAliasTop)->DT0_CODPRO,(cAliasTop)->DT0_CDRORI,(cAliasTop)->DT0_CDRDES )

			// Calculo Excedente por sub-faixa
			// Exclusao do excedente por subfaixa
			If FindFunction("ALIASINDIC") .And. AliasInDic("DY1")
				TmsA860Del( 'DY1', cTabela, cTipo, (cAliasTop)->DT0_CODPRO,(cAliasTop)->DT0_CDRORI,(cAliasTop)->DT0_CDRDES )
			Endif	
		EndIf
		(cAliasTop)-> ( DbSkip() )
	EndDo	                       
	(cAliasTop)->(dbCloseArea())
	RestArea(aArea)
End Transaction

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa860Del ³ Autor ³Patricia Antar Salomao³ Data ³03/01/2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exclui as Tabelas (TOP)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TmsA860Del()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Alias (DT0/DT1/DTK)                                   ³±±
±±³          ³ExpC2 - Tabela de Frete                                       ³±±
±±³          ³ExpC3 - Tipo da tabela                                        ³±± 
±±³          ³ExpC4 - Produto                                               ³±±
±±³          ³ExpC5 - Regiao Origem                                         ³±± 
±±³          ³ExpC6 - Regiao Destino                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA860                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA860Del( cAlias, cTabela, cTipo, cCodPro,cCdrOri,cCdrDes)
Local cQuery
Local lRet     := .T.

cQuery := "UPDATE " + RetSqlName( cAlias ) + " SET D_E_L_E_T_ = '*' "
cQuery += ", R_E_C_D_E_L_ = R_E_C_N_O_ "
cQuery += " WHERE " + cAlias + "_FILIAL = '" + xFilial( cAlias )+ "'"
cQuery += "   AND " + cAlias + "_TABFRE = '" + cTabela + "'"
cQuery += "   AND " + cAlias + "_TIPTAB = '" + cTipo   + "'"
cQuery += "   AND " + cAlias + "_CDRORI = '" + cCdrOri + "'"
cQuery += "   AND " + cAlias + "_CDRDES = '" + cCdrDes + "'"
If !Empty(cCodPro)
	cQuery += "   AND " + cAlias + "_CODPRO = '" + cCodPro + "'"
EndIf	
cQuery += "   AND D_E_L_E_T_ = ' '"
If TCSqlExec( cQuery ) <> 0
	lRet := .F.
EndIf

Return lRet
          
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA860Leg ³ Autor ³Patricia Antar Salomao³ Data ³ 03/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Legenda da Categoria do Grupo de Regioes                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA860Leg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA860                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA860Leg()

Local cCadOld := cCadastro

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

TmsA120Leg()
                 
cCadastro := cCadOld

//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA860Cor ³ Autor ³Patricia Antar Salomao³ Data ³ 03/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica qual sera a cor das Pastas no Tree                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA860Cor()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo da Regiao Origem / Destino                  ³±±
±±³          ³ ExpC2 - Cor da Pasta Aberta                                ³±±
±±³          ³ ExpC3 - Cor da Pasta Fechada                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA860                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA860Cor(cCodReg, cFolderA, cFolderB)
          
Default cCodReg  := ''
Default cFolderA := 'FOLDER5'          
Default cFolderB := 'FOLDER6'

DUY->(dbSetOrder(1))
DUY->( MsSeek( xFilial('DUY') + cCodReg ) )

//-- Base para Taxa
If	DUY->DUY_CATREG == StrZero(2,Len(DUY->DUY_CATREG))
	cFolderA := 'FOLDER7'
	cFolderB := 'FOLDER8'
Else
	//-- Estado
	If	DUY->DUY_CATGRP == StrZero(1,Len(DUY->DUY_CATGRP))
		cFolderA := 'FOLDER10'
		cFolderB := 'FOLDER11'
	//-- Filial
	ElseIf DUY->DUY_CATGRP == StrZero(2,Len(DUY->DUY_CATGRP))
		cFolderA := 'FOLDER12'
		cFolderB := 'FOLDER13'
	//-- Regiao
	ElseIf DUY->DUY_CATGRP == StrZero(3,Len(DUY->DUY_CATGRP))
		cFolderA := 'FOLDER5'
		cFolderB := 'FOLDER6'
	EndIf
EndIf
                                               
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tms860Clear³ Autor ³Patricia Antar Salomao³ Data ³ 12/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Limpa o Vetor aOrigem / aDestino                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tms860Clear()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA860                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMS860Clear(aArray)
aArray:= {}
Return .T.
