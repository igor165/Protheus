#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA870.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#define Confirma 1
#define Redigita 2
#define Abandona 3

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Gpea870  ³ Autor ³ Abel Ribeiro          ³ Data ³  09.02.09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao do Certificado de Ingressos e Retencao (DIAN)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS / FNC     ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alex Fagunde ³05/01/11³00000029757/2010³Atender a Nova Interface MP 11.5 utilizan-³±±
±±³             ³        ³                ³do a funcao MsAdvSize( p/ flexibilidade da³±±
±±³             ³        ³                ³tela de acordo com a resolucao).          ³±±
±±³Ademar Jr.   ³08/08/11³00000020223/2011³-COL-Ajustes para gravar o RGO. Melhoria  ³±±
±±³	            ³        ³Chamado TDMMLG  ³     da funcao gp870Grv().                ³±±
±±³Alfredo Med. ³27/11/13³Prj.:COL11.8_RH ³-MEX-Permite alteraciones al campo 		 ³±±
±±³             ³        ³Req.:239713		³ RCS_ORIGEM, Toma como referencia de NIT  ³±±
±±³             ³        ³               	³ el campo RA_RG en vez de RA_CIC 			 ³±± 
±±³Alfredo Med. ³07/09/16³PDR_SER_MI002-56³ Merge 12.1.3                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gpea870(nOpcAuto)

LOCAL cFiltraSRA			//Variavel para filtro
LOCAL aIndexSRA    := {}		//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

PRIVATE aRotina    :=  MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Private cANO       := 0

cCadastro := OeMtoAnsi(STR0001) //"Manutençäo do Certificado de Ingressos e Retenção"

//cCadastro	:= OeMtoAnsi(STR0001)  +STR0011 +cAno //""Manutençäo do Certificado de Ingressos e Retenção"#" - Ano Calendario "

If !Pergunte("GPA870",.T.)
	Return
EndIf

cAno 		:= Strzero(MV_PAR01,4)

If nOpcAuto <> Nil
	Do Case
		Case nOpcAuto == 3
			INCLUI := .T.
			ALTERA := .F.
		Case nOpcAuto == 4
			INCLUI := .F.
			ALTERA := .T.
		OtherWise	
			INCLUI := .F.
			ALTERA := .F.
	EndCase		

	dbSelectArea('SRA')
	nPos := Ascan(aRotina,{|x| x[4]== nOpcAuto})
	If ( nPos <> 0 )
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPos,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nPos)
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Arquivo Esta Vazio                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !ChkVazio("SRA")
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltraRh := CHKRH("GPEA870","SRA","1")
	bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
	Eval(bFiltraBrw)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("SRA")
	mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor() )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndFilBrw("SRA",aIndexSra)
	//--Retornar Set Epoch Padrao
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp870Atu  ³ Autor ³ Abel Ribeiro          ³ Data ³ 09.02.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de (Vis.,Inc.,Alt. e Del.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gp870Atu(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±                                   
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA870                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function gp870Atu(cAlias,nReg,nOpcx)

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local nSavRec   	:= RecNo()
Local nCnt			:= 0
Local oDlg
Local oFont
Local oGroup

Local aNoFields  := {"RGO_FILIAL","RGO_NIF","RGO_ANO","RGO_ALI_WT","RGO_REC_WT"}
Local aYesFields := {"RGO_TIPREN","RGO_NOMREN","RGO_LOCREN","RGO_VLRREN","RGO_VLRRET"}
Local bSeekWhile := {|| Alltrim(RGO->RGO_FILIAL + RGO->RGO_ANO + RGO->RGO_MAT + RGO->RGO_NIF) }
Local Nrgoord	 := RetOrdem( "RGO", "RB_FILIAL+RGO->RGO_ANO + RGO->RGO_MAT + RGO->RGO_NIF + RGO->RGO_TIPREN" )
Local nPosRec	 := 0

Private aColsComp 	:= {}
Private aHeaderComp	:= {}
Private aColsRec := {}   //--Array que contem o Recno() dos registros da aCols

Private nUsado   := 0
Private cAliasRgo:= "RGO"
PRIVATE cMAT   	 := SRA->RA_MAT
PRIVATE cNome  	 := SRA->RA_NOME 
PRIVATE cNIF   	 := SRA->RA_RG  //           SRA->RA_CIC             

//cAno 		:= Strzero(MV_PAR01,4)
cCOD        := Alltrim(cFilial + cANO + cMAT + cNIF)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 015 , 020 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

While .T.

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe algum dado no arquivo                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( cAliasRGO )
	dbSetOrder(1)
	dbSeek( cCod )
	nCnt := 0
   	While !(cAliasRGO)->(Eof()) .And. Alltrim(RGO_FILIAL + RGO_ANO + RGO_MAT + RGO_NIF) == Alltrim(CCod) 
		nCnt++
		(cAliasRGO)->(DbSkip())
    EndDo
  
    IF (nCnt = 0 .and. nOPCx == 2) .or. (nCnt = 0 .and. nOPCx == 5) .or. (nCnt = 0 .and. nOPCx == 4)
		Aviso(OemToAnsi(STR0010), OemToAnsi(STR0015), {"Ok"})            	            //"Atencao"###"Não Há valores lançados para este Funcionário"	        
		Exit             
    Elseif nCnt = 0 
		nOpcx := 3
    Elseif nCnt > 0 .and. nOpcx == 3
		cMensagem := STR0014 +chr(13) + CHR(10) + SRA->RA_MAT +" - "+ space(02)+SRA->RA_NOME   //"Já Existe Lançamentos para este Funcionário,utilize a opção Alterar"
		Aviso(STR0007,cMensagem,{"OK"})
		Exit
    Elseif nCnt > 0 
		dbSeek( cCod )
    Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Gerar o array aCols com os dependentes E Monta o cabecalho   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//-FillGetDados( nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, uSeekFor, aNoFields, aYesFields, lOnlyYes, cQuery, bMontCols, lEmpty, aHeaderAux, aColsAux, bAfterCols, bBeforeCols, bAfterHeader, cAliasQry, bCriaVar, lUserFields, aYesUsado )
	FillGetDados(nOpcx					,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
				 cAliasRGO				,; //2-cAlias - area a ser utilizada;
				 nRGOOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				 cCod	                ,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
				 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
				 aNoFields		   	    ,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
				 aYesFields				,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
				 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
				 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
				 NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
				 IIF(nOpcx==3,.t.,.f.)  ,; //12-Caso inclusao inclua um registro em branco no acols	
				 NIL			      	,; //13-aHeaderAux
				 NIL			      	,; //14-aColsAux
				 NIL			     	)  //15-bAfterCols
	
	nOpca := 0         
	
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
    DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
    
    @ aObjSize[1,1] , aObjSize[1,2] GROUP oGroup TO ( aObjSize[1,3] - 3 ),( ( aObjSize[1,4]/100*10 - 2 ) ) LABEL OemToAnsi(STR0007) OF oDlg PIXEL				// "Matricula:"
	oGroup:oFont:= oFont 
	@ aObjSize[1,1] , ( ( aObjSize[1,4]/100*10 ) ) GROUP oGroup TO ( aObjSize[1,3] - 3 ),( aObjSize[1,4]/100*80 - 2 ) LABEL OemToAnsi(STR0008) OF oDlg PIXEL	// "Nome:"
	oGroup:oFont:= oFont 
	@ aObjSize[1,1] , ( aObjSize[1,4]/100*80 ) GROUP oGroup TO ( aObjSize[1,3] - 3 ),aObjSize[1,4] LABEL OemToAnsi(STR0009) OF oDlg PIXEL						// "NIF:"
	oGroup:oFont:= oFont 

	@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] ) - aObjSize[1,2] ) / 2 ) + 15 ) , ( aObjSize[1,2] + 5 )				SAY cMat 	                SIZE 050,10 OF oDlg PIXEL FONT oFont
	@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] ) - aObjSize[1,2] ) / 2 ) + 15 ) , ( ( aObjSize[1,4]/100*10 ) + 5 )	SAY OemToAnsi(cNOME) 		SIZE 146,10 OF oDlg PIXEL FONT oFont
	@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] ) - aObjSize[1,2] ) / 2 ) + 15 ) , ( ( aObjSize[1,4]/100*80 ) + 5 )	SAY cNIF  	                SIZE 050,10 OF oDlg PIXEL FONT oFont

	                           
	oGet	:= MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpcx,"Xgp870LinOk","Xgp870TudOk"," ",If(nOpcx=2.Or.nOpcx=5,Nil,.T.),,1)
	
   	bSet15	:= {|| nOpca:=If(nOpcx=5,2,1),If(oGet:TudoOk(),oDlg:End(),nOpca:=0)}
   	bSet24	:= {|| oDlg:End()}

   	aButton := {{"NOTE",{|| gpm870Compl(nOPCx,cANO,cMAT,cNIF)},STR0022}}//Informacoes Complementares
    
    ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButton ) CENTERED 

   	
    aColsAnt := Aclone(aCols)

    //--Se nao for Exclusao
    If nOpcx # 5
        IF nOpcA == Redigita
            LOOP
        ELSEIF nOpcA == Confirma .And. nOpcx # 2
            Begin Transaction
                //--Gravacao Arquivo Principal
                gp870Grv(cAliasRGO,aColsAnt)
                
                //--Processa Gatilhos
                EvalTrigger()
                
               	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	            //³Grava informacoes complementares³
	            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	            m870GravInf(cANO,cMAT,cNIF)	
                
            End Transaction
        Endif
    //--Se for Exclusao
    Elseif nOpca = 2 .And. nOpcx = 5
        Begin Transaction
            gp870Dele( cAlias , nReg , nOpc )

        End Transaction
    Endif

	Exit
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da janela                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
carq1 := "SRA"
dbSelectArea(cArq1)
Go nSavRec

If nOpcx == 3    //--Quando Inclusao
   MBrChgLoop(.F.)
EndIf
   
Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp870Dele ³ Autor ³ Abel Ribeiro          ³ Data ³ 09.02.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Deleta os Registro de                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp870Dele                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp870Dele( cAlias , nReg , nOpc )
cAlias := "RGO"
dbSelectArea(cALIAS)
dbSetOrder(1)                  // RGO_FILIAL+RGO_ANO+RGO_MAT+RGO_NIF              
IF dbSeek(SRA->RA_FILIAL+cANO+SRA->RA_MAT+SRA->RA_RG) // SRA->RA_CIC

    cMensagem := STR0019 +chr(13) + CHR(10) + SRA->RA_MAT +" - "+ space(02)+SRA->RA_NOME    

	IF Aviso(STR0010,cMensagem,{STR0020,STR0021}) == 1 // ###"ATENCAO"###"Deseja Excluir Informação do Certificado deste funcionário: "###"Sim"###"Nao"
	   Do While RGO->(!Eof()) .And. RGO->RGO_MAT == SRA->RA_MAT
		  RecLock(cALIAS,.F.)
		  DbDelete()
		  RGO->(MsUnlock())     
		  RGO->(DbSkip())
	   EndDO

	   cAlias := "RCS"
	   dbSelectArea(cALIAS)
       dbSetOrder(4)                 
       //Exclui as Informações Complementares
	   dbSeek(SRA->RA_FILIAL+cANO+SRA->RA_MAT+SRA->RA_RG) //SRA->RA_CIC
       Do While RCS->(!Eof()) .And. RCS->RCS_MAT == SRA->RA_MAT
		     RecLock(cALIAS,.F.)
		     DbDelete()
		     RCS->(MsUnlock())     
		     RCS->(DbSkip())
	      EndDO
    Endif
ELSE
    cMensagem := STR0015 + chr(13) + CHR(10) + SRA->RA_MAT + space(02)+SRA->RA_NOME// "Não foram geradas informações para o funcionário: "
	Aviso(STR0007,cMensagem,{"OK"})
Endif
                                                                                            
Return Nil



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³                   ROTINAS DE CRITICA DE CAMPOS                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp870Grava³ Autor ³ Abel Ribeiro          ³ Data ³ 09.02.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava registro no arquivo RGO                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp870Grava                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function gp870Grv(cAliasRGO,aColsAnt)
Local nX 		:= 0
Local aAreaRGO 	:= RGO->( GetArea() )
Local lAlt      := .F.
Local nLenCols	:= Len(aColsAnt)
Local nUsado    := Len(aHeader)
Local nTpRen    := aScan(aHeader,{|x| AllTrim(x[2])=="RGO_TIPREN" })
Local nLocRen   := aScan(aHeader,{|x| AllTrim(x[2])=="RGO_LOCREN" })
Local nVlREND	:= aScan(aHeader,{|x| AllTrim(x[2])=="RGO_VLRREN" })
Local nVlRET	:= aScan(aHeader,{|x| AllTrim(x[2])=="RGO_VLRRET" })

Local nTan :=  TamSx3("RGO_NIF")[1] //Len(RGO->RGO_NIF)

cNIF := SubStr((cNIF+Space(nTan)),1,nTan)

For nX := 1 To nLenCols
	IF !( aColsAnt[nX,nUsado+1] )       //Se não Foi Deletado 
			dbSelectArea("RGO")
	    dbSetOrder(1)   
	    If dbSeek(xFilial("RGO")+cANO+cMAT+cNIF+aColsAnt[nX,1])
	       (cAliasRGO)->( RecLock(cAliasRGO,.F.,.T.) )
	       lAlt := .T.
	    Else     
	       (cAliasRGO)->( RecLock(cAliasRGO,.T.) )
	       (cAliasRGO)->RGO_FILIAL	:= XFILIAL("RGO")
		   (cAliasRgo)->RGO_MAT	    := cMat
		   (cAliasRGO)->RGO_NIF	    := cNIF
		   (cAliasRGO)->RGO_ANO     := cANO
    	   (cAliasRGO)->RGO_TIPREN 	:= aColsAnt[nX,nTPREN]
		Endif

		(cAliasRGO)->RGO_LOCREN 	:= aColsAnt[nX,nLocRen]
		(cAliasRGO)->RGO_VLRREN 	:= aColsAnt[nX,nVLREND]
		(cAliasRGO)->RGO_VLRRET 	:= aColsAnt[nX,nVLRET]

		//Se for alteração Grava o Codigo do Usuário
		IF lAlt 
		   (cAliasRGO)->RGO_USER 	    := __cUSERID
		ENDIF
		   
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Destrava o Registro										   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		( cAliasRGO )->( MsUnLock() )
	Else  //Se FOi Deletado , Trata o Registro
	    dbSelectArea("RGO")
	    dbSetOrder(1)   
	    If dbSeek(xFilial("RGO")+cANO+cMAT+cNIF+aColsAnt[nX,1])
	       (cAliasRGO)->( RecLock(cAliasRGO,.F.,.T.) )
	       (cAliasRGO)->(dbDelete())
 	       (cAliasRGO)->( MsUnLock() )
 	    Endif   
	EndIF
Next nX

RestArea( aAreaRGO )
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp870LinOk³ Autor ³ Abel Ribeiro          ³ Data ³ 09.02.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Xgp870LinOk()
Local lRet 	   := .T.                                                                                                                            
Local nPosVLREN:= GdFieldPos("RGO_VLRREN")
Local nPosVLRET:= GdFieldPos("RGO_VLRRET")
Local nLocRen  := GdFieldPos("RGO_LOCREN")
Local nPosTip  := GdFieldPos("RGO_TIPREN")
Local cTIPREN  := GDFIELDGET("RGO_TIPREN",n)

nPosAcols := aScan(aCols,{|x| x[nPosTip]  == cTIPREN  } )

If aCols[n,Len(acols[n])]  = .F.
   IF  (nPosAcols > 0) .And. (nPosAcols <> n)
       Aviso(STR0012,STR0018 + AllTrim(Str(nPosAcols)),{STR0013})     //"Inconsistencia"###"Tipo de Rendimento Já Digitado - linha "##"OK"
       lRet := .F.
   ELSEIF EMPTY(aCols[n, nLocRen])       
          Aviso(STR0012,STR0017,{STR0013})                            //"Inconsistencia"###"Informe o Local onde se praticou a Retencao"##"OK"
          lRet := .F.
   ELSEIF (aCols[n, nPosTip]) $ "A /B /C /D /E /F /G /H "
          IF aCols[n, nPosVlRet] > 0.00
             Aviso(STR0012,STR0028,{STR0013})                         //"Inconsistencia"###"Para este tipo de Rendimento, não deve ser informado valor Retido"##"OK"
            lRet := .F.             
          Endif  
   ENDIF                               
   
Endif
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³xgp870TudOk³ Autor ³ Abel Ribeiro         ³ Data ³ 09.02.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Xgp870TudOk()
Local lRetorna  := .T.
Continua := .F.
Return lRetorna

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³gpm870ComplºAutor  ³Microsiga          º Data ³  10/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza dados referentes as informacoes  complementares   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function gpm870Compl(nOpcx,cAno,cMat,cNIF)

Local nOpcA		:=	0 
Local cChave 	:= xFilial("RGO")+cANO+cMAT+cNIF
Local aAlter	:= {}  
Local nx		:= 1
Local lDeletados:= .F.
Local lInclui 	:= .T.
Local cUsado	:= ""      
Local nOpcNewGd	:= If( ( nOpcX ==2 .or. nOpcX ==6 ),0,( GD_INSERT + GD_UPDATE + GD_DELETE ) )

Local a870Field	:= {"RCS_FILIAL","RCS_MAT","RCS_CPFBEN","RCS_ANO"}
Local nCampos	:= 0
Local naCols	:= 0                                                 
Local aAltera	:= {"RCS_TIPORE","RCS_DESCRI","RCS_VALOR","RCS_NOME","RCS_ORIGEM"}
// Getdados
Local aColsAnt 	:=	aClone( aCols )
Local aHeaderAnt:=  aClone( aHeader)

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

aCols		:= {}
aHeader	:= {}
nUsado		:= 0
                                                        
DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do AHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
SX3->(DbSeek("RCS"))
While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO == "RCS")
	IF X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .and. ASCAN(a870Field,Trim(SX3->X3_CAMPO)) == 0
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), ;
						SX3->x3_campo	, ;	
						SX3->x3_picture , ;
						SX3->x3_tamanho , ;
						SX3->x3_decimal , ;
						SX3->x3_valid   , ;
						SX3->x3_usado   , ;
						SX3->x3_tipo	, ;
						SX3->x3_F3 			} )                                       
	Endif
	SX3->(DbSkip())
EndDo


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do ACols                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols 	:= {}
naCols 	:= nUsado+1

If nOpcx <> 3

	If nOpcx == 4 // Alteracao
		For nX := 1 to Len(aColsComp )
			aadd(aCols,aColsComp[nx])

			If aColscomp[nX,naCols]
				lDeletados := .T.	     
			EndIF	
		Next
		aColsComp := {}
		If len(aCols) == 0 .and. lDeletados 
			lInclui := .F.
		EndIf	
	Endif

	If len(aCols) == 0	 .and. lInclui  
		aColsRec:= {}  
		nCnt 	:= 0
		dbSelectArea("RCS")
		dbSetOrder(4)
		dBSeek(cChave)
		While RCS->(!Eof()) .And. xFilial("RGO")+cANO+cMat+cNIF == ;
				RCS->RCS_FILIAL+RCS->RCS_ANO+RCS->RCS_MAT+RCS->RCS_CPFBEN
	
			aaDD( aCols, Array(naCols) )
			nCnt++
			nUsado := 0
			SX3->(DbSeek("RCS"))
			While SX3->(!Eof()) .And. SX3->x3_arquivo == "RCS"
				If X3USO(SX3->x3_usado) .AND. cNivel >= SX3->x3_nivel .and. ASCAN(a870Field,Trim(SX3->x3_campo)) == 0
					nUsado++
					aCOLS[nCnt][nUsado] := &("RCS->"+SX3->X3_CAMPO)
				Endif			
				SX3->(DbSkip())
			EndDo  
			
			aCOLS[nCnt][nUsado+1] := .F.
			
			Aadd(aColsRec,("RCS")->(Recno()))
			
			RCS->(	DbSkip())
		EndDo	
        //aCols[1][GdFieldPos("RCS_TIPORE")] := '01'					//-- Inicia Ordem com 1

	EndIF	

ElseIf nOpcx == 3 //Inclusao
    aColsRec := {}
   	aCols := aClone( aColsComp)
 
EndIF

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	aAdvSize		:= MsAdvSize()
	aAdvSize[5]		:= (aAdvSize[5]/100) * 80	//horizontal
	aAdvSize[6]		:= (aAdvSize[6]/100) * 75	//Vertical
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 015 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aAdd( aObjCoords , { 000 , 030 , .T. , .F. } )	// Navegacao
	aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )
	aGdCoord		:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*65), (((aObjSize[1,4])/100)*75) }	//1,3 Vertical /1,4 Horizontal

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0022) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	@ aObjSize[1,1]+10 , aObjSize[1,2]+2 GROUP oGroup TO ( aObjSize[1,3] +5 ),( ( aObjSize[1,4]/100*80 - 2 ) ) OF oDlg PIXEL                                     //15,05 TO 30,480 
	IF  nOpcx == 3
		@ aObjSize[1,1]+15 , aObjSize[1,2]+20 SAY cMat + " - " + cNOME SIZE 200,7 PIXEL FONT oFont COLOR CLR_HBLUE //20,20	
	Else

		@ aObjSize[1,1]+15 , aObjSize[1,2]+20 SAY cMAT + " - " + cNOME SIZE 200,7 PIXEL FONT oFont COLOR CLR_HBLUE		//20,20	
    EndIF

	oGet1 := MsNewGetDados():New(60,05,(aObjSize[2,3]/100)*70,(aObjSize[2,4]/100)*70,nOpcNewGd,"GP870LOK","GP870LOK","+RCS_TIPORE",aAltera,0,8,NIL,NIL,,@oDlg,@aHeader,@aCols) //140,480


ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,If( oGet1:TudoOk() ,oDlg:End(),nOpca :=0)},{|| nOpca := 2,oDlg:End()}) CENTERED

	If nOpca == 1
	If nOpcx # 1	// Se nao for visualizacao
		Begin Transaction
			aColsComp  := aClone(oGet1:aCols)
			aHeaderComp:= aClone(oGet1:aHeader)
		End Transaction
	EndIf
EndIf

aCols	 := aClone( aColsAnt)
aHeader := aClone( aHeaderAnt )

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GP870LOK  ºAutor  ³Abel Ribeiro        º Data ³  11/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a linha da msGetdados                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA870                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION GP870LOK()
Local lRet 		:= .T.

If  (aCols[n,len(aHeader)+1] == .F.) .and. (empty(aCols[n,1]) ) 
	Aviso(STR0012,STR0023,{"Ok"}) //"Inconsistencia"##"Informe a coluna 'Nome/Descr.'"
	Return( .F. )
EndIf	

lRet := aComplOk()

RETURN( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³aComplOK  ºAutor  ³Microsiga           º Data ³  11/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP       	                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function aComplOk()
Local nLin 		:= 0
Local nUsado	:= Len(AHEADER)
Local cChave	:= ""
Local nPosTpRe	:= GdFieldPos( "RCS_TIPORE", aHeader)
Local nPosValor	:= GdFieldPos( "RCS_VALOR", aHeader)
Local nPosDescr	:= GdFieldPos( "RCS_DESCRI", aHeader)

If aCols[n,nUsado+1]  == .T.
	Return( .T. )
Endif

cChave := aCols[n,nPosTpRe] 

Begin  Sequence
	For nLin := 1 To Len(aCols)
		If aCols[nLin,nUsado+1]  == .T.
			Loop
		Endif

	    If nLin # n
		    If  aCols[nLin,nPosTpRe] == cChave
		    	Aviso(STR0012,STR0024,{"Ok"}) //"Inconsitência"###"Nro. Item já informado "
		    	Return( .F. )
	    	EndIf
	    EndIf	
	    If  aCols[nLin,nPosValor] == 0.00
		   	Aviso(STR0012,STR0025,{"Ok"}) //"Inconsitência"###"Informe o valor do Bem "
		   	Return( .F. )
	    EndIf
	    
	    If  EMPTY(aCols[nLin,nPosDescr])
		   	Aviso(STR0012,STR0026,{"Ok"}) //"Inconsitência"###"Informe a Descrição do Bem "
		   	Return( .F. )
	    EndIf

	Next nLin
End Sequence	
Return( .T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³m870GravInf ºAutor  ³Abel Ribeiro       º Data ³ 11/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a gravacao no arquivo de informacoes complementares     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA870                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                     
Function m870GravInf(cAno,cMat,cNIF)
Local nX 		:= 1
Local nT 		:= 1		                   
Local nPosTpRe  := GdFieldPos("RCS_TIPORE",aHeaderComp)
Local cTipoRe	:= ""
Local nOrdem    := 0  
Local cAlias    := "RCS"

For nX := 1 to len(aColsComp)       
	If !empty(aColsComp[nx][01])
		
			
		//--Verifica se Nao esta Deletado no aCols
		If nx <= Len(aColsRec)               		// Altera Linha existente
			RCS->(dbGoto(aColsRec[nx]))
			
			RecLock("RCS",.F.)

			cTipoRe := aColsComp[nx][nPosTpRe] //RCS->RCS_TIPORE

			//--Verifica se esta deletado
			If aColsComp[nx][Len(aColsComp[nx])] 
				RCS->(dbDelete())
				MsUnlock()		   
				Loop    
			EndIf
		Else                                  		// Nova Linha da GetDados
			If aColsComp[nx][Len(aColsComp[nx])] 
		       loop
		    EndIf   
		
			cTipoRe := aColsComp[nx][nPosTpRe]
		   	dbSelectArea(cALIAS)
            dbSetOrder(4)                 

	        IF !dbSeek(SRA->RA_FILIAL+cANO+cMAT+cNIF+cTipoRe)

			   RecLock("RCS",.T.)
	   
			   RCS->RCS_FILIAL		:= xFilial("RGO")
			   RCS->RCS_MAT 		:= cMAT
			   RCS->RCS_CPFBEN		:= cNIF
			   RCS->RCS_ANO		    := cAno 
			   RCS->RCS_TIPORE      := cTipoRe 
			  
			ENDIF    
		EndIf
		nORDEM++
		For nt := 1 To Len(aHeaderComp)
			cCampo		:= Trim(aHeaderComp[nt][2])
		    IF cCampo == "RCS_TIPORE"
			   xConteudo	:= Strzero(nOrdem ,2)					//-- Faz o Reordenacao da ordem  dos campos nos casos em  que haja delecao de algum  regitro na GetDados
            Else
			   xConteudo 	:= aColsComp[nx][nt]
			Endif   
			&cCampo := xConteudo
		Next nt                     

		MsUnlock()
	EndIf	
Next      
aColsComp 	:= {}
aHeaderComp := {}
Return

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³01/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA870                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/        

Static Function MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         1
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
Local  aRotina := { {	STR0002	 , 'PesqBrw' 	, 0 , 1 , ,.F.}	,;  //'Pesquisar' 
					{	STR0003  , "Gp870atu"	, 0 , 2  } ,;  	    //"Visualizar"
					{   STR0004  , "gp870ATu"   , 0 , 3  } ,;       //"Incluir" 
					{   STR0005  , "gp870ATu"   , 0 , 4  } ,;       //"Alterar" 
					{	STR0006  , "Gp870Dele"	, 0 , 5  } }   	    //"Excluir"
Return aRotina