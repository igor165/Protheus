#INCLUDE "AVGDM400.ch" 
#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FONT.CH"
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2

/*
Traduções e Abreviações dos campos usados no Demurrage
ACSJ - 22 de Janeiro de 2004
   

*--------------------------------------------------------------------------*
|Booking Note Dated:     | Booking Note (Contrato)| B/N Dated of:          |
|                        |datado de:              |                        |
|------------------------+------------------------+------------------------|
|Vsl. Arvd on Roads:     | Navio Chegou na Barra: | Vsl Arvd Rds           |
|------------------------+------------------------+------------------------|
|Vessel Berthed:         | Navio Atracado         | Vsl Bthed              |
|------------------------+------------------------+------------------------|
|Notice Tendered:        | Aviso de Prontidão     | NOR Tndred             |
|                        |Apresentado             |                        |
|------------------------+------------------------+------------------------|
|Notice Accepted:        | Aviso de Prontidão     | NOR Accpted            |
|                        |Aceito                  |                        |
|------------------------+------------------------+------------------------|
|Time to Count From:     | Tempo Inicia contagem  | Time Cnt From          |
|                        |em                      |                        |
|------------------------+------------------------+------------------------|
|Disch. Commenced:       | Descarga Iniciada em   | Disch. Commenc.        |
|------------------------+------------------------+------------------------|
|Disch. Completed:       | Descarga Concluída em  | Disch. Cmpted          |
|------------------------+------------------------+------------------------|
|Cargo Quantity          | Quantidade de Carga    | Cgo. Qtty.             |
|------------------------+------------------------+------------------------|
|Rate of load/disch.:    | Taxa de Carga/Descarga | Rate L/D               |
|------------------------+------------------------+------------------------|
|Rate of Demurrage:  USD | Taxa de Demurrage      | Dem. Rate USD          |
|                        |(Demora) - USD          |                        |
|------------------------+------------------------+------------------------|
|Rate of Despatch:    USD| Desp. Rate USD         | Desp. Rate USD         |
|------------------------+------------------------+------------------------|
|Time allowed:           | Tempo Permitido        | Time Allowed           |
|------------------------+------------------------+------------------------|
|Time Lost/Saved         | Tempo Perdido/Salvo    | Time Lost/Svd          |
|------------------------+------------------------+------------------------|
|DWT:                    | Peso Total do Navio    | DWT                    |
|------------------------+------------------------+------------------------|
|Charter Party Dated     | Contrato de Afretamento| C/P Dated (Pode ser    |
|                        |Datado de               |usado C/P-B/N Dated e   |
|                        |                        |isto substituia posicao |
|                        |                        |de C/P e B/N, se        |
|                        |                        |estiverem separadas)    |
*------------------------+------------------------+------------------------*

----------------------------------------------------------------------------  */


// *****************************************************************//
// Programador - Alexandre Caetano Sciancalepre Jr
// Data        - 16 de Janeiro de 2004
// Objetivo    - Controle e manutenção de DEMURRAGE                   
// Revisão     - LRL - 25/10/04 a 19/11/04
// Revisão     - LRL - 13/01/05 a 18/01/05
// Revisão     - AAF - 15/02/05 a 22/02/05 - Correção de Problemas encontrados nos testes de qualidade.
//*****************************************************************//
FUNCTION AVGDM400()
// ----------------------------------------------------------------//
LOCAL aSemProc         := {},i 
LOCAL cDespreza		   := "EG2_DEMURR/EG2_REMARK/EG2_CODMEN/"
LOCAL lOK              := .F. //AAF 31/05/04
PRIVATE aYesFields       := {}
PRIVATE aOwnTp         := {} 
PRIVATE cCadastro      := STR0001 //"Demurrage"
PRIVATE lTop           := .f.
PRIVATE dDataAtual     := dDataBase 
PRIVATE cTipoLD        := "2"
PRIVATE aHeader        := {}    // Array de Colunas do MSGETDADOS
// --- Posicao das colunas no aCols
Private aAlter         := {}   //  Array de Colunas editaveis
Private nColRate       := 0, nColFrom := 0, nColTo := 0, nColData := 0, nColDtSem := 0, nColTimeUs := 0
Private nColCodMen     := 0, nColOBS  := 0, nColRemark := 0 , nColTpLD := 0
//-----------------------------
PRIVATE cFilSx5 := xFilial("SX5"), cFilSw6 := xFilial("SW6"), cFilEE6 := xFilial("EE6")
PRIVATE cFilSY9 := xFilial("SY9"), cFilSA2 := xFilial("SA2"), cFilSYF := xFilial('SYF') , cFilSA1 := xFilial("SA1")
PRIVATE cFilSW8 := xFilial("SW8"), cFilEG0 := xFilial("EG0"), cFilEG1 := xFilial("EG1")
PRIVATE cFilEG2 := xFilial("EG2"), cFilSAH := xFilial("SAH"), cFilSW7 := xFilial("SW7")
PRIVATE cFilSY7 := xFilial('SY7'), cFilEEC := xFilial("EEC"), cFilEE9 := xFilial("EE9") ,cFilEE4 := xFilial("EE4")
PRIVATE lCpoViagem     := .f.
PRIVATE oGetTUsed   
PRIVATE oGetTLS           
PRIVATE oGetTAll
PRIVATE oGetRate
PRIVATE oGetTot       
PRIVATE oGetTotL      
PRIVATE oGetTotD      
PRIVATE oGetHD
PRIVATE oSayHD 
PRIVATE oSayRate
PRIVATE oSayTot 
PRIVATE oSayParV 
PRIVATE oSayTotL
PRIVATE oSayTotD
PRIVATE oSayTN, oGetTN //AAF 18/02/05
PRIVATE oCmbOwnTp,oCmbNegTp  //ALCIR - 31-01-05
PRIVATE oGet
PRIVATE cDMF3RET   
PRIVATE lExistDM := if (EG0->( FieldPos( "EG0_DEMURR" ) ) > 0 .AND. EG1->( FieldPos( "EG1_DEMURR" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_NRINVO" ) ) > 0 .AND. EG1->( FieldPos( "EG1_PEDIDO" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_SEQUEN" ) ) > 0 .AND. EG1->( FieldPos( "EG1_COD_I" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_QTDUC" ) ) > 0  .AND. EG1->( FieldPos( "EG1_QTDMT" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_UNMED" ) ) > 0  .AND. EG1->( FieldPos( "EG1_COEF" ) ) > 0 ;
        .AND. EG2->( FieldPos( "EG2_DEMURR" ) ) > 0  ,.T.,.F.) /* LRL 12/11/04 - 
Checa se existem os campos:
EG0_DEMURR
EG1_DEMURR   Codigo do processo de Demurrage 
EG2_DEMURR 
EG1_NRINVO   
EG1_PEDIDO
EG1_SEQUEN
EG1_COD_I
EG1_QTDUC    Quantidade na Unidade original Unidade de Compra
EG1_QTDMT    Quantidade convertida em Tonelada Metro
EG1_UNMED    Unidade de Compra
EG1_COEF     Coeficiente de conversão da Unidade de Compra para Tonelada Metro

caso existão as chaves passaram a ser
De                                                                |Para
------------------------------------------------------------------|----------------------------------------------------------------
1 -EG0_FILIAL+EG0_MODULO+EG0_NAVIO+EG0_VIAGEM+EG0_DEST            |EG0_FILIAL+EG0_MODULO+EG0_DEMURR+EG0_NAVIO+EG0_VIAGEM+EG0_DEST
2 -EG0_FILIAL+EG0_MODULO+EG0_FORNEC+EG0_NAVIO+EG0_VIAGEM+EG0_DEST |EG0_FILIAL+EG0_MODULO+EG0_DEMURR+EG0_FORNEC+EG0_NAVIO+EG0_VIAGEM+EG0_DEST
1 -EG1_FILIAL+EG1_MODULO+EG1_NAVIO+EG1_VIAGEM+EG1_DEST+EG1_EMBARQ |EG1_FILIAL+EG1_MODULO+EG1_DEMURR+EG1_NAVIO+EG1_VIAGEM+EG1_DEST+EG1_EMBARQ+EG1_NRINVO+EG1_PEDIDO+EG1_SEQUEN
2 -EG1_FILIAL+EG1_MODULO+EG1_EMBARQ                               |EG1_FILIAL+EG1_MODULO+EG1_DEMURR+EG1_EMBARQ+EG1_NRINVO+EG1_PEDIDO+EG1_SEQUEN
1 -EG2_FILIAL+EG2_MODULO+EG2_NAVIO+EG2_VIAGEM+EG2_DEST            |EG2_FILIAL+EG2_MODULO+EG2_DEMURR+EG2_NAVIO+EG2_VIAGEM+EG2_DEST

Os campos EG0_DEMURR, EG1_DEMURR ,EG1_NRINVO, EG1_PEDIDO, EG1_SEQUEN ,EG2_DEMURR foram adicionado a chave,
o restante da chave continua igual para garantir compatibilidade com dicionarios anteriores e manter
uma ordem dos registros     

Se essa variavel for .T. o sistema permitira as seguintes Funcionalidades

* - Selecão do Embarques que devem ser amarrados ao processo de Demurrage(Marca/Desmarca)
* - Adicionar embarques ao processo de demurrage (Mesmo que não tenha o mesmo Navio,Viagem,Destino)
* - Permitir selecionar para cada item do(s) embarque(s) item as quantidades 
*/
Private  lExistFret := if  ( EG2->( FieldPos( "EG2_TP_LD" ) ) > 0 .AND. EG0->( FieldPos( "EG0_FRETE"  ) ) > 0 ; 
                       .AND. EG0->( FieldPos( "EG0_BANCO" ) ) > 0 .AND. EG0->( FieldPos( "EG0_NOR"    ) ) > 0 ;
                       .AND. EG0->( FieldPos( "EG0_TCFDT" ) ) > 0 ;
                       .AND. EG0->( FieldPos( "EG0_TCFTM" ) ) > 0 .AND. EG0->( FieldPos( "EG0_NEG_VL" ) ) > 0 ;
                       .AND. EG0->( FieldPos( "EG0_VCT"   ) ) > 0 .AND. EG0->( FieldPos( "EG0_CLIENT" ) ) > 0;
                       .AND. EG0->( FieldPos( "EG0_CLILOJ") ) > 0 .AND. EG0->( FieldPos( "EG0_NEG_TP" ) ) > 0,.T.,.F.) //LRL 12/01/05
Private lLojaFor := EG0->( FieldPos( "EG0_FORLOJ" ) ) > 0                       
Private lMultiFil :=  VerSenha(115) .and. Posicione("SX2",1,"EG0","X2_MODO") == "C" .AND. (nModulo == 17 .and. Posicione("SX2",1,"SW8","X2_MODO") == "E" .Or. nModulo == 29 .and. Posicione("SX2",1,"EE9","X2_MODO") == "E" ) .AND. EG1->( FieldPos( "EG1_FILORI" ) ) > 0 .And. lExistFret .And. lExistDM
Private lExistFilOri := EG1->( FieldPos( "EG1_FILORI" ) ) > 0 
Private aFil := AvgSelectFil(.F.)
Private cCpoCliOff := "EEC_CLIENT" //LRL 06/06/2005 - Cliente  Off-Shore
Private  nTimeNor := 0
Private  cTotLoad := "  :  :  " ,cTotDisp:= "  :  :  "

PRIVATE aRotina := MenuDef()

// Preenche o Array AHEADER para ser usado na MSGETDADOS
// Colunas a serem editadas.
// ACSJ - 20 de Janeiro de 2004
SX3->( DBSetOrder(2) )
DBSelectArea("EG2")
SX3->(DbSeek("EG2_DATA  "))
SX3->( DBSetOrder(1) )
While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == "EG2"
   lOk := .t.
   If SX3->X3_BROWSE == "N" 
      if ALLTRIM(SX3->X3_CAMPO) $ cDespreza
         lOK := .f.
      Endif
   Endif   
   if lOk
      aAdd(aYesFields, AllTrim(SX3->X3_CAMPO))
      //Aadd(aHeader, { SX3->X3_TITULO + iif(ALLTRIM(SX3->X3_CAMPO) == "EG2_RATE","    .",""), ALLTRIM(SX3->X3_CAMPO), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,nil,nil, SX3->X3_TIPO,nil,nil } )
      If ALLTRIM(SX3->X3_CAMPO) == "EG2_CODMEN"  
         //Aadd(aHeader, { STR0005, "OBS", "@!", 30, 0,nil,nil,"C",nil,nil} ) //"Observações"
         
      ElseIf ALLTRIM(SX3->X3_CAMPO) == "EG2_DATA"
          aAdd(aYesFields, "EG2_DIASEM")
         //Aadd(aHeader, { AVSX3("EG2_DIASEM",5), "EG2_DIASEM", AVSX3("EG2_DIASEM",6), AVSX3("EG2_DIASEM",3), AVSX3("EG2_DIASEM",4),nil,nil,"C",nil,nil} )
         SX3->(DbSkip())
      Endif   
   Endif
   SX3->(DbSkip())
EndDo
SX3->(DbSetOrder(2))
// ---------------------------------------------------- //
// Preenche o Array AALTER para ser usado na MSGetDados() 
// ACSJ - 20 de Janeiro de 2004
// Campos que poderao ser alterados 

For i := 1 to Len(aYesFields)
   If aYesFields[i] <> "OBS" .and. aYesFields[i] <> "EG2_DIASEM" .and.;
      aYesFields[i] <> "EG2_TIMEUS"
      Aadd( aAlter, aYesFields[i] )
   Endif
Next                      
/*
For i := 1 to Len(aHeader)
   If aHeader[i,2] <> "OBS" .and. aHeader[i,2] <> "EG2_DIASEM" .and.;
      aHeader[i,2] <> "EG2_TIMEUS"
      Aadd( aAlter, aHeader[i,2] )
   Endif
Next                                
*/
/*
// --- Acha as posicoes das coluna partindo do aHeader.
nColRate     := AScan( aHeader, {|x| x[2] == "EG2_RATE"  } )
nColTo       := AScan( aHeader, {|x| x[2] == "EG2_TO"    } )
nColFrom     := AScan( aHeader, {|x| x[2] == "EG2_FROM"  } )
nColData     := AScan( aHeader, {|x| x[2] == "EG2_DATA"  } )
nColDtSem    := AScan( aHeader, {|x| x[2] == "EG2_DIASEM"} )
nColTimeUs   := AScan( aHeader, {|x| x[2] == "EG2_TIMEUS"} )
nColCodMen   := AScan( aHeader, {|x| x[2] == "EG2_CODMEN"} )
nColRemark   := AScan( aHeader, {|x| x[2] == "EG2_REMARK"} )
nColOBS      := AScan( aHeader, {|x| x[2] == "OBS"} )
If lExistFret                                        
   nColTpLD     := AScan( aHeader, {|x| x[2] == "EG2_TP_LD"} )
EndIF
// ------------------------------------------------------------
*/
lCpoViagem := SX3->( DBSeek("W6_VIAGEM") )   // -- Verifica existencia do campo VIAGEM no W6
   
#IFDEF TOP
   lTop := .t.
#ENDIF

//TRP - 01/02/07 - Campos do WalkThru
AADD(aSemProc,{"TRB_ALI_WT","C",03,0})
AADD(aSemProc,{"TRB_REC_WT","N",10,0})

If nModulo == 17  // Variavel publica que indica o modulo em uso --// 17-IMPORTACAO  // --
   Aadd( aSemProc,{"W8_HAWB",     AVSX3("W8_HAWB",2),    AVSX3("W8_HAWB",3),    AVSX3("W8_HAWB",4)   } )
   Aadd( aSemProc,{"W6_DEST",     AVSX3("W6_DEST",2),    AVSX3("W6_DEST",3),    AVSX3("W6_DEST",4)   } )
   Aadd( aSemProc,{"W8_INVOICE",  AVSX3("W8_INVOICE",2), AVSX3("W8_INVOICE",3), AVSX3("W8_INVOICE",4)} )
   Aadd( aSemProc,{ "W8_COD_I",   AVSX3("W8_COD_I",2),   AVSX3("W8_COD_I",3),   AVSX3("W8_COD_I",4)  } )
   Aadd( aSemProc,{ "W8_QTDEMT",  AVSX3("EG0_PARC_C",2), AVSX3("EG0_PARC_C",3), AVSX3("EG0_PARC_C",4)} )
   Aadd( aSemProc,{ "W8_QTDEUC",  AVSX3("W8_QTDE",2),    AVSX3("W8_QTDE",3),    AVSX3("W8_QTDE",4)   } )
   Aadd( aSemProc,{ "W8_UNID",    AVSX3("W8_UNID",2),    AVSX3("W8_UNID",3),    AVSX3("W8_UNID",4)   } )
   Aadd( aSemProc,{ "W8_PO_NUM",  AVSX3("W8_PO_NUM",2),  AVSX3("W8_PO_NUM",3),  AVSX3("W8_PO_NUM",4) } )
   Aadd( aSemProc,{ "W8_POSICAO", AVSX3("W8_POSICAO",2), AVSX3("W8_POSICAO",3), AVSX3("W8_POSICAO",4)} )  
   
   If lExistDM //LRL 12/11/04
      Aadd( aSemProc,{ "EG1_COEF", AVSX3("EG1_COEF",2), AVSX3("EG1_COEF",3), AVSX3("EG1_COEF",     4)} ) 
      Aadd( aSemProc,{ "MARCA"   , "C",2,0} )   
   EndIF                                    
   IF lMultiFil                                                                                           
      Aadd( aSemProc,{ "FILORI", AVSX3("W8_FILIAL",2), AVSX3("W8_FILIAL",3), AVSX3("W8_FILIAL",4)} )  
   EndIF
   
   FileWork1:=E_CriaTrab("SW8",aSemProc,"WORKPROC") //MCF - 16/02/2016 
   IndRegua("WORKPROC",FileWork1+TEOrdBagExt(),"W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO")                                                               
Elseif nModulo == 29  // 29-EXPORTACAO // --
   Aadd( aSemProc,{"EE9_PREEMB",  AVSX3("EE9_PREEMB",2), AVSX3("EE9_PREEMB",3), AVSX3("EE9_PREEMB",4)} )
   Aadd( aSemProc,{"EE9_DEST",    AVSX3("EEC_DEST",2),   AVSX3("EEC_DEST",3),   AVSX3("EEC_DEST",4)  } )   
   Aadd( aSemProc,{"EE9_NRINVO",  AVSX3("EEC_NRINVO",2), AVSX3("EEC_NRINVO",3), AVSX3("EEC_NRINVO",4)} )
   Aadd( aSemProc,{ "EE9_COD_I",  AVSX3("EE9_COD_I",2),  AVSX3("EE9_COD_I",3),  AVSX3("EE9_COD_I",4) } )   
   Aadd( aSemProc,{ "EE9_QTDEMT", AVSX3("EG0_PARC_C",2), AVSX3("EG0_PARC_C",3), AVSX3("EG0_PARC_C",4)} )
   Aadd( aSemProc,{ "EE9_QTDEUC", AVSX3("EE9_SLDINI",2), AVSX3("EE9_SLDINI",3), AVSX3("EE9_SLDINI",4)} )
   Aadd( aSemProc,{ "EE9_UNIDAD", AVSX3("EE9_UNIDAD",2), AVSX3("EE9_UNIDAD",3), AVSX3("EE9_UNIDAD",4)} )
   Aadd( aSemProc,{ "EE9_PEDIDO", AVSX3("EE9_PEDIDO",2), AVSX3("EE9_PEDIDO",3), AVSX3("EE9_PEDIDO",4)} )   
   Aadd( aSemProc,{ "EE9_SEQUEN", AVSX3("EE9_SEQUEN",2), AVSX3("EE9_SEQUEN",3), AVSX3("EE9_SEQUEN",4)} )  

   If lExistDM //LRL 12/11/04
      Aadd( aSemProc,{ "EG1_COEF", AVSX3("EG1_COEF",2), AVSX3("EG1_COEF",3), AVSX3("EG1_COEF",     4)} )  
      Aadd( aSemProc,{ "MARCA"   ,"C",2,0} )
   EndIF                                                                                     
   IF lMultiFil                                                                                           
      Aadd( aSemProc,{ "FILORI", AVSX3("EE9_FILIAL",2), AVSX3("EE9_FILIAL",3), AVSX3("EE9_FILIAL",4)} )  
   EndIF
   FileWork1:=E_CriaTrab(,aSemProc,"WORKPROC")                                                           
   IndRegua("WORKPROC",FileWork1+TEOrdBagExt(),"EE9_PREEMB+EE9_NRINVO+EE9_PEDIDO+EE9_SEQUEN")                                                               
Endif
   
Aadd( aOwnTp, STR0013) //"1-Demurrage"
Aadd( aOwnTp, STR0014) //"2-Despatch"
Aadd( aOwnTp, STR0015) //"3-No Demurrage/No Despatch"
SW7->(DbSetOrder(4))
SW6->(DBSetOrder(1))   

//MFR 12/08/2021 OSSME-6114
If nModulo == 17
   cFiltro := "EG0_MODULO = 'I'"
Elseif nModulo == 29
   cFiltro := "EG0_MODULO = 'E'"
Endif

MBrowse(10,05,22,78,"EG0",,,,,,,,,,,,,,cFiltro)
 



If Select("WORKPROC") <> 0
   WORKPROC->(dbCloseArea())
   FErase(FileWork1)
EndIf   
If Select("WORK_MEN") <> 0
   WORK_MEN->(DBCloseArea())
Endif               
SX3->(DBSetOrder(1))
SW7->(DBSetOrder(1))
SW8->(DBSetOrder(1))
SY7->(DBSetOrder(1))
SY9->(DBSetOrder(1))

dDataAtual     := dDataBase

Return .t.                                                   

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 26/01/07 - 11:31
*/
Static Function MenuDef()
Local aRotAdic := {}   
Local aRotina :=  {}

aAdd( aRotina, { STR0006 , "AxPesqui",    0, 1 } )    //"Pesquisar"
aAdd( aRotina, { STR0007 , "DM400Manut",  0, 2 } )    //"Visualizar"
aAdd( aRotina, { STR0008 , "DM400Manut",  0, 3 } )  //"Incluir"
aAdd( aRotina, { STR0009 , "DM400Manut",  0, 4 } )  //"Alterar"
aAdd( aRotina, { STR0010 , "DM400Manut",  0, 5 } )   //"Estornar"
aAdd( aRotina, { STR0011 , "DM400Emis" ,  0, 6 } )    //"Impressão"
aAdd( aRotina, { "Debit Note" , "AVGDM151" ,  0, 7 } )    

If EasyEntryPoint("AVGDM400")
   ExecBlock("AVGDM400",.F.,.F.,"MENU")
EndIf

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("ADM400MNU")
	aRotAdic := ExecBlock("ADM400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina


// ---------------------------------------------- //
// ACSJ - 16 de Janeiro de 2004
// Inclusão / Alteração de processos de Demurrage   
FUNCTION DM400MANUT(PcAlias, PnReg, PnOpc)
// ---------------------------------------------- //                               
LOCAL i
LOCAL lPriVez	:= .t.
LOCAL oEnc
LOCAL oFld, oFldCAD, oFldPRO
LOCAL nOpcao        := 0
LOCAL aNomeFolders  := {STR0016,STR0017} //"Cadastrais" - "Processos"
LOCAL aAbrevFolders := {STR0018,STR0019} //"CAD" - "PRO"
//LOCAL bOK	:= {|| iif( If(Str(PnOpc,1,0) $ '3/4',Obrigatorio(aGets,aTela),.T.) .And. DM400TudOk(), (nOpcao := 1, oDlg:End()), nOpcao := 0) }
LOCAL bOK	:= {|| iif( iif(Str(PnOpc,1,0) $ '3/4',Obrigatorio(aGets,aTela) .And. DM400TudOk(),.T.), (nOpcao := 1, oDlg:End()), nOpcao := 0) }
LOCAL bCancel   := {|| nOpcao := 0, oDlg:End() }
LOCAL aPosTelaUp, aPosTelaDown, aPosTelaBase        

//LOCAL bBarras
Local bMArca                       
Local bHide    := {|nTela| If(nTela == 1, oGet:oBrowse:Hide(),;
                              oGet2:oBrowse:Hide()) }                                                  
                                 
Local bShow := {|nTela,o| o := if(nTela == 1,oGet,oGet2):oBrowse,;
                                  o:Show(),o:SetFocus() }                           
                                  
Local bHideAll         := {|| Eval(bHide,1), Eval(bHide,2) }                          
Local cSeekEG1     //LRL 16/11/04

//**AAF 03/02/05 - Verifica se o demurrage foi enviado ao cambio da exportação.
If nModulo == 29 .AND. PnOpc > 3 .AND. lExistDm .AND. lExistFret .AND. DM100VCamb(EG0->EG0_DEMURR,.T.)
   PnOpc := 2
Endif
//**

aGets:={}   // Criado pela função ENCHOICE 
aTela:={}   // Criado pela função ENCHOICE 
PRIVATE lMsgDel        := .f. , oGet2
Private lRefresh       := .t.   // Variavel usada para MSGETDADOS
PRIVATE lDespatch      := .t.
PRIVATE aCols          := {}    // Array com os dados das Colunas editaveis do MSGETDADOS
PRIVATE aButtons       := {}
Private aCampos        := Array(0)
PRIVATE nTot := 0, nTimeAllowed := 0, nRate := 0, nOwnVl := 0, nLostSavD := 0  
PRIVATE nLostSavH := 0, cTimeAllowed := "00:00:00", cTimeUsed := "00:00:00"
PRIVATE cTimeLS := "00:00:00", cOwnTp := "1", cSituacao := Space(50), nParcVal := 0
PRIVATE lInvert,  aCpos, nLin,  oGetPar, oGetParV, nMTAux := 0
PRIVATE cMarca := GetMark() //LRL 16/11/04
PRIVATE aBotoes := {} //*** GFP 01/08/2011 
PRIVATE aBotPRO := Nil //LRL 18/11/04
PRIVATE nPOpc := PnOpc
//LRL 10/11/04 - Para que o titulo possa ser modificado por RdMAke
Private cParcel := STR0131 //"Parcel" 
Private cParcelDem := STR0132 //"Parcel demurrage"
Private cParcelDes := STR0133 // "Parcel despatch"  
Private cTitParc
Private cNeg_TP
nTimeNOR := 0 //THTS - 08/12/2017 - Zera a variavel para ela nao abrir ja preenhida na inclusao
//LRL 12/01/04-------------------------------------------------------------                                                                                      
SetFil() //MultiFilial
If lExistFret .and. (PnOpc = 3)                                          
   //*** GFP 01/08/2011 - Nopado
   //aBotoes:= {{"S4WB005N" /*"S4WB001N"*/,{|| CopyDiario()  },STR0177,STR0177 }} //"Copia Diario"
   aAdd(aBotoes,{"S4WB005N" /*"S4WB001N"*/,{|| CopyDiario()  },STR0177,STR0177 }) //"Copia Diario"
EndIf

//-------------------------------------------------------------LRL 12/01/04
If lExistDm .AND. (PnOpc == 3 .OR. PnOpc == 4) //AAF 21/02/05 - Botão visivel apenas na inclusão e alteração. //LRL 18/11/04                                                              
   aBotPRO:= {{"POSCLI",{|| AddEmbarq()  },STR0134,STR0134}} // "Adicionar Embarque"
   Aadd(aBotoes,{"POSCLI",{|| AddEmbarq()  },STR0134,STR0134})
EndIf 
cTipoLD        := If(nModulo==29,"1","2") //AAF 19/02/05 - Verifica o Modulo. //"2" //LRL 13/01/05
//** AAF 21/02/05
If nModulo == 29 .AND. PnOpc <> 3 .AND. !Empty(EG0->EG0_CLIENT)
   cTipoLD := "2"
Endif
//**
If(EasyEntryPoint("AVGDM400"),ExecBlock("AVGDM400",.F.,.F.,"INICIO_MANUTENCAO"),)

//bBarras := {|| EnchoiceBar(/*oFldCAD*/ oDlg, bOK, bCancel, /*PnOpc*/, aBotoes) }   //*** GFP 02/08/2011 - Nopado

bMarca := {|| Dm400Marca (PnOpc)}

lInvert   := .f.
//cMarca    := ""
aCpos     := {}        
       
cHoraVazia   := "  :  "

DBSelectArea("EG2")
FOR i := 1 TO FCount()
   M->&(FIELDNAME(i)) := CRIAVAR(FIELDNAME(i))
NEXT
//IncaCols() // Inclui uma linha vazia                      
DBSelectArea("EG1") 
// ---------------------------------------------------- //
// Preenche o Array ACPOS para ser usado na MSSelect() 
// ACSJ - 19 de Janeiro de 2004

If lExistDm //LRL 16/11/04
   AADD(aCpos,{"MARCA"     ,,""})
EndIf   
If lMulTiFil                                                                  
   AADD(aCpos,{ {|| WORKPROC->FILORI}          , "" , "Filial" }) //"Processo"
EndIF
If nModulo == 17
   AADD(aCpos,{ {|| WORKPROC->W8_HAWB}          , "" , STR0021 }) //"Processo"
   AADD(aCpos,{ {|| WORKPROC->W6_DEST}          , "" , STR0022 }) //"Dest."
   AADD(aCpos,{ {|| WORKPROC->W8_INVOICE}       , "" , STR0023 }) //"Invoice"
   AADD(aCpos,{ {|| WORKPROC->W8_COD_I}         , "" , STR0024 }) //"Item" 
   AADD(aCpos,{ {|| Transform( WORKPROC->W8_QTDEMT, AVSX3("EG0_PARC_C",6) )}  , "" , STR0025 }) //"Qtde MT"	
   AADD(aCpos,{ {|| Transform( WORKPROC->W8_QTDEUC, AVSX3("W8_QTDE",6) )}     , "" , STR0026 }) //"Qtde UM Compra"
   AADD(aCpos,{ {|| WORKPROC->W8_UNID}          , "" , STR0027 }) //"UM Compra"
   AADD(aCpos,{ {|| WORKPROC->W8_PO_NUM}        , "" , STR0028 }) //"P.O."
   AADD(aCpos,{ {|| WORKPROC->W8_POSICAO}       , "" , STR0029 }) //"Posicao"
Elseif nModulo == 29                                                
   AADD(aCpos,{ {|| WORKPROC->EE9_PREEMB}       , "" , STR0021 }) //"Processo"
   AADD(aCpos,{ {|| WORKPROC->EE9_DEST}         , "" , STR0022 }) //"Dest."
   AADD(aCpos,{ {|| WORKPROC->EE9_NRINVO}       , "" , STR0023 }) //"Invoice"
   AADD(aCpos,{ {|| WORKPROC->EE9_COD_I}        , "" , STR0024 }) //"Item" 
   AADD(aCpos,{ {|| Transform( WORKPROC->EE9_QTDEMT, AVSX3("EG0_PARC_C",6) )}, "" , STR0025 }) //"Qtde MT"	
   AADD(aCpos,{ {|| Transform( WORKPROC->EE9_QTDEUC, AVSX3("EE9_SLDINI",6) )}, "" , STR0172 }) //"Qtde UM Neg."
   AADD(aCpos,{ {|| WORKPROC->EE9_UNIDAD}       , "" , STR0173 }) //"UM Neg."
   AADD(aCpos,{ {|| WORKPROC->EE9_PEDIDO}       , "" , STR0030 }) //"Pedido"
   AADD(aCpos,{ {|| WORKPROC->EE9_SEQUEN}       , "" , STR0031 }) //"Sequencia"
Endif

// ---------------------------------------------------- //
WORKPROC->(avzap() )
if PnOpc == 2 .or. PnOpc == 4 .or. PnOpc == 5  // Visualizar, Alteracao ou Estorno

   M->EG0_PARC_C := 0
   
   DBSelectArea("EG0")
   
   For i := 1 to EG0->( FCount() )
      M->&( FieldName(i) ) := EG0->&( FieldName(i) )
   Next            
   M->EG0_VM_OBS := MSMM( EG0->EG0_OBS, AVSX3("EG0_VM_OBS",3) )
   If lExistFret                                               
      M->EG0_VM_BCO := MSMM( EG0->EG0_BANCO, AVSX3("EG0_VM_BCO",3) )
      cNeg_TP := aOwnTp[Max(Val(M->EG0_NEG_TP),1)]   //Alcir - 31-01-05    
   EndIf
   cOW_TP := aOwnTp[Max(Val(M->EG0_OW_TP),1)]      
   EG1->(DBSetOrder(1))
// SW8->(DBSetOrder(6)) VI 28/04/04
   SW8->(DBSetOrder(1))                                                                           
   EEC->(DBSetOrder(1))
   EE9->(DBSetOrder(2))
// EG1->(DBSeek( cFilEG0 + EG0->EG0_MODULO +EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) )
   EG1->(DBSeek( cFilEG0 + EG0->EG0_MODULO + if(lExistDM,EG0->EG0_DEMURR,"") + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) )  // LRL 12/11/04  
   nMTAux := 0   
// Do While ( cFilEG0 + EG0->EG0_MODULO + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) == ( cFilEG1 + EG1->EG1_MODULO + EG1->EG1_NAVIO + EG1->EG1_VIAGEM + EG1->EG1_DEST ) .and. .not. EG1->( EoF() )
   Do While ( cFilEG0 + EG0->EG0_MODULO + if(lExistDM,EG0->EG0_DEMURR,"")+ EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) == ( cFilEG1 + EG1->EG1_MODULO + if(lExistDM,EG1->EG1_DEMURR,"")+ EG1->EG1_NAVIO + EG1->EG1_VIAGEM + EG1->EG1_DEST ) .and. .not. EG1->( EoF() ) //LRL 12/11/04 vide lExistDM
      If nModulo == 17  // Variavel publica que indica o modulo em uso --// 17-IMPORTACAO  // --      
         SW6->( DBSeek(cFilSW6+AVKey(EG1->EG1_EMBARQ,"W6_HAWB")) )
         If !lExistDm
            If SW8->( DBSeek(cFilSW8+AVKey(EG1->EG1_EMBARQ,"W8_HAWB")) ) 
               Do While ! SW8->(EOF()) .And. cFilSW8 = SW8->W8_FILIAL .And. SW8->W8_HAWB = AVKey(EG1->EG1_EMBARQ,"W8_HAWB")
                  GrvWorkW8('SW6')
                  SW8->(DBSKIP())
               EndDo
            Endif               
         Else
           GrvWorkEG1('IMP')
         EndIf   
      Elseif nModulo == 29  // 29-EXPORTACAO // --      
         If !lExistDm  
            If EE9->( DBSeek(cFilEE9+AVKey(EG1->EG1_EMBARQ,"EE9_PREEMB")) ) 
               EEC->( DBSeek(cFilEEC+AVKey(EG1->EG1_EMBARQ,"EEC_PREEMB")) )
               Do While ! EE9->(EOF()) .And. cFilEE9 = EE9->EE9_FILIAL .And. EE9->EE9_PREEMB = AVKey(EG1->EG1_EMBARQ,"EE9_PREEMB")
                  GrvWorkEE9('EEC')
                  EE9->(DBSKIP())
               EndDo
            Endif               
         Else
           GrvWorkEG1('EXP')
         EndIf      
      Endif   
      EG1->( DBSkip() )
   Enddo
   WORKPROC->(DbGoTop())
   If !lExistDM .AND. PnOpc == 4 .And. M->EG0_PARC_C # Val(Transf(nMTAux,'99999999999999.99999')) //AAF 02/12/04 - Não é verificado quando o dicionário é o novo.
      If MsgYesNo(STR0032+Alltrim(Transf(M->EG0_PARC_C,AVSX3("EG0_PARC_C",6)))+STR0034+; //'Qtde da parcela de ' -' MT'
                  CHR(13)+CHR(10)+STR0033+Alltrim(Transf(nMTAux,AVSX3("EG0_PARC_C",6)))+' MT.'+;
                  CHR(13)+CHR(10)+STR0035)//' Deseja alterar ?'
         M->EG0_PARC_C := nMTAux
      EndIf
   EndIf
   //DM400EG2(.F.)
   //IncaCols()
   M->EG0_PARC_C := nMTAux
   N:=1
   DM400Allowed( M->EG0_CARGO, M->EG0_RAT_LD, M->EG0_RAT_HD, .F. )
   DM400LnOk(.F.,.T.)           
   nTimeNOR := Val(Left(M->EG0_NOR,2))+(Val(SubStr(M->EG0_NOR,4,2))/24)+(Val(Right(M->EG0_NOR,2))/1440) //THTS - 08/12/2017 - Carrega o campo nTimeNOR
Else    // Inclusao                      
   DBSelectArea(PcAlias)
   FOR i := 1 TO FCount()
      M->&(FIELDNAME(i)) := CRIAVAR(FIELDNAME(i))
   NEXT 
   IF lExistFret  // NCF - 14/07/09 - Adicionada verificação da flag para uso do campo neste ponto
      M->EG0_VM_BCO := MSMM( M->EG0_BANCO, AVSX3("EG0_VM_BCO",3) )
   ENDIF
   cOW_TP := STR0013 // "1-Demurrage"
   cNeg_TP:=STR0013 //Alcir - 31-01-05
Endif
aHeader := {}
aCols   := {}

FillGetDados(PnOpc, "EG2", 1, "", {|| "" }, {|| .T. }, /*aNoFields*/, aYesFields, , /*cQuery*/, {|| DM400EG2(.F., PnOpc), IncaCols(PnOpc) }, /*lInclui*/,,,,, {|| SetHeaderPos() } )

if PnOpc == 4 .or. PnOpc == 5  // Alteracao / Exclusao
   If ! RecLock("EG0",.f.)
      Return .F.
   EndIf
EndIf
                       
//JVR - 13/07/09 - Atualização de toda a tela demurrage.
DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

   //Definição de Telas
   aPosTelaUp  := PosDlgUp(oDlg)
   aPosTelaDown:= POsDlgDown(oDlg)
   aPosTelaBase:= PosDLg(oDlg)    

   //Tratamento caso seja MDI.                  
   If(SetMdiChild(),aPosTelaBase[3] -= 20,)

   //Tratamento caso ambiente WEB. 
   cDirClient := GETCLIENTDIR()//retorna o diretorio do client completo.
   If(UPPER(cDirClient)$"CLIENTAX",aPosTelaBase[3] += 20,)//TotvsSmartClientAX; => Active X; => WEB

   //Definição tamanho da tela
   aPosTelaBase[3] -= 61//Desconto Rodape. 
   aPosTelaUp[3]   := aPosTelaBase[3] * 0.6 //60% da tela restante.
   aPosTelaDown[1] := aPosTelaUp[3]
   aPosTelaDown[3] := aPosTelaBase[3]       //40% da tela.

   //Definição de Variaveis que serão utilizadas no Folder e Rodape.
   nLinha := (oDlg:nClientHeight-132)/2  
   nLin   := If(SetMdiChild(),nLinha+3,nLinha-7)
                                           
   //Criação do Folder.
   oFld := TFolder():New(1,1,aNomeFolders,aAbrevFolders,oDlg,,,,.T.,.F.,COLUNA_FINAL,nLinha)
   aEval(oFld:aControls,{|x| x:SetFont(oDlg:oFont) })
   oFldCAD   := oFld:aDialogs[1]
   oFldPRO   := oFld:aDialogs[2]

   //MsMGet
   oEnc := MsMGet():NEw( PcAlias, PnReg, PnOpc,,,,,aPosTelaUp,,,,,,oFldCAD )

   DBSelectArea("EG2")                                                                                           
   //MsGetDados
   oGet := MsGetDados():New(aPosTelaDown[1],aPosTelaDown[2],aPosTelaDown[3],aPosTelaDown[4],PnOpc,"DM400LnOK","","",.f.,aAlter,nil,.f.,1500,"DM400FieldOK",nil,nil,"DM400DELOK",oFld:aDialogs[1])
  
   oGet:oBrowse:Align      := CONTROL_ALIGN_BOTTOM //CONTROL_ALIGN_ALLCLIENT //NCF - 21/09/2017
   oGet:oBROWSE:BADD       := {|| .t. } 
   oGet:oBrowse:BGOTFOCUS  := {|| oGet:oBrowse:Cargo:=1}
   oGet:oBrowse:BLOSTFOCUS := {|| oGet:oBrowse:Cargo:=0}
   oGet:oBrowse:Cargo      :=1
   SetKey(9,{|| Dm400Ins()})   

   If M->EG0_CLASSI = '2'
      cRATE := STR0036 // "Rate of despatch "
      cTotal:= STR0037 // "Total despatch "  
      cTitParc :=  cParcelDes
   ElseIf M->EG0_CLASSI = '1'
      cRATE := STR0038 //"Rate of demurrage "
      cTotal:= STR0039 //"Total demurrage "
      cTitParc :=  cParcelDem
   Else
      cRATE := STR0040  //"Rate no demurrage/no despatch"
      cTotal:= STR0041  //"Total no demurrage/no despatch"
      cTotalL:= STR0154 // "Load"
      cTotalD:= STR0155 //"Disch"
      cTitParc :=  cParcel 
   EndIf
   cTotalL:= STR0156 //"Time Used at load"
   cTotalD:= STR0157 //"Time Used at disch" 

   //**Rodape  
   oFld2 := TFolder():New(150,1,{"Total","Neg. Values"},{"TOT","VAL"},oDlg,,,,.T.,.F.,COLUNA_FINAL,71)
   oFld2:Align:= CONTROL_ALIGN_BOTTOM
   nLin:= 1
   
   //aDialogs[1]*****
   @ nLin,     005 Say oSayRate Prompt cRATE                      Of oFld2:aDialogs[1] Pixel Size 85,6 FONT oDlg:oFont
   @ nLin,     085 MsGet oGetRate     Var nRate                   Of oFld2:aDialogs[1] Pixel Size 090,6  When .f. Picture AVSX3("EG0_DES_V",6) HASBUTTON
   @ (nLin+12),005 Say oSayTot  Prompt cTotal                     Of oFld2:aDialogs[1] Pixel Size 85,6 FONT oDlg:oFont         
   @ (nLin+12),085 MsGet oGetTot      Var nTot                    Of oFld2:aDialogs[1] Pixel Size 090,6  When .f. Picture AVSX3("EG0_DEM_V",6) HASBUTTON
   @ (nLin+24),005 Say AVSX3("EG0_PARC_C",5)                      Of oFld2:aDialogs[1] Pixel
   @ (nLin+24),085 MsGet oGetPar      Var M->EG0_PARC_C           Of oFld2:aDialogs[1] Pixel Size 090,6  When .f. Picture AVSX3("EG0_PARC_C",6) HASBUTTON
   @ (nLin+36),005 Say oSayParV Prompt cTitParc                   Of oFld2:aDialogs[1] Pixel //LRL 10/11/04
   @ (nLin+36),085 MsGet oGetParV     Var nParcVal                Of oFld2:aDialogs[1] Pixel Size 090,6  When .f. Picture AVSX3("EG0_DEM_V",6) HASBUTTON
   @ nLin,     177 Say STR0042                                    Of oFld2:aDialogs[1] Pixel //"Time allowed      "
   @ nLin,     225 MsGet oGetTAll     Var cTimeAllowed            Of oFld2:aDialogs[1] Pixel Size 045,6  When .f. 
   @ (nLin+12),177 Say AVSX3("EG0_USED",5)                        Of oFld2:aDialogs[1] Pixel 
   @ (nLin+12),225 MsGet oGetTUsed    Var cTimeUsed               Of oFld2:aDialogs[1] Pixel Size 045,6  When .f.
   @ (nLin+24),177 Say STR0043                                    Of oFld2:aDialogs[1] Pixel //"Time Lost/Saved"
   @ (nLin+24),225 MsGet oGetTLS      Var cTimeLS                 Of oFld2:aDialogs[1] Pixel Size 045,6  When .f.
   //** AAF 18/02/05 - Campo Time NOR
   If lExistFret
      @ (nLin+36),177 Say oSayTN   Prompt AVSX3("EG0_NOR",5)      Of oFld2:aDialogs[1] Pixel Size 70,6 FONT oDlg:oFont
      @ (nLin+36),225 MsGet oGetTN       Var M->EG0_NOR           Of oFld2:aDialogs[1] Pixel Size 045,6 When PnOpc # 2 .And. PnOpc # 5 Valid Eval(AVSX3("EG0_NOR",7)) Picture AVSX3("EG0_NOR",6)
   Endif
   //**
   @ (nLin),280 Say oSayHD   Prompt AVSX3("EG2_DIASEM",5)         Of oFld2:aDialogs[1] Pixel Size 70,6 FONT oDlg:oFont
   @ (nLin),325 MsGet oGetHD       Var M->EG0_TEMPO               of oFld2:aDialogs[1] Pixel Size 70,6  When .f. Picture AVSX3("EG0_TEMPO",6)  HASBUTTON//LRS - 27/11/2017
   @ (nLin+36),280 Say oSayTxt Prompt STR0130                     Of oFld2:aDialogs[1] Pixel COLOR CLR_HRED//"Quando o material é liquido não existe despatch"

   //aDialogs[2]*****
   @ nLin,     005 Say AVSX3("EG0_OW_TP",5)                       Of oFld2:aDialogs[2] Pixel
   @ nLin,     080 ComboBox oCmbOwnTp Var cOW_TP Items aOwnTp     Of oFld2:aDialogs[2] Pixel Size 95,6   When PnOpc # 2 .And. PnOpc # 5
   @ (nLin+12),005 Say AVSX3("EG0_OW_VL",5)                       Of oFld2:aDialogs[2] Pixel
   @ (nLin+12),080 MsGet M->EG0_OW_VL                             Of oFld2:aDialogs[2] Pixel Size 090,6  When PnOpc # 2 .And. PnOpc # 5 Picture AVSX3("EG0_DEM_V",6)  VALID POSITIVO() HASBUTTON
   @ (nLin+24),005 Say AVSX3("EG0_SITUA",5)                       Of oFld2:aDialogs[2] Pixel
   @ (nLin+24),080 MsGet M->EG0_SITUA                             Of oFld2:aDialogs[2] Pixel Size 090,6  When PnOpc # 2 .And. PnOpc # 5
   @ (nLin+36),005 Say AVSX3("EG0_PGT",5)                         Of oFld2:aDialogs[2] Pixel
   @ (nLin+36),080 MsGet M->EG0_PGT                               Of oFld2:aDialogs[2] Pixel Size 045,6  When PnOpc # 2 .And. PnOpc # 5 HASBUTTON
   If lExistFret
      @ (nLin),177 Say AVSX3("EG0_VCT",5)                         Of oFld2:aDialogs[2] Pixel
      @ (nLin),235 MsGet M->EG0_VCT                               Of oFld2:aDialogs[2] Pixel Size 045,6  When PnOpc # 2 .And. PnOpc # 5 HASBUTTON
      @ (nLin+12),177 Say oSayTotL  Prompt cTotalL                Of oFld2:aDialogs[2] Pixel Size 90,6 FONT oDlg:oFont
      @ (nLin+12),235 MsGet oGetTotL     Var cTotLoad             Of oFld2:aDialogs[2] Pixel Size 085,6  When .f.// Picture AVSX3("EG0_DEM_V",6)
      @ (nLin+24),177 Say oSayTotD  Prompt cTotalD                Of oFld2:aDialogs[2] Pixel Size 90,6 FONT oDlg:oFont
      @ (nLin+24),235 MsGet oGetTotD     Var cTotDisp             Of oFld2:aDialogs[2] Pixel Size 085,6  When .f.// Picture AVSX3("EG0_DEM_V",6)
      @ (nLin+36),177 Say AVSX3("EG0_NEG_TP",5)                   Of oFld2:aDialogs[2] Pixel Size 90,8 FONT oDlg:oFont
      @ (nLin+36),235 ComboBox oCmbNegTp Var cNeg_TP Items aOwnTp Of oFld2:aDialogs[2] Pixel Size 095,6   When PnOpc # 2 .And. PnOpc # 5 //Alcir - 31-01-05
      @ (nLin),340 Say AVSX3("EG0_NEG_VL",5)                      Of oFld2:aDialogs[2] Pixel
      @ (nLin),375 MsGet M->EG0_NEG_VL                            Of oFld2:aDialogs[2] Pixel Size 085,6  When PnOpc # 2 .And. PnOpc # 5 Picture AVSX3("EG0_DEM_V",6) VALID POSITIVO() HASBUTTON
   EndIf
   oSayTxt:Hide()
   //**

   If lExistDM        
      oGet2 := MsSelect():New("WORKPROC","MARCA",,aCpos,@lInvert,@cMarca,aPosTelaBase,,,oFld:aDialogs[2])
      oGet2 :bAval:= bMarca 
   Else
      oGet2 := MsSelect():New("WORKPROC",,,aCpos,@lInvert,@cMarca,aPosTelaBase,,,oFld:aDialogs[2])
   EndIf
   
   Eval(bHideAll)
   oGet2:oBrowse:Align := CONTROL_ALIGN_TOP
   oFld:bChange := {|nOption,nOldOption| Eval(bHide,nOldOption),;
                   Eval(bShow,nOption) }

   If lPriVez
      lPriVez   := .f.
      Eval(bShow,1)              
      oGet:ForceRefresh()
      If lExistDm
         SetParcelC()                                      
      EndIF
   Endif                
   oDlg:lMaximized := .T.
   
   IF PnOpc <> 3
      DM400LnOk(.T.,.F.)
   ENDIF
   
   oFld:Align      := CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oEnc:oBox:Align := CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oGet:oBrowse:Align := CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, bOK, bCancel,, aBotoes))   //*** GFP 01/08/2011 - Retirado bBarras                       
                               
If nOpcao == 1 // OK

   Begin Transaction
   
   If PnOpc == 3   // Inclusao
      RecLock("EG0",.t.)
      lOk := .t.
   Elseif PnOpc == 2   // Visualizar
      lOk := .F.
   Elseif PnOpc == 4   // Alteracao
      lOk := .t.
   Elseif PnOpc == 5    // Exclusao
      DM400Excl()
      lOK := .f.
   Endif                
   
   if lOk  

      If(EasyEntryPoint("AVGDM400"),ExecBlock("AVGDM400",.F.,.F.,"ANTES_GRAVACAO"),)

      For i := 1 to EG0->(FCount())
         EG0->&( FieldName(i) )   := M->&(EG0->(FieldName(i)))
      Next                    
   
      EG0->EG0_FILIAL := cFilEG0
      EG0->EG0_MODULO := Iif( nModulo == 17, "I", Iif( nModulo == 29, "E"," ") )
      EG0->EG0_VALPRO := nTot
      EG0->EG0_OW_TP  := Left(cOW_TP,1)
      MSMM(If(PnOpc == 4,EG0->EG0_OBS,), AVSX3("EG0_VM_OBS",3),, M->EG0_VM_OBS, 1,,, "EG0", "EG0_OBS") 
      If lExistFret
         MSMM(If(PnOpc == 4,EG0->EG0_BANCO,), AVSX3("EG0_VM_BCO",3),, M->EG0_VM_BCO, 1,,, "EG0", "EG0_BANCO")
         EG0->EG0_NEG_TP  := Left(cNEG_TP,1) //Alcir - 31-01-05
      EndIf
      EG0->( MSUnlock() )
   
      EG1->(DBSetOrder(1))

      WORKPROC->( DBGoTop() )
      Do While .not. WORKPROC->( EoF() )
         //LRL 16/11/04  - Vide lExistDm       -----------------------------
         If lExistDm 
           If nModulo == 17
               cSeekEG1 :=  cFilEG0 + EG0->EG0_MODULO + EG0->EG0_DEMURR + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST +;
               AVKey(WORKPROC->W8_HAWB,"EG1_EMBARQ") + AVKey(WORKPROC->W8_INVOICE,"EG1_NRINVO") + ;
               AVKey(WORKPROC->W8_PO_NUM,"EG1_PEDIDO")  + AVKey(WORKPROC->W8_POSICAO,"EG1_SEQUEN")
           Else
               cSeekEG1 :=  cFilEG0 + EG0->EG0_MODULO + EG0->EG0_DEMURR + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST +;
               AVKey(WORKPROC->EE9_PREEMB,"EG1_EMBARQ")+  AVKey(WORKPROC->EE9_NRINVO,"EG1_NRINVO") + ;
               AVKey(WORKPROC->EE9_PEDIDO,"EG1_PEDIDO")  + AVKey(WORKPROC->EE9_SEQUEN,"EG1_SEQUEN")
           EndIf
             If WORKPROC->MARCA == cMarca
                If EG1->( DBSeek(cSeekEG1 ) )
                   RecLock("EG1", .f.)
                Else 
                   RecLock("EG1", .t.)
                Endif    
                REPLACEEG1()
                EG1->( MSUnlock() )
             Else
               If EG1->( DBSeek(cSeekEG1 ) )
                  RecLock("EG1", .f.)
                  EG1->( DBDelete() )
                  EG1->( MSUnlock() )
               EndIF
             Endif
         Else
            cSeekEG1 :=  cFilEG0 + EG0->EG0_MODULO +  EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST +;
            Iif(nModulo == 17,AVKey(WORKPROC->W8_HAWB,"EG1_EMBARQ"), AVKey(WORKPROC->EE9_PREEMB,"EG1_EMBARQ")) 
                 
            If EG1->( DBSeek(cSeekEG1 ) )
               RecLock("EG1", .f.)
            Else 
               RecLock("EG1", .t.)
            Endif         
            REPLACEEG1()       
            EG1->( MSUnlock() )
         EndIF   
         EG1->( DBSkip() )
         WORKPROC->( DBSkip() )
      Enddo
      //                                    -----------------------------      
      
      Do While ( cFilEG0 + EG0->EG0_MODULO + if(lExistDm,EG0->EG0_DEMURR,"") + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) == ( cFilEG1 + EG1->EG1_MODULO + if(lExistDm,EG1->EG1_DEMURR,"")+ EG1->EG1_NAVIO + EG1->EG1_VIAGEM + EG1->EG1_DEST ) .and. .not. EG1->( EoF() ) //LRL 12/11/04 Vide lExistDM
         RecLock( "EG1", .f. )
         EG1->( DBDelete() )
         EG1->( MSUnlock() )
         EG1->( DBSkip() )
      Enddo
   
      EG2->(DBSetOrder(1))
      //EG2->(DBSeek( cFilEG0 + EG0->EG0_MODULO + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) ) 
      EG2->(DBSeek( cFilEG0 + EG0->EG0_MODULO + if(lExistDm,EG0->EG0_DEMURR,"") + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) ) //LRL 12/11/04 Vide lExistDM
      For i := 1 to Len(aCols)
          If aCols[i,nColTo] <> cHoraVazia .and. aCols[i,nColFrom] <> cHoraVazia
             If ( cFilEG0 + EG0->EG0_MODULO + if(lExistDm,EG0->EG0_DEMURR,"") + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) == ( cFilEG2 + EG2->EG2_MODULO + if(lExistDm,EG2->EG2_DEMURR,"")+ EG2->EG2_NAVIO + EG2->EG2_VIAGEM + EG2->EG2_DEST ) //LRL 12/11/04 Vide lExistDM
                RecLock( "EG2", .f.)
             Else
                RecLock( "EG2", .t.)
             Endif   
             EG2->EG2_FILIAL := cFilEG2
             EG2->EG2_MODULO := EG0->EG0_MODULO
             If lExistDm //LRL 12/11/04
                EG2->EG2_DEMURR := EG0->EG0_DEMURR 
             EndIf    
             EG2->EG2_NAVIO  := EG0->EG0_NAVIO
             EG2->EG2_VIAGEM := EG0->EG0_VIAGEM
             EG2->EG2_DEST   := EG0->EG0_DEST      
             EG2->EG2_DATA   := aCols[i, nColData]
             EG2->EG2_FROM   := aCols[i, nColFrom]
             EG2->EG2_TO     := aCols[i, nColTo]
             EG2->EG2_RATE   := aCols[i, nColRate]
             EG2->EG2_TIMEUS := aCols[i, nColTimeUs]
             If lExistFret //LRL 13/01/05
                EG2->EG2_TP_LD := aCols[i, nColTpLD]
             EndIf    
             if nColCodMen > 0
                EG2->EG2_CODMEN := aCols[i, nColCodMen]
             Endif
             if nColRemark > 0
                EG2->EG2_REMARK := aCols[i, nColRemark]
             Endif
             EG2->( DBSkip() )      
          EndIf
      Next
   
//    Do While .not. EG2->( EoF() ) .and. ( cFilEG0 + EG0->EG0_MODULO + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) == ( cFilEG2 + EG2->EG2_MODULO + EG2->EG2_NAVIO + EG2->EG2_VIAGEM + EG2->EG2_DEST ) 
      Do While .not. EG2->( EoF() ) .and. ( cFilEG0 + EG0->EG0_MODULO + if(lExistDm,EG0->EG0_DEMURR,"") + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) == ( cFilEG2 + EG2->EG2_MODULO + if(lExistDm,EG2->EG2_DEMURR,"")+ EG2->EG2_NAVIO + EG2->EG2_VIAGEM + EG2->EG2_DEST ) //LRL 12/11/04 Vide lExist
         RecLock( "EG2", .f. )
         EG2->( DBDelete() )
         EG2->( MSUnlock() )
         EG2->( DBSkip() )
      Enddo
   
   Endif 
   End Transaction
Else
   if PnOpc == 4 .or. PnOpc == 5  // Alteracao / Exclusao
      EG0->( MSUnlock() )
   EndIf
If(EasyEntryPoint("AVGDM400"),ExecBlock("AVGDM400",.F.,.F.,{"APOS_GRAVACAO",nOpcao}),) //LRS - 03/02/2015
Endif

Return .t.                                             

// ------------------------------------------ //
// Responsavel -- ACSJ - 19 de Janeiro de 2004
// Escrito Por -- Victor Iotti
Function AVDIFTIME(cInicial, cFinal)
// ----------------------------------------- //
Local nTime := 0
if (!empty(cFinal) .and. cFinal#Nil .and. !empty(cInicial) .and. cInicial#Nil) 
   nTime := (((Val(Left(cFinal,2))*60)+ Val(Right(cFinal,2)))-(( Val(Left(cInicial,2))*60)+ Val(Right(cInicial,2))))

endif 
Return nTime
// ------------------------------------------ //
// Responsavel -- ACSJ - 19 de Janeiro de 2004
// Escrito Por -- Victor Iotti
Function AVTIME(nVar,PQtdia)
// ------------------------------------------ // 
Local cTime     := '' 
LOCAL nMinuto   := 0

Default PQtdia  := 1

cTime     := StrZero(INT(nVar),PQtdia,0) + ':'
cTime     += Strzero(INT(Round( ( ( nVar - INT(nVar) ) * 24 ),2)),2,0) + ":"
nMinuto   := (((nVar - INT(nVar))*24)-( INT((nVar-INT(nVar))*24)))*60
cTime     += iif(nMinuto = 60, "00", Strzero(nMinuto,2,0))
   
Return cTime   
// ------------------------------------------ // 
// ACSJ - 19 de Janeiro de 2004
// Monta Barra de Botoes da Enchoice
// ------------------------------------------ //
Function DM400Bar(oDlg,bOk,bCancel,nOpc,aBotoes)
Return EnchoiceBar(oDlg, bOk, bCancel, , aBotoes)

// ---------------------------------------- 
// Valida os campos digitados na MSGetDados
// ACSJ - 20 De Janeiro de 2004
FUNCTION DM400FieldOk()   
// ----------------------------------------
LOCAL cVar	:= ReadVar(), lRet  := .t., nColAux:=0
LOCAL i

If cVar   == "M->EG2_DATA"

   If M->EG2_DATA <> dDataBase
      dDataAtual   := M->EG2_DATA
   Endif       
   If Empty(M->EG2_DATA)
      MsgStop(STR0047) //"A data deve ser preenchida"
      lRet := .f.
   ElseIf n > 1 .and. ( aCols[ (n-1), nColData ] > M->EG2_DATA )
      MsgStop(STR0048)//"A data não pode ser menor que a data anterior"
      lRet := .f.
   ElseIf  ( n <> Len(aCols) ) .and. ( M->EG2_DATA > aCols[(n+1), nColData] )
      MsgStop(STR0049) //"A data não pode ser maior que a data posterior"                       
      lRet := .f.
   Else
      //** AAF 19/02/05 - Conflito de periodos ao alterar data.
      If M->EG2_DATA <> aCols[n][nColData]
         For i:= 1 To Len(aCols)
            If aCols[i][nColData] == M->EG2_DATA
               If ( DM400ValTime(aCols[n][nColFrom]) >= DM400ValTime(aCols[i][nColFrom]) .AND. DM400ValTime(aCols[n][nColTo]) <= DM400ValTime(aCols[i][nColTo]  ) ) .OR.;
                  ( DM400ValTime(aCols[n][nColFrom]) <= DM400ValTime(aCols[i][nColFrom]) .AND. DM400ValTime(aCols[n][nColTo]) >= DM400ValTime(aCols[i][nColTo]  ) ) .OR.;
                  ( DM400ValTime(aCols[n][nColFrom]) <  DM400ValTime(aCols[i][nColTo]  ) .AND. DM400ValTime(aCols[n][nColTo]) >= DM400ValTime(aCols[i][nColTo]  ) ) .OR.;
                  ( DM400ValTime(aCols[n][nColFrom]) <= DM400ValTime(aCols[i][nColFrom]) .AND. DM400ValTime(aCols[n][nColTo]) >  DM400ValTime(aCols[i][nColFrom]) )
                  MsgStop(STR0171)//"Data não pode ser alterada pois estaria em conflito com outro periodo."
                  lRet:= .F.
                  Exit
               Endif
            Endif
         Next i
      Endif
      //**
      If lRet     
         M->EG2_DIASEM  := CdoW(M->EG2_DATA)
         aCols[ n, nColDtSem ]   := M->EG2_DIASEM
      Endif
   Endif

Elseif cVar	== "M->EG2_FROM"

   M->EG2_FROM := StrZero(Val(Left(M->EG2_FROM,2)),2,0) + ":" + Strzero(Val(Right(M->EG2_FROM,2)),2,0)
                          
   If Val(Left(M->EG2_FROM,2)) < 0 .OR. Val(Right(M->EG2_FROM,2)) < 0 //AAF - 17/02/05 - Numeros não negativos.
      MSGSTOP(STR0175)//"Horas ou Minutos não podem ser numeros negativos"
      M->EG2_FROM := "  :  "
      lRet := .F.
   ElseIf Val(Left(M->EG2_FROM,2)) > 24
      MSGSTOP(STR0050)//"Hora não pode ser maior que 24."   
      M->EG2_FROM := "  :  "
      lRet := .F.
   Elseif Val(Left(M->EG2_FROM,2)) == 24 .and. Val(Right(M->EG2_FROM,2)) <> 0
      MsgStop(STR0050)//"Hora não pode ser maior que 24."
      M->EG2_FROM := "24:00"
   EndIf
   If Val(Right(M->EG2_FROM,2)) > 59
      MSGSTOP(STR0052) //"Minuto não pode ser maior que 59."
      M->EG2_FROM := "  :  "
      lRet := .f.
   EndIf
   if aCols[n,nColTo]#nil .and. !Empty(aCols[n,nColTo])  //aCols[n,nColTo]<>cHoraVazia //Alcir Alves - 03-03-05
      If lRet .and. aCols[n,nColTo] <> cHoraVazia .and. M->EG2_FROM > aCols[n,nColTo]
         MSGSTOP(STR0053) //"Horas iniciais não pode ser maior que as horas finais."
         M->EG2_FROM := "  :  "
         lRet := .f.               
      EndIf             
   Endif
   If lRet .and. ( n > 1 ) .and. ( aCols[(n-1), nColData] == aCols[n, nColData] ) .and.;
      ( M->EG2_FROM < aCols[(n-1), nColTo] )   
      MsgStop(STR0054)//"Horas iniciais devem ser maior que as horas finais anterior"
      M->EG2_FROM := "  :  "
      lRet := .f.
   Endif                              
   /* //AAF - 17/02/05 - Validação retirada pois a condição não pode ser satisfeita.
   if lRet .and. ( Len(aCols) > 1 ) .and. ( Len(aCols) <> n ) .and. ( aCols[(n+1), nColData] == M->EG2_DATA ) .and.;
      ( M->EG2_FROM > aCols[(n+1), nColFrom] ) .and. ( aCols[(n+1), nColFrom] <> cHoraVazia )
      MsgStop(STR0055)//"Horas iniciais devem ser maior que as horas Iniciais posterior"
      M->EG2_FROM := "  :  "
      lRet := .f.      
   Endif   
   */
   if aCols[n,nColTo]#nil .and. aCols[n,nColTo]<>cHoraVazia  //Alcir Alves - 03-03-05
      If lRet .and. aCols[n,nColTo] <> cHoraVazia .and. M->EG2_FROM <= aCols[n,nColTo]
         M->EG2_TIMEUS :=  AVTIME( ( AVDIFTIME(M->EG2_FROM, aCols[n,nColTo]) * aCols[n,nColRate] ) / 1440 )   
      EndIf               
      aCols[n,nColFrom] := M->EG2_FROM                            
      If lRet .and. aCols[n,nColTo] <> cHoraVazia .and. M->EG2_FROM <= aCols[n,nColTo]
         aCols[n,nColTimeUs] := M->EG2_TIMEUS
      EndIf
   endif
Elseif cVar == "M->EG2_TO"                                                                                       
   M->EG2_TO := StrZero(Val(Left(M->EG2_TO,2)),2,0) + ":" + Strzero(Val(Right(M->EG2_TO,2)),2,0)
                 
   If Val(Left(M->EG2_TO,2)) < 0 .OR. Val(Right(M->EG2_TO,2)) < 0 //AAF - 17/02/05 - Numeros não negativos.
      MSGSTOP(STR0175)//"Horas ou Minutos não podem ser numeros negativos"
      M->EG2_TO := "  :  "
      lRet := .F.
   ElseIf Val(Left(M->EG2_TO,2)) > 24
      MSGSTOP(STR0050)//"Hora não pode ser maior que 24."
      M->EG2_TO := "  :  "
      lRet := .F.                       
   Elseif Val(Left(M->EG2_TO,2)) == 24 
      If Val(Right(M->EG2_TO,2)) <> 0
         MSGSTOP(STR0050)//"Hora não pode ser maior que 24."
         M->EG2_TO := "24:00"               
      Else
         dDataAtual := aCols[n,nColData] + 1
      Endif
   EndIf
   If Val(Right(M->EG2_TO,2)) > 59
      MSGSTOP(STR0052)//"Minuto não pode ser maior que 59."
      M->EG2_TO := "  :  "
      lRet := .F.
   EndIf                
   If lRet .and. aCols[n,nColFrom] <> cHoraVazia .and. aCols[n,nColFrom] > M->EG2_TO
      MSGSTOP(STR0051)//"Horas finais não pode ser maior que as horas iniciais."
      M->EG2_TO := "  :  "
      lRet := .F.
   EndIf         
   if lRet .and. ( Len(aCols) > 1 ) .and. ( Len(aCols) <> n ) .and. ( aCols[(n+1), nColData] == aCols[n, nColData] ) .and.;
      ( aCols[(n+1), nColTo] <> cHoraVazia )
      If M->EG2_TO > aCols[(n+1), nColTo]
         MsgStop(STR0056)//"Horas finais devem ser maior que as horas finais posterior"
         M->EG2_FROM := "  :  "      
         lRet := .f.      
      Elseif M->EG2_TO > aCols[(n+1), nColFrom]
         MsgStop(STR0057) //"Horas finais devem ser menor que as horas iniciais posterior"
         M->EG2_FROM := "  :  "      
         lRet := .f.      
      Endif
   Endif   
   If lRet .and. aCols[n,nColFrom] <> cHoraVazia .and. aCols[n,nColFrom] <= M->EG2_TO
      M->EG2_TIMEUS :=  AVTIME( ( ( AVDIFTIME(aCols[n,nColFrom], EG2_TO) * aCols[n,nColRate] ) / 1440 ) )
   EndIf                           
   
   aCols[n,nColTo]        := M->EG2_TO                            
   aCols[n,nColTimeUss]   := M->EG2_TIMEUS
   
Elseif cVar == "M->EG2_RATE"

   If M->EG2_RATE > 1
      MSGSTOP(STR0058)//"Rate não pode ser maior que 1."
      M->EG2_RATE   := 0
      lRet := .F.    
   Elseif M->EG2_RATE < 0                      
      MSGSTOP(STR0059)//"Rate não pode ser menor que 0."
      M->EG2_RATE   := 0
      lRet := .F.       
   Else
      If aCols[n,nColFrom] <> cHoraVazia .and. aCols[n,nColFrom] <= aCols[n,nColTo]
         M->EG2_TIMEUS   :=  AVTIME( ( AVDIFTIME(aCols[n,nColFrom], aCols[n,nColTo] ) * EG2_RATE) / 1440 )
         
         
         aCols[n,nColTimeUs]   := M->EG2_TIMEUS
      EndIf 
   EndIf   
   aCols[n,nColRate]   := M->EG2_RATE
     
Elseif cVar == "M->EG2_CODMEN"

   SY7->(DBSETORDER(3))		// JWJ 01/10/09: Acerto p/ utilizar a variável nColRemark ao invés de nColOBS
   If Empty(M->EG2_CODMEN)  // PLB 12/07/06
      If nColRemark > 0
         aCols[N,nColRemark] := SPACE(LEN(EG2->EG2_REMARK))
      EndIf
   Else
      If iif(nModulo == 17 ,! SY7->(DBSEEK(cFilSY7+AvKey("B","Y7_POGI")+AvKey(M->EG2_CODMEN,"Y7_COD"))),! EE4->(DBSEEK(cFilEE4+AvKey(M->EG2_CODMEN,"EE4_COD"))))
         MSGSTOP(STR0060)//"Observação não cadastrada."
         lRet := .F.             
      ElseIf nColRemark > 0
         aCols[N,nColRemark] := if(nModulo ==17 ,MSMM(SY7->Y7_TEXTO,60,1),MSMM(EE4->EE4_TEXTO,60))
      Endif
   EndIf        
   SY7->( DbSetOrder(1) )
   
Elseif cVar == "M->EG2_REMARK"	// JWJ 12/11/2009: Evitar duplicidade na col. Remarks na impressão do Demurrage

	If ! (Alltrim(M->EG2_REMARK) == ALLTRIM(aCols[N, nColRemark]))
		M->EG2_CODMEN 			 := SPACE(LEN(EG2->EG2_CODMEN))
		aCols[N, nColCodMen]  := SPACE(LEN(EG2->EG2_CODMEN))
	Endif

Endif

If lRet                                 
   nColAux := oGet:oBrowse:ColPos
   DM400Allowed( M->EG0_CARGO, M->EG0_RAT_LD, M->EG0_RAT_HD, .T. )
   DM400LnOk(.T.,.T.)           
   oGet:oBrowse:ColPos := nColAux 
Endif        

Return lRet
// ----------------------------------------
// Função que valida a linha quando a mesma perde o foco
// ACSJ - 21 de Janeiro de 2004
Function DM400LnOk(lAtuOBJAux,lIncArray)           
// ----------------------------------------
// Local lRet := .t. ACSJ - varialvel não é utilizada
LOCAL nSoma := 0
Local nSomaLoad := 0 //Soma de Carga
Local nSomaDisp := 0 //Soma de Descarga
Local i
//Local nLoadHour := 0 , nLoadDay := 0 
//Local nDispHour := 0 , nDispDay := 0 
lAtuOBJAux:=If(valtype(lAtuOBJAux)=='O',.T.,lAtuOBJAux)
// --- Calcula Horas Perdidas ou Salvas ( Demurrage/Despatch)

//** AAF 19/02/05 - Controle do Fretador.
If lExistFret .AND. nModulo == 29
   If M->EG0_FRETE == "2" .And. If(Len(aCols)>0,aCols[n][nColTpLD] == "2",.F.) //!ValTipoLD()
      MsgStop(STR0176)//"Somente Fretador pode controlar descarga."
      Return .F.
   ElseIf M->EG0_FRETE == "1" .AND. !Empty(M->EG0_CLIENT) .AND. If(Len(aCols)>0,aCols[n][nColTpLD] == "1",.F.)
      MsgStop(STR0170)//"Somente pode ser feito controle de descarga em demurrage para Cliente."
      Return .F.
   Endif
ElseIf lExistFret .AND. nModulo == 17
   If M->EG0_FRETE == "2" .And. If(Len(aCols)>0,aCols[n][nColTpLD] == "1",.F.) //!ValTipoLD()
      MsgStop(STR0185)//"Somente Fretador pode controlar carga."
      Return .F.
   ElseIf M->EG0_FRETE == "1" .AND. If(Len(aCols)>0,!Empty(M->EG0_CLIENT) .AND. aCols[n][nColTpLD] == "1",.F.)
      MsgStop(STR0186)//"Não pode ser feita carga em demurrage para Cliente."
      Return .F.
   Endif
Endif
//**

For i := 1 to Len(aCols)
   if ( aCols[ i, nColTo ] <> cHoraVazia ) .and. ( aCols[ i, nColFrom ] <> cHoraVazia )
      nSoma +=  ( ( AVDIFTIME(aCols[i,nColFrom], aCols[i,nColTo] ) * aCols[i,nColRate] ) / 1440 )
      If lExistFret
         If aCols[ i, nColTpLd ] = "1"  //Load                                                   
            nSomaLoad +=  ( ( AVDIFTIME(aCols[i,nColFrom], aCols[i,nColTo] ) * aCols[i,nColRate] ) / 1440 )
         Else
            nSomaDisp +=  ( ( AVDIFTIME(aCols[i,nColFrom], aCols[i,nColTo] ) * aCols[i,nColRate] ) / 1440 )
         EndIF
      EndIf  
   EndIf
Next         
nLostSavD := nSoma - nTimeAllowed - If(lExistFret,nTimeNOR,0)    // - Dias
//** AAF 17/02/05 - Tempo usado para carga e descarga
cTotLoad := AVTime(nSomaLoad,2)
cTotDisp := AVTime(nSomaDisp,2)
//**
/*
If lExistFret
   nLoadDay := nSomaLoad - nTimeAllowed - nTimeNOR    // - Dias 
   nDispDay := nSomaDisp - nTimeAllowed 
EndIf
*/
if (nLostSavD) < 0       // --- Despatch
   If lAtuOBJAux
      If M-> EG0_TIPO == "1"
         oSayRate:cCaption := STR0061 //"Rate of despatch"
         oSayTot:cCaption  := STR0062 //"Total despatch "             
         oSayParV:cCaption  := cParcelDes //LRL 10/11/04
         oSayTxt:Hide()
      else
         oSayRate:cCaption := STR0040//"Rate no demurrage/no despatch"
         oSayTot:cCaption  := STR0041//"Total no demurrage/no despatch         
         oSayParV:cCaption  := cParcel //LRL 10/11/04
         oSayTxt:Show()
      Endif
   EndIf
   nRate                := M->EG0_DES_V
   lDespatch            := .t.         
   If lAtuOBJAux           
      oSayHD:cCaption   := iif(M->EG0_DES_TP $ "1 ",STR0063,STR0064) //"Day"  -"Hour"
   EndIf
   M->EG0_CLASSI        := "2"
   
Elseif (nLostSavD) > 0   // --- Demurrage
   If lAtuOBJAux
      oSayRate:cCaption := STR0038 // "Rate of demurrage "
      oSayTot:cCaption  := STR0039//"Total demurrage "  
      oSayParV:cCaption  := cParcelDem //LRL 10/11/04
   EndIf
   nRate                := M->EG0_DEM_V
   lDespatch            := .f.
   If lAtuOBJAux   
      oSayHD:cCaption   := iif(M->EG0_DEM_TP $ "1 ",STR0063,STR0064) //"Day"  -"Hour"
   EndIf
   M->EG0_CLASSI     := "1"
   
Elseif (nLostSavD) = 0   // --- No Demurrage No Despatch
   If lAtuOBJAux
      oSayRate:cCaption := STR0040//"Rate no demurrage/no despatch"
      oSayTot:cCaption  := STR0041//"Total no demurrage/no despatch"
      oSayParV:cCaption  := cParcel //LRL 10/11/04
   EndIf
   nRate                := 0  
   lDespatch            := .f.                                 
   If lAtuOBJAux   
      oSayHD:cCaption := iif(M->EG0_DEM_TP $ "1 ",STR0063,STR0064) //"Day"  -"Hour"
   EndIf
   M->EG0_CLASSI     := "3"   
Endif

cTimeUsed   := AVTime(nSoma,2)                      // - Tempo Usado Total
cTimeLS     := AVTime(ABS(nLostSavD),2)             // - Tempo Perdido ou Salvo "dd:hh:mm"
M->EG0_USED := cTimeUsed                    
nLostSavH   := (Val(Left(cTimeLS,2))*24) + Val(Substr(cTimeLS,4,2)) +;
               (Val(Right(cTimeLS,2))/60)  // Tempo Perdido ou Salvo em Horas "999,9999999"
//nLoadHour   := (Val(Left(AVTime(nSomaLoad,2),2))*24) + Val(Substr(AVTime(nSomaLoad,2),4,2)) +(Val(Right(AVTime(nSomaLoad,2),2))/60)
//nDispHour   :=  (Val(Left(AVTime(nSomaDisp,2),2))*24) + Val(Substr(AVTime(nSomaDisp,2),4,2)) +(Val(Right(AVTime(nSomaDisp,2),2))/60)
If lDespatch
   If M->EG0_DES_TP == "2"       // --- Horas 
      M->EG0_TEMPO  := ABS(nLostSavH) 
      /*
      If lExistFret
         M->EG0_TLOAD  := ABS(nLoadHour)       
         M->EG0_TDISCH := ABS(nDispHour) 
      EndIf
      */
      nTot     := Val(Str((ABS(nLostSavH)*nRate),15,2))
      //nTotLoad := Val(Str((ABS(nLoadHour)*nRate),15,2))
      //nTotDisp := Val(Str((ABS(nDispHour)*nRate),15,2))
   Else    // Dias
      M->EG0_TEMPO  := ABS(nLostSavD) 
      /*
      If lExistFret
         M->EG0_TLOAD  := ABS(nLoadDay)       
         M->EG0_TDISCH := ABS(nDispDay) 
      EndIf
      */
      nTot     := Val(Str((ABS(nLostSavD)*nRate),15,2))    
      //nTotLoad := Val(Str((ABS(nLoadDay)*nRate),15,2))
      //nTotDisp := Val(Str((ABS(nDispDay)*nRate),15,2))
   Endif
Else
   If M->EG0_DEM_TP == "2"       // Hora
      M->EG0_TEMPO  := ABS(nLostSavH) 
      /*
      If lExistFret
         M->EG0_TLOAD  := ABS(nLoadHour)       
         M->EG0_TDISCH := ABS(nDispHour) 
      EndIf
      */
      nTot := Val(Str((ABS(nLostSavH)*nRate),15,2))    
      //nTotLoad := Val(Str((ABS(nLoadHour)*nRate),15,2))
      //nTotDisp := Val(Str((ABS(nDispHour)*nRate),15,2))
   Else   // Dias
      M->EG0_TEMPO  := ABS(nLostSavD) 
      /*
      If lExistFret
         M->EG0_TLOAD  := ABS(nLoadDay)       
         M->EG0_TDISCH := ABS(nDispDay) 
      EndIf
      */
      nTot := Val(Str((ABS(nLostSavD)*nRate),15,2))   
      //nTotLoad := Val(Str((ABS(nLoadDay)*nRate),15,2))
      //nTotDisp := Val(Str((ABS(nDispDay)*nRate),15,2))
   Endif
Endif
nParcVal := Val(Str((M->EG0_PARC_C / M->EG0_CARGO) * nTot,17,2))
// Se for ultimo registro e estiver preenchido corretamente - Inclui uma nova linha para edição
If n == Len(aCols)  .and. aCols[Len(aCols),nColTimeUs] <> " :  :  " .and.;
   ( aCols[Len(aCols),nColTo] <> cHoraVazia .and. aCols[Len(aCols),nColTo] <> cHoraVazia )
   If lIncArray
      IncaCols()   // Inclui uma linha vazia 
   EndIf
Endif                   
If lAtuOBJAux
   oGet:oBrowse:ColPos	:= 1
   oSayRate:Refresh()
   oSayTot:Refresh() 
   oSayParV:Refresh() //LRL 10/11/04
   oGetTUsed:Refresh()              
   oGetTLS:Refresh()                
   oGetRate:Refresh()
   oGetHD:Refresh()
   oSayHD:Refresh()        
   oGetTot:Refresh() 
   oGetPar:Refresh()              
   oGetParV:Refresh()                
   If lExistFret
      oGetTotL:Refresh()
      oGetTotD:Refresh()
      oSayTotL:Refresh()
      oSayTotD:Refresh()
   EndIf
EndIf
Return .t.
// ----------------------------------------
// Quando deletada uma linha sera apagada do aCols
// ACSJ - 22 de Janeiro de 2004
FUNCTION DM400DelOK()                      
// ----------------------------------------
LOCAL aAux := {},i
       
aCols[n, ( Len(aHeader) + 1 ) ] := .t.

For i := 1 to Len(aCols)
   If aCols[ i, ( Len(aHeader) + 1 ) ] == .f. .and. ( aCols[ i, nColTo ] <> cHoraVazia .and. ;
                                                      aCols[ i, nColFrom ] <> cHoraVazia )
      Aadd(aAux,aCols[i])
   Endif
Next

aCols := aAux     
//If Empty(aCols)
If Empty(aCols)  .or. (aCols[Len(aCols),nColTimeUs] <> " :  :  " .and.;
                 ( aCols[Len(aCols),nColTo] <> cHoraVazia .and. aCols[Len(aCols),nColTo] <> cHoraVazia ))  //LRL 10/11/04
   IncaCols()   // Inclui uma linha vazia 
Endif

DM400Allowed( M->EG0_CARGO, M->EG0_RAT_LD, M->EG0_RAT_HD, .T. )
DM400LnOk(.T.,.T.)           

oGet:ForceRefresh()

Return .t. 
// ----------------------------------------
// Inclui uma linha vazia no array (MSGETDADOS)
// ACSJ - 22 de Janeiro de 2003
FUNCTION IncaCols(nOpc)                      
// ----------------------------------------
LOCAL i 
If ValType(nOpc) <> "N" .Or. nOpc == 3
   //** AAF 17/02/05 - Correção de Problema na inclusão de linha com data incorreta.
   If Len(aCols) > 0
      dDataAtual := aCols[Len(aCols)][GDFieldPos("EG2_DATA")]
      If aCols[Len(aCols)][GDFieldPos("EG2_TO")] == "24:00"
         dDataAtual += 1
      Endif
   Endif
   //**
   M->EG2_DATA := dDataAtual
   Aadd( aCols,Array( Len(aHeader) + 1 ) )
         
   For i := 1 to Len(aHeader)    
      aCols[Len(aCols), i] := iif( aHeader[i,2] == "OBS",Space(30),;
                               iif( aHeader[i,2] == "EG2_FROM" .or. aHeader[i,2] == "EG2_TO","  :  ",;
                                iif( aHeader[i,2] == "EG2_TIMEUS", " :  :  ", IIf("REC_WT" $ aHeader[i,2], 0, IIf("ALI_WT" $ aHeader[i,2], "EG2", CriaVar(aHeader[i,2]))) ) ) )
   Next                     
   aCols[ Len(aCols), nColData ]        := dDataAtual
   aCols[ Len(aCols), nColTimeUs ]      := " :  :  "
   If lExistFret
        If  Len(aCols) > 1 
            cTipoLD :=    aCols[Len(aCols)-1,nColtpLD]
        EndIF       
        aCols[ Len(aCols), nColTpLD] := cTipoLD
   EndIF   
   aCols[ Len(aCols), Len(aHeader) + 1] := .f.     
EndIf
Return .t.       

//-----------------------------------------
// Validações do Pergunte
// ACSJ - 03 de Fevereiro de 2004
FUNCTION DM400VAL(PcVar)
// ----------------------------------------
Local lRet := .t.

If PcVar == "NAVIO"
   if .not. Empty(mv_par02)
      EE6->(dbSetOrder(1)) 
      if ALLTRIM(mv_par02) # ALLTRIM(EE6->EE6_COD) .AND. !EE6->(dbseek(cFilEE6+RTRIM(mv_par02)))                    
         MSGSTOP(STR0065)//"Navio não Encontrado!"
         lRet := .f.
      Endif
   Endif   
Elseif PcVar == "FORNEC"
   If ! SA2->(dbSeek(cFilSA2+mv_par05)) .and. .not. Empty(mv_par05)
      MSGSTOP(STR0066)//"Fornecedor não Encontrado!"
      lRet := .f.
   Endif         
Elseif PcVar == "PGINI"
   If mv_par08 > mv_par09 .and. .not. Empty(mv_par09)
      MSGStop(STR0067)//"Data inicial deve ser menor que a data final"
      lRet := .f.
   Endif
Elseif PcVar == "PGFIN"
   If mv_par09 < mv_par08 .and. .not. Empty(mv_par08) .and. .not. Empty(mv_par09)
      MSGStop(STR0068)//"Data final deve ser maior que a data inicial"
      lRet := .f.
   Endif
Endif

Return lRet
// ----------------------------------------
// Validações EG0(Enchoice)
// Escrito por : Victor Iotti
// Responsavel : ACSJ - 22 de Janeiro de 2004
Function RM400VAL(cVar)
// ----------------------------------------
Local lRet := .T.

Do Case
   CASE cVar == "EG0_NAVIO" 
        if !Empty(M->EG0_NAVIO)
           EE6->(dbSetOrder(1)) 
           //if ALLTRIM(M->EG0_NAVIO) # ALLTRIM(EE6->EE6_COD) .AND. !EE6->(dbseek(cFilEE6+RTRIM(M->EG0_NAVIO)))                    
           If !EE6->(dbseek(cFilEE6+AvKey(M->EG0_NAVIO,"EE6_COD"))) 
              M->EG0_VIAGEM := SPACE(LEN(EE6->EE6_VIAGEM))
              MSGSTOP(STR0065)//"Navio não Encontrado!"
              lRet := .F.
           else                               
//            M->EG0_VIAGEM := EE6->EE6_VIAGEM
              If .not. Empty(M->EG0_VIAGEM) .and. iif( M->EG0_REVER == "1", .t., .not. Empty(M->EG0_DEST) ) ;
                                        .and. iif( !lExistDm, .t., !Empty(M->EG0_DEMURR)) //LRL 12/11/04
                 MsAguarde( {|| lRet:=AchaProcessos()}, STR0069 )//"Pesquisando processos"
              Endif         
           endif     
        EndIf

   CASE cVar == "EG0_VIAGEM" 
        /*  EXPORTACAO /  IMPORTACAO NAO VALIDAM O CAMPO VIAGEM.  ACSJ - 02 de Fevereiro de 2004
        If ! Empty(M->EG0_VIAGEM)
           EE6->(dbSetOrder(1)) 
           if (ALLTRIM(M->EG0_NAVIO) # ALLTRIM(EE6->EE6_COD) .Or. ALLTRIM(EG0_VIAGEM) # ALLTRIM(EE6->EE6_VIAGEM)) .AND.;
              !EE6->(dbseek(cFilEE6+Left(M->EG0_NAVIO,LEN(EE6->EE6_COD))+EG0_VIAGEM))
              M->EG0_VIAGEM := SPACE(LEN(EE6->EE6_VIAGEM))
              MSGSTOP("Navio/Viagem não Encontrado!")
              lRet := .F.
           Else*/
              If .not. Empty(M->EG0_NAVIO) .and. .not. Empty(M->EG0_VIAGEM) .and. iif( M->EG0_REVER == "1", .t., .not. Empty(M->EG0_DEST) ) ;
                                                                                .and. iif( !lExistDm, .t., !Empty(M->EG0_DEMURR)) //LRL 12/11/04
                 MsAguarde( {|| lRet:=AchaProcessos()}, STR0069 )//"Pesquisando processos"
              Endif
         /*  EndIf                                                                 
        EndIf */
   CASE cVar == "EG0_DEST" 
        SY9->( DBSetOrder(2) ) 
        If ! Empty(M->EG0_DEST) .And. ! SY9->(dbSeek(cFilSY9+M->EG0_DEST))
           MSGSTOP(STR0070) //"Navio/Viagem não Encontrado!"
           lRet := .F.
        ElseIf Empty(M->EG0_DEST) .And. EG0_REVER # '1'
           MSGSTOP(STR0071)//"Porto de destino deve ser preenchido!"
           lRet := .F.
        Else
           M->EG0_VM_DES := SY9->Y9_DESCR
           If .not. Empty(M->EG0_NAVIO) .and. .not. Empty(M->EG0_VIAGEM) .and. iif( M->EG0_REVER == "1", .t., .not. Empty(M->EG0_DEST) );
                                                                              .and. iif( !lExistDm, .t., !Empty(M->EG0_DEMURR)) //LRL 12/11/04
              MsAguarde( {|| lRet:=AchaProcessos()}, STR0069 )//"Pesquisando processos"
           Endif
        EndIf        
        
   CASE cVar == "EG0_FORNEC" 
        If ! SA2->(dbSeek(cFilSA2+M->EG0_FORNEC))
           MSGSTOP(STR0066)//"Fornecedor não Encontrado!"
           lRet := .F.
        Else
           If lLojaFor
             M->EG0_FORLOJ := SA2->A2_LOJA
           ENdIf
           M->EG0_VM_FOR := SA2->A2_NREDUZ
        EndIf
    CASE cVar == "EG0_CLIENT" 
      If !Empty(M->EG0_CLIENT)  
         If M->EG0_FRETE == "2"
            MsgStop(STR0178,STR0179)//"Somente Fretador pode controlar demurrage de cliente."###"Aviso"
            lRet := .F.
         ElseIf ! SA1->(dbSeek(cFilSA1+M->EG0_CLIENT))
            MSGSTOP(STR0158) // "Cliente não Encontrado"
            lRet := .F.
         ElseIf !ValidaPro()                                               
            MSGSTOP(STR0159) //"Cliente da capa diferente do cliente do embarque "
            lRet := .F.
         Else
            aEval(aCols,{|X| X[nCOlTpLD] := "2"})  //AAF 19/02/05 - Controle somente de Descarga.
            cTipoLD := "2"
            oGet:oBrowse:Refresh()
            M->EG0_VM_CLI := SA1->A1_NREDUZ
            M->EG0_CLILOJ := SA1->A1_LOJA
         EndIf
      Else
         M->EG0_VM_CLI := ""
         M->EG0_CLIFOR := ""
      EndIf
      //AAF 18/02/05 - Atualiza Processos mesmo que o campo EG0_CLIENT esteja vazio.
      If lRet .AND. .not. Empty(M->EG0_NAVIO) .and. .not. Empty(M->EG0_VIAGEM) .and. iif( M->EG0_REVER == "1", .t., .not. Empty(M->EG0_DEST) ) ;
                                   .and. iif( !lExistDm, .t., !Empty(M->EG0_DEMURR)) //LRL 12/11/04
         MsAguarde( {|| lRet:=AchaProcessos()}, STR0069 )//"Pesquisando processos"
      Endif
   CASE cVar == "EG0_CLILOJ"
      If !Empty(M->EG0_CLIENT) .AND. !NaoVazio(M->EG0_CLILOJ)
         lRet:= .F.
      EndIf  
   CASE cVar == "EG0_DT_BOK" //LRL 21/10/04
        if .not. Empty(M->EG0_DT_BOK)
           If M->EG0_DT_BOK > M->EG0_ROADS
              MSGSTOP(AVSX3("EG0_ROADS",5)+STR0072)//"  não pode ser menor que a data do C/P B/N."
              lRet := .F.
           EndIf
        Endif
   
   CASE cVar == "EG0_ROADS" 
        if .not. Empty(M->EG0_ROADS)
           If M->EG0_ROADS < M->EG0_DT_BOK
              MSGSTOP(AVSX3("EG0_ROADS",5)+STR0072)//"  não pode ser menor que a data do C/P B/N."
              lRet := .F.
           Else
              M->EG0_ROADSW := CDOW(M->EG0_ROADS)
           EndIf
        Endif
   CASE cVar == "EG0_ROADST" 
        M->EG0_ROADST :=  StrZero(Val(Left(M->EG0_ROADST,2)),2,0) + ":" + Strzero(Val(Right(M->EG0_ROADST,2)),2,0)
        If Val(Left(M->EG0_ROADST,2)) > 23
           MSGSTOP(STR0073)//"Hora não pode ser maior que 23."
           lRet := .F.
        EndIf
        If Val(Right(M->EG0_ROADST,2)) > 59
           MSGSTOP(STR0052)//"Minuto não pode ser maior que 59."
           lRet := .F.
        EndIf

   CASE cVar == "EG0_BERT" 
        If .not. Empty(M->EG0_BERT)
           If M->EG0_BERT < M->EG0_ROADS 
              MSGSTOP(AVSX3("EG0_BERT",5) +STR0074 +AVSX3("EG0_ROADS",5))//" não pode ser menor que a data do "
              lRet := .F.
           Else
              M-> EG0_BERTW := CDOW(M->EG0_BERT)
           EndIf
        Endif
   CASE cVar == "EG0_BERTT" 
   		M-> EG0_BERTT := StrZero(Val(Left(M->EG0_BERTT,2)),2,0) + ":" + Strzero(Val(Right(M->EG0_BERTT,2)),2,0)
        If Val(Left(M->EG0_BERTT,2)) > 23
           MSGSTOP(STR0073)//"Hora não pode ser maior que 23."
           lRet := .F.
        EndIf
        If Val(Right(M->EG0_BERTT,2)) > 59
           MSGSTOP(STR0052)//"Minuto não pode ser maior que 59."
           lRet := .F.
        EndIf

   CASE cVar == "EG0_TEND" 
        If .not. Empty(M->EG0_TEND)
//           If M->EG0_TEND < M->EG0_BERT   -- Alterado a pedido da trevo - ACSJ - 15/03/2004
           If M->EG0_TEND < M->EG0_ROADS
//              MSGSTOP("Notice Tendered não pode ser menor que a data do Vessel Berthed.")  -- Alterado a pedido da trevo 
//                                                                                              ACSJ - 15/03/2004
              MSGSTOP(AVSX3("EG0_TEND",5) + STR0074 + AVSX3("EG0_ROADS",5))//" não pode ser menor que a data do "                	
              lRet := .F.
           Else
              M->EG0_TENDW := CDOW(M->EG0_TEND)
           EndIf
        Endif
   CASE cVar == "EG0_TENDT" 
        M->EG0_TENDT := StrZero(Val(Left(M->EG0_TENDT,2)),2,0) + ":" + Strzero(Val(Right(M->EG0_TENDT,2)),2,0)
        If Val(Left(M->EG0_TENDT,2)) > 23
           MSGSTOP(STR0073)//"Hora não pode ser maior que 23."
           lRet := .F.
        EndIf
        If Val(Right(M->EG0_TENDT,2)) > 59
           MSGSTOP(STR0052)//"Minuto não pode ser maior que 59."
           lRet := .F.
        EndIf
   CASE cVar == "EG0_ACCEP" 
        If .not. Empty(M->EG0_ACCEP)
           If M->EG0_ACCEP < M->EG0_TEND 
              MSGSTOP(AVSX3("EG0_ACCEP",5) + STR0074 + AVSX3("EG0_TEND",5) )//" não pode ser menor que a data do "
              lRet := .F.
           Else
              M->EG0_ACCEPW := CDOW(M->EG0_ACCEP)
           EndIf
        Endif
   CASE cVar == "EG0_ACCEPT" 
        M->EG0_ACCEPT := StrZero(Val(Left(M->EG0_ACCEPT,2)),2,0) + ":" + Strzero(Val(Right(M->EG0_ACCEPT,2)),2,0)
        If Val(Left(M->EG0_ACCEPT,2)) > 23
           MSGSTOP(STR0073)//"Hora não pode ser maior que 23."
           lRet := .F.
        EndIf
        If Val(Right(M->EG0_ACCEPT,2)) > 59
           MSGSTOP(STR0052)//"Minuto não pode ser maior que 59."
            lRet := .F.
        EndIf
   CASE cVar == "EG0_FROM" 
        If .not. Empty(M->EG0_FROM)
           If M->EG0_FROM < M->EG0_ACCEP 
              MSGSTOP(AVSX3("EG0_FROM",5)+STR0074+AVSX3("EG0_ACCEP",5))//" não pode ser menor que a data do  "
              lRet := .F.
           Else
              M->EG0_FROMW := CDOW(M->EG0_FROM)
           EndIf
        Endif
   CASE cVar == "EG0_FROMT" 
        M->EG0_FROMT := StrZero(Val(Left(M->EG0_FROMT,2)),2,0) + ":" + Strzero(Val(Right(M->EG0_FROMT,2)),2,0)
        If Val(Left(M->EG0_FROMT,2)) > 23
           MSGSTOP(STR0073)//"Hora não pode ser maior que 23."
           lRet := .F.
        EndIf
        If Val(Right(M->EG0_FROMT,2)) > 59
           MSGSTOP(STR0052)//"Minuto não pode ser maior que 59."
           lRet := .F.
        EndIf
   CASE cVar == "EG0_COMM" 
        If .not. Empty(M->EG0_COMM)
           If M->EG0_COMM < M->EG0_FROM 
              MSGINFO(AVSX3("EG0_COMM",5)+STR0074+AVSX3("EG0_FROM",5)) //" não pode ser menor que a data do "
           Else
              M->EG0_COMMW := CDOW(M->EG0_COMM)
           EndIF
        EndIF
   CASE cVar == "EG0_COMMT" 
        M->EG0_COMMT := StrZero(Val(Left(M->EG0_COMMT,2)),2,0) + ":" + Strzero(Val(Right(M->EG0_COMMT,2)),2,0)
                
        If Val(Left(M->EG0_COMMT,2)) > 23
           MSGSTOP(STR0073) //"Hora não pode ser maior que 23."
           lRet := .F.
        EndIf
        If Val(Right(M->EG0_COMMT,2)) > 59
           MSGSTOP(STR0052) //"Minuto não pode ser maior que 59."
           lRet := .F.
        EndIf

   CASE cVar == "EG0_COMP" 
        If .not. Empty(M->EG0_COMP)
           If M->EG0_COMP < M->EG0_COMM 
              MSGSTOP(AVSX3("EG0_COMP",5)+STR0074+AVSX3("EG0_COMM",5))//" não pode ser menor que a data do " 
              lRet := .F.
           Else
              M->EG0_COMPW := CDOW(M->EG0_COMP)
           EndIf
        Endif
   CASE cVar == "EG0_COMPT" 
        M->EG0_COMPT := StrZero(Val(Left(M->EG0_COMPT,2)),2,0) + ":" + Strzero(Val(Right(M->EG0_COMPT,2)),2,0)
        If Val(Left(M->EG0_COMPT,2)) > 23
           MSGSTOP(STR0073)//"Hora não pode ser maior que 23."
           lRet := .F.
        EndIf
        If Val(Right(M->EG0_COMPT,2)) > 59
           MSGSTOP(STR0052) //"Minuto não pode ser maior que 59."
           lRet := .F.
        EndIf
        
   CASE cVar == "EG0_CARGO" 
        If M->EG0_CARGO < 0
           MSGSTOP(AVSX3("EG0_CARGO",5)+STR0075)//" não pode ser menor que zero."
           lRet := .F.
       /* ElseIf M->EG0_CARGO = 0 //LRL 13/01/05 - Esse campo não é mais obrigatorio
           MSGSTOP(AVSX3("EG0_CARGO",5)+STR0075) //"não pode ser igual a zero."
           lRet := .F.  */
        ElseIf !Empty(M->EG0_PARC_C) .And. M->EG0_CARGO < EG0_PARC_C
           MSGSTOP(AVSX3("EG0_CARGO",5)+STR0077 +AVSX3("EG0_PARC_C",5)) //" não pode menor que a "
           lRet := .F.
        EndIf                     
        If lRet
           DM400Allowed( M->EG0_CARGO, M->EG0_RAT_LD, M->EG0_RAT_HD, .T. )
           DM400LnOk(.T.,.T.)           
        Endif        

   CASE cVar == "EG0_RAT_LD"     // ACSJ - 22 de Janeiro de 2002
       If M->EG0_RAT_LD < 0
          MsgStop(AVSX3("EG0_RAT_LD",5)+STR0075) //" não pode ser menor que zero."
          lRet := .f.
       Else
          DM400Allowed( M->EG0_CARGO, M->EG0_RAT_LD, M->EG0_RAT_HD, .T. )
          DM400LnOk(.T.,.T.)           
       Endif

   CASE cVar == "EG0_RAT_HD"
        If ! M->EG0_RAT_HD $ '12'
           MSGSTOP(STR0078)//"Deve ser digitado 1-Day ou 2-"Hour"."
           lRet := .F.
        Else
           DM400Allowed( M->EG0_CARGO, M->EG0_RAT_LD, M->EG0_RAT_HD, .T. )
           DM400LnOk(.T.,.T.)           
        EndIf                                           
   CASE cVar == "EG0_TIPO" 
        If ! M-> EG0_TIPO $ '12'
           MSGSTOP(STR0079)//"Deve ser digitado 1-Sólido ou 2-Liquido."
           lRet := .F.
        Else
           DM400LnOK(.T., .F.)
        EndIf
   CASE cVar == "EG0_REVER" 
        If ! M->EG0_REVER $ '12'
           MSGSTOP(STR0080)//"Deve ser digitado 1-Sim ou 2-Não."
           lRet := .F.      
        //** AAF 17/02/05 - Controle do Fretador.
        ElseIf nModulo == 29 .AND. M->EG0_FRETE == "2" .AND. M->EG0_REVER == "1"
           MsgStop(STR0180)//"Caso não seja o Fretador o demurrage não pode ser Reversivel"
           lRet := .F.
        //**
        Else 
           if M->EG0_REVER == "1"
              M->EG0_DEST := "   "   
              If .not. Empty(M->EG0_NAVIO) .and. .not. Empty(M->EG0_VIAGEM) ;
                          .and. iif( !lExistDm, .t., !Empty(M->EG0_DEMURR)) //LRL 12/11/04
                 MsAguarde( {|| lRet:=AchaProcessos()}, STR0069 )//"Pesquisando processos"
              Endif
           Elseif M->EG0_REVER == "2"
              If WORKPROC->(EasyRecCount("WORKPROC")) > 0
                 WORKPROC->( avzap() )   
                 oGet2:oBrowse:Refresh()
              Endif
              If .not. Empty(M->EG0_NAVIO) .and. .not. Empty(M->EG0_VIAGEM) .and. iif( M->EG0_REVER == "1", .t., .not. Empty(M->EG0_DEST) ) ;
                                                                          .and. iif( !lExistDm, .t., !Empty(M->EG0_DEMURR)) //LRL 12/11/04
                 MsAguarde( {|| lRet:=AchaProcessos()}, STR0069 )//"Pesquisando processos"
              Endif
           Endif
        EndIf
   CASE cVar == "EG0_DEM_TP" 
        If ! M->EG0_DEM_TP $ '12'
           MSGSTOP(STR0078)// "Deve ser digitado 1-Day ou 2-Hour."
           lRet := .F.
        EndIf                                     
        If lRet 
           DM400Allowed( M->EG0_CARGO, M->EG0_RAT_LD, M->EG0_RAT_HD, .T. )
           DM400LnOk(.T.,.T.)           
        EndIf
   CASE cVar == "EG0_DES_TP" 
        If ! M->EG0_DES_TP $ ' 12' .And. ! Empty(M->EG0_DES_TP)
           MSGSTOP(STR0078)// "Deve ser digitado 1-Day ou 2-Hour."
           lRet := .t.
        Endif
        If lRet 
           If M->EG0_DES_TP = '1' .AND. M->EG0_DEM_V != 0 .AND. M->EG0_DES_V == 0
              M->EG0_DES_V := (M->EG0_DEM_V / 2)
           EndIF
           DM400Allowed( M->EG0_CARGO, M->EG0_RAT_LD, M->EG0_RAT_HD, .T. )
           DM400LnOk(.T.,.T.)           
        EndIf
   CASE cVar == "EG0_MOEDA" 
        SYF->(DBSETORDER(1))
        If ! Empty(M->EG0_MOEDA) .And. ! SYF->(DBSEEK(cFilSYF+ M->EG0_MOEDA))
           MSGSTOP(STR0081)//"Moeda não cadastrada."
           lRet := .F.
        EndIf        
   CASE cVar == "EG0_DEM_V" 
        If M->EG0_DEM_V < 0
           MSGSTOP(STR0082)//"Rate of Demurrage não pode ser menor que zero."
           lRet := .F.
        EndIf
        if .not. lDespatch
           nRate := M->EG0_DEM_V
           oGetRate:Refresh()
        Endif        
        If lRet 
           DM400Allowed( M->EG0_CARGO, M->EG0_RAT_LD, M->EG0_RAT_HD, .T. )
           DM400LnOk(.T.,.T.)           
        EndIf
   CASE cVar == "EG0_DES_V" 
      If M->EG0_DES_V < 0
         MSGSTOP(STR0083)// "Rate of Despatch não pode ser menor que zero."
         lRet := .F.
      EndIf
      if lDespatch
         nRate := M->EG0_DES_V
         oGetRate:Refresh()
      Endif
      If lRet 
         DM400Allowed( M->EG0_CARGO, M->EG0_RAT_LD, M->EG0_RAT_HD, .T. )
         DM400LnOk(.T.,.T.)           
      EndIf                 
   CASE cVar == "EG0_FRETE" 
      //**AAF 19/02/05 - Controle de Fretador
      If M->EG0_FRETE == "2"
         //Caso não seja o Fretador
         M->EG0_CLIENT := CriaVar("EG0_CLIENT") //Não há controle de demurrage por cliente.
         M->EG0_CLILOJ := CriaVar("EG0_CLILOJ") //Não há controle de demurrage por cliente.
         M->EG0_VM_CLI := CriaVar("EG0_VM_CLI") //Não há controle de demurrage por cliente.
         M->EG0_REVER  := "2"                   //Não pode ser reversivel.
         If nModulo == 29
            aEval(aCols,{|X| X[nCOlTpLD] := "1"})//Controle somente de Carga.
            cTipoLD:= "1"
         Else
            aEval(aCols,{|X| X[nCOlTpLD] := "2"})//Controle somente de Descarga.
            cTipoLD:= "2"
         Endif
         
         oGet:oBrowse:Refresh()
      Endif
         lRet := .T.
   CASE cVar == "EG0_TCFDT" 
        If .not. Empty(M->EG0_TCFDT)
           M->EG0_TCFWK := CDOW(M->EG0_TCFDT)
        Endif
   CASE cVar == "EG0_TCFTM" 
        M->EG0_TCFTM := StrZero(Val(Left(M->EG0_TCFTM,2)),2,0) + ":" + Strzero(Val(Right(M->EG0_TCFTM,2)),2,0)
        If Val(Left(M->EG0_TCFTM,2)) > 23
           MSGSTOP(STR0073)//"Hora não pode ser maior que 23."
           lRet := .F.
        EndIf
        If Val(Right(M->EG0_TCFTM,2)) > 59
           MSGSTOP(STR0052) //"Minuto não pode ser maior que 59."
           lRet := .F.
        EndIf
   CASE cVar == "EG0_NOR" 
      If !Empty(M->EG0_NOR)                                                                                   
         If Val(Left(M->EG0_NOR,2)) < 0 .OR. Val(SubStr(M->EG0_NOR,4,2)) < 0 .OR. Val(Right(M->EG0_NOR,2)) < 0 //AAF - 18/02/05 - Numeros não negativos.
            MSGSTOP(STR0175)//"Horas ou Minutos não podem ser numeros negativos"
            M->EG0_NOR := "  :  :  "
            lRet := .F.
         ElseIf Val(SubStr(M->EG0_NOR,1,2)) > 24
            MSGSTOP(STR0050)//"Hora não pode ser maior que 24."
            M->EG0_NOR := "  :  :  "
            lRet := .F.                       
         Elseif Val(SubStr(M->EG0_NOR,1,2)) == 24 
            If Val(Right(M->EG0_NOR,2)) <> 0 .Or.  Val(Right(M->EG0_NOR,5,2)) <> 0
               MSGSTOP(STR0050)//"Hora não pode ser maior que 24."
               M->EG0_NOR := "  :  :  "               
               lRet := .F.                       
            Endif
         EndIf
         If Val(Right(M->EG0_NOR,5,2)) > 59
            MSGSTOP(STR0052)//"Minuto não pode ser maior que 59."
            M->EG0_NOR := "  :  :  "
            lRet := .F.
         EndIf                
         If Val(Right(M->EG0_NOR,2)) > 59
            MSGSTOP(STR0188)//"Segundo não pode ser maior que 59."
            M->EG0_NOR := "  :  :  "
            lRet := .F.
         EndIf            
         If Val(Left(M->EG0_NOR,2)) + Val(SubStr(M->EG0_NOR,4,2)) + Val(Right(M->EG0_NOR,2)) <= 0
            M->EG0_NOR := "  :  :  "
         EndIf
         If lRet
            nTimeNOR := Val(Left(M->EG0_NOR,2))+(Val(SubStr(M->EG0_NOR,4,2))/24)+(Val(Right(M->EG0_NOR,2))/1440) 
            DM400LnOk(.T.,.F.)
            oGetPar:Refresh()
            oGetParV:Refresh()           
         EndIf   
      EndIf
   CASE cVar == "EG0_FRETE"//AAF 19/02/05 - Somente fretador pode fazer carga e descarga.
      If M->EG0_FRETE == "2" .AND. nModulo == 29
         If aScan(aCols,{|X| X[nColTpLD] == "2"}) > 0
            If MsgYesNo(STR0181,STR0179)//"Somente fretador pode fazer controle de descarga, deseja alterar?"###"Aviso"
               aEval(aCols,{|X| X[nCOlTpLD] := "2"})
               cTipoLD := "2"
               oGet:oBrowse:Refresh()
            Else
               lRet := .F.
            Endif
         Endif
      ElseIf M->EG0_FRETE == "2" .AND. nModulo == 17
         If aScan(aCols,{|X| X[nColTpLD] == "1"}) > 0
            If MsgYesNo(STR0187,STR0179)//"Somente fretador pode fazer controle de carga, deseja alterar?"###"Aviso"
               aEval(aCols,{|X| X[nCOlTpLD] := "1"})
               cTipoLD := "1"
               oGet:oBrowse:Refresh()
            Else
               lRet := .F.
            Endif
         Endif
      Endif
EndCase

Return lRet
// ----------------------------------------

// ----------------------------------------
// Calcular tempo permitido Time Allowed
// ACSJ - 22 de Janeiro de 2004
FUNCTION DM400Allowed( PCarga, PTaxa, PTipo,PAtuOBJ )
// Paramentros
//             PCarga -> Peso Total em Toneladas Metricas
//             PTaxa  -> Taxa de Descarga
//             PTipo  -> Taxa de Descarga em Horas ou Dias
//	           PAtuOBJ-> Atualiza objeto GET
// Retornos
//             .t.
//             Atualiza a Variavel Private cTimeAllowed
//             Atualiza a Variavel Private nTimeAllowed
// ----------------------------------------  
LOCAL nTaxa

Default PTaxa    := 1   
Default PCarga   := 1                        
Default PTipo    := "2"     // ----------------- Horas


If PTipo == "2"
   nTaxa   := ( PTaxa * 24 )    // ------------- Taxa em Horas
Else
   nTaxa   := PTaxa
Endif 

nTimeAllowed     := (PCarga / nTaxa)          // ---- Tempo Permitido em dias

cTimeAllowed     := AVTime(nTimeAllowed,2)    // Tempo Permitido em dias:horas:minutos

nTimeAllowed := Val(Left(cTimeAllowed,2))+(Val(SubStr(cTimeAllowed,4,2))/24)+(Val(Right(cTimeAllowed,2))/1440) //LRL 17/09/04 -Correção de Aredondamento
If PAtuOBJ
   oGetTAll:Refresh()
EndIf

Return .t.                     

// ----------------------------------------
// Busca no SW6 os processos que respeitarem a chave
// NAVIO + VIAGEM + DESTINO
// ACSJ - 24 de Janeiro de 2004
FUNCTION ACHAPROCESSOS()
//-----------------------------------------
LOCAL cCond := "", lRet:=.T., aSemTrb := {}, cIdentVe ,cAliasold:=Alias()
Local nQtd := 0 //LRL 17/11/04        
Local cFil:="'"
Local lFrete := .t. //AAF 31/03/05
If lTop
  aEval(aFil,{|x,y| cFil += x + iIF(y == Len(aFil),"'","','")})
Else
  cFil:=""
  aEval(aFil,{|x,y| cFil += x + iIF(y == Len(aFil),"/","")})
EndIF
If !lExistDM .AND. EG0->(dbSeek(cFILEG0+Iif(nModulo==17,"I",Iif(nModulo==29, "E"," "))+M->EG0_NAVIO+M->EG0_VIAGEM+M->EG0_DEST)) //LRL 12/11/04 vide lExistDM
   MsgStop(STR0084)//"Demurrage / Despatch já cadastrado para este Navio/Viagem/Porto."
   lRet := .F.
EndIf
nMTAux := 0      
If nModulo == 17 .And. lRet // Variavel publica que indica o modulo em uso --// 17-IMPORTACAO  // --
   If lTop   // Banco de Dados
      IF lMulTiFil
         cCond += "W6_FILIAL IN (" + cFil + ") and " + iif( TcSrvType() <> "AS/400", "D_E_L_E_T_ <> '*' ", "@DELETED@ <> '*' " )
      Else
         cCond += "W6_FILIAL = '" + cFilSW6 + "' and " + iif( TcSrvType() <> "AS/400", "D_E_L_E_T_ <> '*' ", "@DELETED@ <> '*' " )
      EndIf   
      cCond += "and W6_IDENTVE = '" + M->EG0_NAVIO + "' "
      If lCpoViagem
         cCond += "and W6_VIAGEM = '" + M->EG0_VIAGEM + "' "
      Endif
      If M->EG0_REVER == "2"
         cCond += "and W6_DEST = '" + M->EG0_DEST + "' "
      Endif      
      If lExistFret .and. !Empty(M->EG0_CLIENT)
         cCond += " and W6_IMPORT = '" + AvKey(M->EG0_CLIENT,"W6_IMPORT") + "' "
      Endif      
      cCond += "and W6_DT_EMB > '' and (W6_DT_ENCE = '' OR W6_DT_ENCE = '        ')"
            
      cQuery:= "SELECT DISTINCT " +If(lMultiFil ,"W6_FILIAL, ","") +" W6_HAWB, W6_DEST, W6_CHEG " +;
               "FROM " + RetSqlName("SW6") + " SW6 Where " + cCond + " " +;
               "ORDER BY "+If(lMultiFil,"W6_FILIAL, ","") +"SW6.W6_HAWB"
      cQuery:=ChangeQuery(cQuery)
      TcQuery cQuery ALIAS "TRB" NEW               
               
   Else      // DBF  
      aSemTrb := {}                                  
      If lMulTiFil                                                                                      
         Aadd( aSemTrb,{"W6_FILIAL",     AVSX3("W6_FILIAL",2),    AVSX3("W6_FILIAL",3),    AVSX3("W6_FILIAL",4)} ) 
      EndIf
      Aadd( aSemTrb,{"W6_HAWB",     AVSX3("W6_HAWB",2),    AVSX3("W6_HAWB",3),    AVSX3("W6_HAWB",4)} ) 
      Aadd( aSemTrb,{"W6_DEST",     AVSX3("W6_DEST",2),    AVSX3("W6_DEST",3),    AVSX3("W6_DEST",4)} ) 
      Aadd( aSemTrb,{"W6_CHEG",     AVSX3("W6_CHEG",2),    AVSX3("W6_CHEG",3),    AVSX3("W6_CHEG",4)} )
      FileWork2:=E_CriaTrab(,aSemTrb,"TRB")   
      
      
      cIdentVe := AVKey(M->EG0_NAVIO,'W6_IDENTVE')

      If lMultiFil                                                                              
         cCond := "SW6->W6_FILIAL $ '"+cFil+"' .and. SW6->W6_IDENTVE == '" + cIdentVe + "' "
      Else
         cCond := "SW6->W6_FILIAL == '"+cFilSw6+"' .and. SW6->W6_IDENTVE == '" + cIdentVe + "' "
      EndIf
      If lCpoViagem
         cCond += ".and. SW6->W6_VIAGEM = '" + M->EG0_VIAGEM + "' "
      Endif                                                                         
      If M->EG0_REVER == "2"
         cCond += ".and. SW6->W6_DEST = '" + M->EG0_DEST  + "' "
      Endif      
      
      If lExistFret .and. !Empty(M->EG0_CLIENT)
         cCond += " .and. SW6->W6_IMPORT = '" + AvKey(M->EG0_CLIENT,"W6_IMPORT") + "' "
      Endif      
      cCond += ".and. .not. Empty(SW6->W6_DT_EMB) .and. Empty(SW6->W6_DT_ENCE) "
      
      SW6->(DBSetFilter( {|| &cCond }, cCond ) )
      
      SW6->( DBGoTop() )                           
      
      Do While .not. SW6->( EoF() )

         RecLock("TRB",.t.)                
         If lMulTiFil
            TRB->W6_FILIAL := SW6->W6_FILIAL
         EndIf
         TRB->W6_HAWB := SW6->W6_HAWB      
         TRB->W6_DEST := SW6->W6_DEST
         TRB->W6_CHEG := SW6->W6_CHEG 
         SW6->( MsUnlock() )            

         SW6->( DBSkip() )
      Enddo
   Endif  
   
   WORKPROC->(avzap() )
   M->EG0_PARC_C := 0   
// SW8->( DBSetOrder(6) )
   SW8->( DBSetOrder(1) )
   EG1->(dbsetorder(2))
   TRB->( DBGoTop() )    
   M->EG0_BERT := iif( lTop, CtoD( Right(TRB->W6_CHEG,2) + "/" + Substr(TRB->W6_CHEG,5,2) + "/" + Left(TRB->W6_CHEG,4) ), TRB->W6_CHEG )
   Do While .not. TRB->( EoF() )
      cFilSW8 := If(lMultiFil,TRB->W6_FILIAL,cFilSW8)
   //   If !EG1->(DBSeek(cFilEG1+iif(nModulo==17,"I",iif(nModulo==29,"E"," "))+AVKey(TRB->W6_HAWB,"EG1_EMBARQ"))) .And.;  
      If !EG1->(DBSeek(cFilEG1+iif(nModulo==17,"I",iif(nModulo==29,"E"," "))+if(lExistDM,M->EG0_DEMURR,"")+AVKey(TRB->W6_HAWB,"EG1_EMBARQ"))) .And.;  //LRL 12/11/04 -Vide lExistDm
         SW8->(DBSeek(cFilSW8+AVKey(TRB->W6_HAWB,"W8_HAWB")))
         Do While ! SW8->(EOF()) .And. cFilSW8 = SW8->W8_FILIAL .And. SW8->W8_HAWB = AVKey(TRB->W6_HAWB,"W8_HAWB")
            If lExistDm
               nQtd:=DMQtdUsd("TRB")
            EndIF
            If  nQTd < SW8->W8_QTDE
               GrvWorkW8('TRB',SW8->W8_QTDE - nQTd)
            EndIF   
            SW8->(DBSKIP())
         EndDo
      Endif                            
      TRB->( DBSkip() )
   Enddo  
   WORKPROC->( DBGoTop() )
   EG1->(dbsetorder(1))
   SW8->(DBSetOrder(1))   
   If Select("TRB") <> 0  
      TRB->(dbCloseArea())
      if !lTop
         FErase(FileWork2)
      Endif
   EndIf    
Elseif nModulo == 29 .And. lRet // 29-EXPORTACAO // --

   If lTop   // Banco de Dados
      If lMultiFil                                                                                                                 
         cCond += "EEC_FILIAL IN (" + cFil + ") and " + iif( TcSrvType() <> "AS/400", "D_E_L_E_T_ <> '*' ", "@DELETED@ <> '*' " )
      Else
         cCond += "EEC_FILIAL = '" + cFilEEC + "' and " + iif( TcSrvType() <> "AS/400", "D_E_L_E_T_ <> '*' ", "@DELETED@ <> '*' " )
      EndIf   
      cCond += "and EEC_EMBARC = '" + M->EG0_NAVIO + "' "
      /*If lCpoViagem*/ //AAF 15/02/05 - Não é necessário verificar se existe o campo EEC_VIAGEM.
      cCond += "and EEC_VIAGEM = '" + M->EG0_VIAGEM + "' "

      If M->EG0_REVER == "2"
         cCond += "and EEC_DEST = '" + M->EG0_DEST + "' "
      Endif                    
      If lExistFret .and. !Empty(M->EG0_CLIENT)
         cCond += " and ( (EEC_INTERM = '2' AND EEC_IMPORT = '" + AvKey(M->EG0_CLIENT,"EEC_IMPORT") + "') OR ( EEC_INTERM = '1' AND "+cCpoCliOff+"  = '" + AvKey(M->EG0_CLIENT,"EEC_IMPORT") + "') )"
      Endif      
      //LRL - 03/02/05
      // cCond += "and (EEC_DTEMBA = '' OR EEC_DTEMBA = '        ')"
               
      cQuery:= "SELECT DISTINCT "+if(lMultiFil,"EEC_FILIAL , ","") +" EEC_PREEMB, EEC_DEST, EEC_ETA" +;
               " FROM " + RetSqlName("EEC") + " EEC Where " + cCond + " " +;
               "ORDER BY "+if(lMultiFil,"EEC_FILIAL , ","") + "EEC.EEC_PREEMB"
               
      cQuery:=ChangeQuery(cQuery)
      TcQuery cQuery ALIAS "TRB" NEW               
   Else
      aSemTrb := {}                                                                                        
      If lMultiFil
         Aadd( aSemTrb,{"EEC_FILIAL",  AVSX3("EE9_FILIAL",2), AVSX3("EE9_FILIAL",3), AVSX3("EE9_FILIAL",4)} ) 
      EndIf
      Aadd( aSemTrb,{"EEC_PREEMB",  AVSX3("EE9_PREEMB",2), AVSX3("EE9_PREEMB",3), AVSX3("EE9_PREEMB",4)} ) 
      Aadd( aSemTrb,{"EEC_DEST",    AVSX3("EEC_DEST",2),   AVSX3("EEC_DEST",3),   AVSX3("EEC_DEST",4)} ) 
      Aadd( aSemTrb,{"EEC_ETA",     AVSX3("EEC_ETA",2),    AVSX3("EEC_ETA",3),    AVSX3("EEC_ETA",4)} )
      FileWork2:=E_CriaTrab(,aSemTrb,"TRB")   
      
      cIdentVe := AVKey(M->EG0_NAVIO,'EEC_EMBARC')
      
      If lMultiFil                                                                               
         cCond := "EEC->EEC_FILIAL $ '"+cFil+"' .and. EEC->EEC_EMBARC == '" + cIdentVe + "' "
      Else
         cCond := "EEC->EEC_FILIAL == '"+cFilEEC+"' .and. EEC->EEC_EMBARC == '" + cIdentVe + "' "
      EndIf
      cCond += ".and. EEC->EEC_VIAGEM = '" + M->EG0_VIAGEM + "' "

      If M->EG0_REVER == "2"
         cCond += ".and. EEC->EEC_DEST = '" + M->EG0_DEST  + "' "
      Endif      
      If lExistFret .and. !Empty(M->EG0_CLIENT)
        // cCond += " .and. EEC->EEC_IMPORT = '" + AvKey(M->EG0_CLIENT,"EEC_IMPORT") + "' "
         cCond += " .and. ( (EEC->EEC_INTERM = '2' .AND. EEC->EEC_IMPORT = '" + AvKey(M->EG0_CLIENT,"EEC_IMPORT") + "') .OR. ( EEC->EEC_INTERM = '1' .AND. EEC->"+cCpoCliOff+"  = '" + AvKey(M->EG0_CLIENT,"EEC_IMPORT") + "') )"
      Endif      
      //LRL - 03/02/05
      //cCond += ".and. Empty(EEC->EEC_DTEMBA)" 
      
      EEC->(DBSetFilter( {|| &cCond }, cCond ) )
      
      EEC->( DBGoTop() )                           
      
      Do While .not. EEC->( EoF() )

         RecLock("TRB",.t.)                      
         If lMultiFil
            TRB->EEC_FILIAL := EEC->EEC_FILIAL
         EndIf
         TRB->EEC_PREEMB := EEC->EEC_PREEMB      
         TRB->EEC_DEST   := EEC->EEC_DEST
         TRB->EEC_ETA    := EEC->EEC_ETA 
         TRB->( MsUnlock() )            

         EEC->( DBSkip() )
      Enddo
   Endif                                           
   
   WorkProc->(avzap() )
   M->EG0_PARC_C := 0      
   EE9->( DBSetOrder(2) )   
   EG1->(dbsetorder(2))
   TRB->( DBGoTop() )                                                                                                                     
   
   M->EG0_BERT := iif( lTop, CtoD( Right(TRB->EEC_ETA,2) + "/" + Substr(TRB->EEC_ETA,5,2) + "/" + Left(TRB->EEC_ETA,4) ), TRB->EEC_ETA )
 
   Do While .not. TRB->( EoF() )
      cFilEEC:=cFilEE9:=If(lMUltifil,TRB->EEC_FILIAL,cFilEEC)
      If !EG1->( DBSeek(cFilEG1 + "E" +if(lExistDM,M->EG0_DEMURR,"")+AVKey(TRB->EEC_PREEMB,"EG1_EMBARQ")) )  .And.; //LRL 12/11/04
         EE9->( DBSeek(cFilEE9+AVKey(TRB->EEC_PREEMB,"EEC_PREEMB")) )
         EEC->( DBSeek(cFilEEC+AVKey(TRB->EEC_PREEMB,"EEC_PREEMB")) )
         
         //** AAF 31/03/05 - Atualiza campo Fretador para SIM caso o incoterm de algum embarque possua Frete.
         lFrete:= lFrete .and. Posicione("SYJ",1,xFilial("SYJ")+EEC->EEC_INCOTE,"YJ_CLFRETE") == "1"
         //**
         
         Do While ! EE9->(EOF()) .And. cFilEE9 = EE9->EE9_FILIAL .And. EE9->EE9_PREEMBB = AVKey(TRB->EEC_PREEMB,"EEC_PREEMB")
            If lExistDm
               nQtd:=DMQtdUsd("TRB")
            EndIF
            If nQTd < EE9->EE9_SLDINI
                 GrvWorkEE9('TRB',EE9->EE9_SLDINI - nQTd)
            EndIF   
            EE9->(DBSKIP())
         EndDo
      Endif                            
      TRB->( DBSkip() )
   Enddo  
   WORKProc->( DBGoTop() )
   EG1->(dbsetorder(1))
   EE9->(DBSetOrder(1))   
   If Select("TRB") <> 0  
      TRB->(dbCloseArea())
//      if !lTop
//         FErase(FileWork2)
//      Endif
   EndIf   
     
Endif

If nMTAux = 0  .AND. lRet
   If !lExistDm //18/11/04
      MsgStop(STR0085)//"Não existe processo para este Navio/Viagem/Porto."
   ElseIF WORKPROC->(BOF()) .AND. WORKPROC->(EOF())
      MsgStop(STR0085)//"Não existe processo para este Navio/Viagem/Porto."
   EndIf   
EndIf
DbSelectArea(cAliasold)
M->EG0_PARC_C := nMTAux

//** AAF 31/03/05 - Atualiza o Fretador caso haja frete em algum incoterm
If lFrete
   M->EG0_FRETE := "1"
Endif
//**

nParcVal := (M->EG0_PARC_C / M->EG0_CARGO) * nTot
oGetPar:Refresh()              
oGetParV:Refresh()                
oGet2:oBrowse:Refresh()                                   
Return lRet

//----------------------------------------------
// Rotina de Exclusão de Demurrage
// ACSJ - 26 de Janeiro de 2004
FUNCTION DM400EXCL()
// ---------------------------------------------
EG2->(DBSetOrder(1))
//EG2->(DBSeek( cFilEG0 + EG0->EG0_MODULO + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) )
EG2->(DBSeek( cFilEG0 + EG0->EG0_MODULO +if (lExistDM,EG0->EG0_DEMURR,"")+EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) ) //LRL 12/11/04 - vide lExistDM
lSair := .F. 
If(EasyEntryPoint("AVGDM400"),ExecBlock("AVGDM400",.F.,.F.,"ANTES_EXCLUSAO"),)
If lSair 
   Return .T. 
EndIf

//Do While ( cFilEG0 + EG0->EG0_MODULO + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) == ( cFilEG2 + EG2->EG2_MODULO + EG2->EG2_NAVIO + EG2->EG2_VIAGEM + EG2->EG2_DEST ) .and. .not. EG2->( EoF() ) 
Do While ( cFilEG0 + EG0->EG0_MODULO +if (lExistDM,EG0->EG0_DEMURR,"")+ EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) == ( cFilEG2 + EG2->EG2_MODULO +if (lExistDM,EG2->EG2_DEMURR,"")+ EG2->EG2_NAVIO + EG2->EG2_VIAGEM + EG2->EG2_DEST ) .and. .not. EG2->( EoF() )   //LRL 12/11/04 vid lExistDM
   RecLock( "EG2", .f. )
   EG2->( DBDelete() )
   EG2->( MSUnlock() )
   EG2->(DBSkip())
Enddo

EG1->(DBSetOrder(1))
//EG1->(DBSeek( cFilEG0 + EG0->EG0_MODULO + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) )
EG1->(DBSeek( cFilEG0 + EG0->EG0_MODULO + if (lExistDM,EG0->EG0_DEMURR,"")+ EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) ) //LRL 12/11/04 Vide lExistDm

//Do While ( cFilEG0 + EG0->EG0_MODULO + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) == ( cFilEG1 + EG1->EG1_MODULO + EG1->EG1_NAVIO + EG1->EG1_VIAGEM + EG1->EG1_DEST ) .and. .not. EG1->( EoF() )  
Do While ( cFilEG0 + EG0->EG0_MODULO + if (lExistDM,EG0->EG0_DEMURR,"") + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) == ( cFilEG1 + EG1->EG1_MODULO + if (lExistDM,EG1->EG1_DEMURR,"") + EG1->EG1_NAVIO + EG1->EG1_VIAGEM + EG1->EG1_DEST ) .and. .not. EG1->( EoF() ) //LRL 12/11/04 Vide lExistDM
   RecLock( "EG1", .f. )
   EG1->( DBDelete() )
   EG1->( MSUnlock() )
   EG1->(DBSkip())
Enddo                
MSMM(EG0->EG0_OBS,,,,2)
If lExistFret          
   MSMM(EG0->EG0_BANCO,,,,2)
EndIf
EG0->( DBDelete() )      
EG0->( MSUnlock() )

Return .t.

// --------------------------------------------
// Gravação de Dados na WORKPROC
// ACSJ - 26 de Janeiro de 2004
// LRL  - 17 de Novembro de 2004  - Revisão
FUNCTION GRVWORKW8(cArq,nQtdUc,lAppend)                       
// --------------------------------------------
Local nQTDE := 0, nPesoL := 0
Default nQtdUc := 0
Default lAppend := .T.      
SAH->(DBSeek(cFilSAH+AVKey(SW8->W8_UNID,"AH_UNIMED")) )                                    
                                                  
If SAH->AH_COD_SIS = '21'     // Toneladas
   nQTDE := If (nQtdUC > 0 ,nQtdUC,SW8->W8_QTDE) //LRL 17/11/04 - Para quebra da di
ElseIf SAH->AH_COD_SIS = '10' // Kg
   nQTDE := If (nQtdUC > 0 ,nQtdUC,SW8->W8_QTDE) / 1000    
ElseIf SW7->(DbSeek(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM)) .And. SW7->W7_PESO # 0
   nQTDE := SW7->W7_PESO * If (nQtdUC > 0 ,nQtdUC,SW8->W8_QTDE) / 1000
Else
   nPesoL := B1Peso(SW8->W8_CC, SW8->W8_SI_NUM, SW8->W8_COD_I, SW8->W8_REG, SW8->W8_FABR, SW8->W8_FORN)
   If nPesoL # 0
      nQTDE := nPesoL * If (nQtdUC > 0 ,nQtdUC,SW8->W8_QTDE) / 1000
   Else
      nQTDE := AVTransUnid(SW8->W8_UNID, "MT", SW8->W8_COD_I, If (nQtdUC > 0 ,nQtdUC,SW8->W8_QTDE))   
   EndIf
EndIf
If !lExistDM //LRL 18/11/04
   nMTAux += nQTDE
EndIF   
RecLock("WORKPROC",lAppend)        
WORKPROC->W8_HAWB      := SW8->W8_HAWB
WORKPROC->W8_INVOICE   := SW8->W8_INVOICE
WORKPROC->W8_COD_I     := SW8->W8_COD_I   
WORKPROC->W8_QTDEMT    := nQTDE
WORKPROC->W8_QTDEUC    := If (nQtdUC > 0 ,nQtdUC,SW8->W8_QTDE)
WORKPROC->W8_UNID      := SW8->W8_UNID
WORKPROC->W8_PO_NUM    := SW8->W8_PO_NUM
WORKPROC->W8_POSICAO   := SW8->W8_POSICAO
If lExistDM //LRL 12/11/04
   WORKPROC->EG1_COEF     := nQTDE / If (nQtdUC > 0 ,nQtdUC,SW8->W8_QTDE)
   If !lAppend 
      WORKPROC->MARCA := cMarca
   ElseIf lAppend .And. M->EG0_REVER <> "1"
      WORKPROC->W6_DEST      := (cArq)->W6_DEST
   EndIf
Else
   WORKPROC->W6_DEST      := (cArq)->W6_DEST 
EndIF                                    
IF lMultiFil
   WORKPROC->FILORI   := SW8->W8_FILIAL
ENdIf
WORKPROC->TRB_ALI_WT:= "SW8"
WORKPROC->TRB_REC_WT:= SW8->(Recno())
WORKPROC->( MSUnlock() )

Return .t.
 
// --------------------------------------------
// Gravação de Dados na WorkEEC
// ACSJ - 02 de Fevereiro de 2004       
// LRL  - 17 de Novembro de 2004  - Revisão
// AAF  - 16 de Fevereiro de 2005 - Revisão
FUNCTION GRVWORKEE9(cArq,nQtdUc,lAppend)                       
// --------------------------------------------
Local nQTDE := 0, cUnidade:=''
// Local nPesoL := 0  - ACSJ - Variavel não é utilizada.
Default nQtdUc := 0
Default lAppend := .T.

Begin Sequence
   
   SB1->( DBSetOrder(1) )
   SB1->( DBSeek( xFilial("SB1")+EE9->EE9_COD_I ) )
   
   cUnidade:=EE9->EE9_UNIDAD
   If(Empty(cUnidade),cUnidade:=EEC->EEC_UNIDAD,)
   If(Empty(cUnidade),cUnidade:=EE9->EE9_UNPRC,)
   If(Empty(cUnidade),cUnidade:=EE9->EE9_UNPES,)
   If(Empty(cUnidade),cUnidade:=SB1->B1_UM,)
   
   SAH->(DBSeek(cFilSAH+AVKey(cUnidade,"AH_UNIMED")) )
   
   If SAH->AH_COD_SIS = '21'     // Toneladas
      nQTDE := If (nQtdUC > 0 ,nQtdUC,EE9->EE9_SLDINI)
   ElseIf SAH->AH_COD_SIS = '10' // Kg
      nQTDE := If (nQtdUC > 0 ,nQtdUC,EE9->EE9_SLDINI) / 1000
   //AAF - 16/02/05 - Comentado pois a condição nunca é satisfeita.
   //Elseif .not. Empty(EE9->EE9_PSBRTO)
   //   nQTDE := EE9->EE9_PSBRTO / 1000
   Else
      If SB1->B1_PESO # 0
         nQTDE := SB1->B1_PESO * If (nQtdUC > 0 ,nQtdUC,EE9->EE9_SLDINI) / 1000
      Else
         nQTDE := AVTransUnid(cUnidade, "MT", EE9->EE9_COD_I, If (nQtdUC > 0 ,nQtdUC,EE9->EE9_SLDINI), .t.)
         //** AAF - 16/02/05 - Conversão pelo peso liquido do item informado no embarque.
         If ValType(nQTDE) == "U" .AND. !Empty(EE9->EE9_UNPES)
            nQTDE := AVTransUnid(EE9->EE9_UNPES, "MT", EE9->EE9_COD_I, If (nQtdUC > 0 ,nQtdUC,EE9->EE9_SLDINI*EE9->EE9_PSLQUN), .t.)
         Endif
         //**
         If ValType(nQTDE) == "U"
            //Break
            nQTDE := 0
         Endif
      Endif
   EndIf
   
   If !lExistDM //LRL 18/11/04
      nMTAux += nQTDE
   EndIF
   
   RecLock("WORKPROC",lAppend)
   WORKPROC->EE9_PREEMB   := EE9->EE9_PREEMB
   WORKPROC->EE9_NRINVO   := EEC->EEC_NRINVO
   WORKPROC->EE9_COD_I    := EE9->EE9_COD_I
   WORKPROC->EE9_QTDEMT   := nQTDE
   WORKPROC->EE9_QTDEUC   := If (nQtdUC > 0 ,nQtdUC,EE9->EE9_SLDINI)
   WORKPROC->EE9_UNIDAD   := EE9->EE9_UNIDAD
   WORKPROC->EE9_PEDIDO   := EE9->EE9_PEDIDO
   WORKPROC->EE9_SEQUEN   := EE9->EE9_SEQUEN
   If lExistDM //LRL 12/11/04
      WORKPROC->EG1_COEF     := nQTDE / If (nQtdUC > 0 ,nQtdUC,EE9->EE9_SLDINI)
      If !lAppend
         WORKPROC->MARCA := cMarca
      ElseIf lAppend .And. M->EG0_REVER <> "1"
         WORKPROC->EE9_DEST     := (cArq)->EEC_DEST
      EndIf
   Else
      WORKPROC->EE9_DEST     := (cArq)->EEC_DEST
   EndIf
   WORKPROC->TRB_ALI_WT:= "EE9"
   WORKPROC->TRB_REC_WT:= EE9->(Recno())
   WORKPROC->( MSUnlock() )

End Sequence

Return .t.

// ---------------------------------------------------
// Validações que serão feitas apos pressionado o botao Ok
// ACSJ - 26 de Janeiro de 2004
FUNCTION DM400TUDOK(POpcao)
// ---------------------------------------------------
LOCAL lRet := .t.
POpcao     := 1


//Alcir - 25-11-04 - validação após manutenção
If M->EG0_CARGO < 0
   MSGSTOP(AVSX3("EG0_CARGO",5)+STR0075)//" não pode ser menor que zero."
   lRet := .F.
   POpcao := 0
ElseIf M->EG0_CARGO = 0
   MSGSTOP(AVSX3("EG0_CARGO",5)+STR0075) //"não pode ser igual a zero."
   lRet := .F.
   POpcao := 0
ElseIf !Empty(M->EG0_PARC_C) .And. M->EG0_CARGO < EG0_PARC_C
   MSGSTOP(AVSX3("EG0_CARGO",5)+STR0077 +AVSX3("EG0_PARC_C",5)) //" não pode menor que a "
   lRet := .F.
   POpcao := 0
EndIf                     

                 
If M->EG0_TIPO == "1"      // SOLIDO
   If Empty(M->EG0_DES_V)  // Valor cobrado no caso de despatch.           
      MsgStop(STR0086 +AVSX3("EG0_DES_V",5) + STR0087) //"O campo - deve ser informado no caso de carga solida."
      lRet   := .f.
      POpcao := 0
   Endif
   
   If Empty(EG0_DES_TP)  // Tipo de cobrança de despatch, por hora ou por dia
      MsgStop(STR0086 +AVSX3("EG0_DES_TP",5) + STR0087) // "O campo  - deve ser informado no caso de carga solida."
      lRet := .f.
      POpcao := 0
   Endif      
Endif         
If M->EG0_REVER == "2"    // NÃO REVERSIVEL
   If Empty(M->EG0_DEST)  // Porto Destino.
      MsgStop(STR0086+AVSX3("EG0_DEST",5)+STR0088)//"O campo Disch. Port deve ser preenchido" 
      lRet := .f.
      POpcao := 0
   Endif
Endif

lRet := lRet .AND. DM400LnOk(.F.,.T.)//AAF 25/02/05

Return lRet

//********************************
*-------------------------------------------------------------------------------------------------------------*
Static FUNCTION DM400EG2(lImpr, nOpc)
*-------------------------------------------------------------------------------------------------------------*
Local ni, cRemark

If nOpc <> 3

   EG2->(DBSetOrder(1) )
   //EG2->(DBSeek(cFilEG0 + EG0->EG0_MODULO + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) )  
   EG2->(DBSeek(cFilEG0 + EG0->EG0_MODULO + if (lExistDM,EG0->EG0_DEMURR,"")+EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ) ) //LRL 12/11/04 vide lExistDM
   aCols := {} 
   i := 0
   SY7->(DBSETORDER(3))
   //Do While (cFilEG0+EG0->EG0_MODULO+EG0->EG0_NAVIO+EG0->EG0_VIAGEM+EG0->EG0_DEST) == (cFilEG2+EG2->EG2_MODULO+EG2->EG2_NAVIO+EG2->EG2_VIAGEM+EG2->EG2_DEST) .and. !EG2->(EoF())
   Do While (cFilEG0+EG0->EG0_MODULO+ if (lExistDM,EG0->EG0_DEMURR,"")+EG0->EG0_NAVIO+EG0->EG0_VIAGEM+EG0->EG0_DEST) == (cFilEG2+EG2->EG2_MODULO+if (lExistDM,EG2->EG2_DEMURR,"")+EG2->EG2_NAVIO+EG2->EG2_VIAGEM+EG2->EG2_DEST) .and. !EG2->(EoF()) //LRL 12/11/04 vide lExistDM
      i ++
      //If !lImpr  //CCH - 15/07/2008 - Verifica se não foi chamada a rotina de impressão. Se Sim, não é necessário carregar o aCols.
         Aadd( aCols,Array( Len(aHeader) + 1 ) )
         GdFieldPut("EG2_ALI_WT", "EG2", i)
         GdFieldPut("EG2_REC_WT", EG2->(Recno()), i)
         aCols[i, nColData]   := EG2->EG2_DATA
         aCols[i, nColDtSem]  := CdoW(EG2->EG2_DATA)
         aCols[i, nColFrom]   := EG2->EG2_FROM
         aCols[i, nColTo]     := EG2->EG2_TO
         dDataAtual:=  if ( Val(Left(aCols[i,nColTo],2)) < 24 , EG2->EG2_DATA ,EG2->EG2_DATA+1)      //LRL 09/10/04
         aCols[i, nColRate]   := EG2->EG2_RATE
         aCols[i, nColTimeUs] := EG2->EG2_TIMEUS
         If lExistFret //LRL 13/01/05
            aCols[i, nColTpLD] := EG2->EG2_TP_LD
         EndIf    
         If nColCodMen > 0 
            aCols[i, nColCodMen] := EG2->EG2_CODMEN
         Endif
         If nColRemark > 0
            aCols[i, nColRemark] := EG2->EG2_REMARK
         Endif
         aCols[i, ( Len(aHeader) + 1 ) ] := .F.
         If !Empty(EG2->EG2_CODMEN) .And.  iif(nModulo == 17 ,SY7->(DBSEEK(cFilSY7+AvKey("B","Y7_POGI")+AvKey(EG2->EG2_CODMEN,"Y7_COD"))), EE4->(DBSEEK(cFilEE4+AvKey(EG2->EG2_CODMEN,"EE4_COD"))))
            If nColObs > 0      
               aCols[i,nColOBS] := if(nModulo == 17 ,MSMM(SY7->Y7_TEXTO,60,1),MSMM(EE4->EE4_TEXTO,60,1))//MSMM(SY7->Y7_TEXTO,60,1)
            Endif
         EndIf
      //EndIf
      If lImpr   //Para impressão do Crystal
         DETAIL_P->(dbAppend())
         DETAIL_P->AVG_FILIAL := xFilial("SY0")
         DETAIL_P->AVG_SEQREL := cSeqRel
         DETAIL_P->AVG_C02_20 := ALLTRIM(SUBSTR(CdoW(EG2->EG2_DATA),1,3)) //Alcir Alves - 11-04-05                                         // Day
         DETAIL_P->AVG_C01_10 := DtoC(EG2->EG2_DATA)                                          // Date
         DETAIL_P->AVG_C02_10 := Left(EG2->EG2_FROM,2)                                        // From - H
         DETAIL_P->AVG_C03_10 := Right(EG2->EG2_FROM,2)                                       // From - M
         DETAIL_P->AVG_C04_10 := Left(EG2->EG2_TO,2)                                          // To - H
         DETAIL_P->AVG_C05_10 := Right(EG2->EG2_TO,2)                                         // To - M
         DETAIL_P->AVG_C03_20 := Left(EG2->EG2_TIMEUS,1)                                      // Time Used - D
         DETAIL_P->AVG_C04_20 := SubStr(EG2->EG2_TIMEUS,3,2)                                  // Time Used - H
         DETAIL_P->AVG_C05_20 := Right(EG2->EG2_TIMEUS,2)                                     // Time Used - M
         DETAIL_P->AVG_C06_20 := Trans(EG2->EG2_RATE,AVSX3("EG2_RATE",6))                     // Rate
         If lExistFret
            DETAIL_P->AVG_C02_60 := If (ALLTRIM(EG2->EG2_TP_LD) = "1","LOAD","DISCH") //Alcir Alves - 11-04-05
         EndIf   
         DETAIL_P->AVG_N01_04 := 3                                                            // Detalhe dos EG2
      
         If !Empty(EG2->EG2_CODMEN) .And.  iif(nModulo == 17 ,SY7->(DBSEEK(cFilSY7+AvKey("B","Y7_POGI")+AvKey(EG2->EG2_CODMEN,"Y7_COD"))), EE4->(DBSEEK(cFilEE4+AvKey(EG2->EG2_CODMEN,"EE4_COD"))))  // JWJ 11/11/09: Seek no SY7 estava faltando
            cRemark := ALLTRIM(if(nModulo == 17 ,MSMM(SY7->Y7_TEXTO,60,1),MSMM(EE4->EE4_TEXTO,60,1))) //+ " " + Alltrim(EG2->EG2_REMARKS)
         Else
            cRemark := Alltrim(EG2->EG2_REMARKS)
         EndIf
         DETAIL_P->AVG_C01_60 := cRemark //MemoLine(cRemark,41,1)                                       // Remarks
   
         For ni:=2 to MlCount(cRemark,41)
            DETAIL_P->(dbAppend())
            DETAIL_P->AVG_FILIAL := xFilial("SY0")
            DETAIL_P->AVG_SEQREL := cSeqRel
            DETAIL_P->AVG_C01_60 := MemoLine(cRemark,41,ni)                                   // Remarks
            DETAIL_P->AVG_N01_04 := 3                                                         // Detalhe dos EG2
            DETAIL_P->AVG_N01_15 := 1
         Next ni
   
         // Gravar Historico de Documentos
         DETAIL_H->(dbAppend())
         AvReplace("DETAIL_P","DETAIL_H")
      EndIf
      EG2->( DBSkip() )
   Enddo
   SY7->( DbSetOrder(1) )
EndIf
Return .t.

*---------------------------------------------------------------------------------------------------------------*
Function DM400Emis(PAlias, PReg, PnOpc)
*---------------------------------------------------------------------------------------------------------------*
Local aMeses:= {"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"}
Local i
Local cEmb  := "" //LRL 22/11/04
Private lSair := .F. //.T. MCF - 15/02/2015 //LRS - 03/02/2015
Private cSeqRel, cTimeAllowed, nTimeAllowed, nTot, nLostSavD, aCols, cHoraVazia, n:=1, cTimeUsed, cTimeLS
Private nParcVal, nContPag:=0 //nTot
Private dDtEmb // ACSJ - 22/02/2005 
If Select("HEADER_P") = 0
   E_ARQCRW(.T.,,.T.)
EndIf
SetFil()
cSEQREL := GetSXENum("SY0","Y0_SEQREL")
CONFIRMSX8()

//Grava cabeçalho e rodapé

HEADER_P->(dbAppend())
HEADER_P->AVG_FILIAL := xFilial("SY0")
HEADER_P->AVG_SEQREL := cSeqRel
If lExistDm
   HEADER_P->AVG_C30_60 := Alltrim(EG0->EG0_DEMURR)    
EndIF   
If lExistFret 
   HEADER_P->AVG_N02_15 := 1
EndIf   
If lMultiFil
   HEADER_P->AVG_N03_15 := 1
EndIf
HEADER_P->AVG_C01_20 := Alltrim(EG0->EG0_NAVIO)                      // M/V
HEADER_P->AVG_C01_30 := E_FIELD("EG0_DEST","Y9_DESCR",,,2)           // Disch. Port.
HEADER_P->AVG_C02_20 := aMeses[Month(EG0->EG0_DT_BOK)]+" "+StrZero(Day(EG0->EG0_DT_BOK),2)+"/"+Str(Year(EG0->EG0_DT_BOK),4)+"."  //Booking Note Dated  //TRP-20/06/08
HEADER_P->AVG_C03_20 := E_FIELD("EG0_FORNEC","A2_NREDUZ")            //Owners / Sellers
If !Empty(EG0->EG0_ROADS)
   HEADER_P->AVG_C01_10 := If(Upper(Left(CdoW(EG0->EG0_ROADS),2))<>"AS", Left(CdoW(EG0->EG0_ROADS),3)+".", Alltrim(CdoW(EG0->EG0_ROADS))) //Vsl Arvd on Roads
EndIf
HEADER_P->AVG_D01_08 := EG0->EG0_ROADS                               //Vsl Arvd on Roads
HEADER_P->AVG_C02_10 := Alltrim(EG0->EG0_ROADST)                     //Vsl Arvd on Roads
If !Empty(EG0->EG0_BERT)
   HEADER_P->AVG_C03_10 := If(Upper(Left(CdoW(EG0->EG0_BERT),2))<>"AS", Left(CdoW(EG0->EG0_BERT),3)+".", Alltrim(CdoW(EG0->EG0_BERT))) //Vessel Berthed
EndIf
HEADER_P->AVG_D02_08 := EG0->EG0_BERT                                //Vessel Berthed
HEADER_P->AVG_C04_10 := Alltrim(EG0->EG0_BERTT)                      //Vessel Berthed
If !Empty(EG0->EG0_TEND)
   HEADER_P->AVG_C05_10 := If(Upper(Left(CdoW(EG0->EG0_TEND),2))<>"AS", Left(CdoW(EG0->EG0_TEND),3)+".", Alltrim(CdoW(EG0->EG0_TEND))) //Notice Tendered
EndIf
HEADER_P->AVG_D03_08 := EG0->EG0_TEND                                //Notice Tendered
HEADER_P->AVG_C06_10 := Alltrim(EG0->EG0_TENDT)                      //Notice Tendered
If !Empty(EG0->EG0_ACCEP)
   HEADER_P->AVG_C07_10 := If(Upper(Left(CdoW(EG0->EG0_ACCEP),2))<>"AS", Left(CdoW(EG0->EG0_ACCEP),3)+".", Alltrim(CdoW(EG0->EG0_ACCEP))) //Notice Accepted
EndIf
HEADER_P->AVG_D04_08 := EG0->EG0_ACCEP                               //Notice Accepted
HEADER_P->AVG_C08_10 := Alltrim(EG0->EG0_ACCEPT)                     //Notice Accepted
If !Empty(EG0->EG0_FROM)
   HEADER_P->AVG_C09_10 := If(Upper(Left(CdoW(EG0->EG0_FROM),2))<>"AS", Left(CdoW(EG0->EG0_FROM),3)+".", Alltrim(CdoW(EG0->EG0_FROM))) //Time to count from
EndIf
HEADER_P->AVG_D05_08 := EG0->EG0_FROM                                //Time to count from
HEADER_P->AVG_C10_10 := Alltrim(EG0->EG0_FROMT)                      //Time to count from
If !Empty(EG0->EG0_COMM)
   HEADER_P->AVG_C04_20 := If(Upper(Left(CdoW(EG0->EG0_COMM),2))<>"AS", Left(CdoW(EG0->EG0_COMM),3)+".", Alltrim(CdoW(EG0->EG0_COMM))) //Disch. Commenced
EndIf
HEADER_P->AVG_D06_08 := EG0->EG0_COMM                                //Disch. Commenced
HEADER_P->AVG_C05_20 := Alltrim(EG0->EG0_COMMT)                      //Disch. Commenced
If !Empty(EG0->EG0_COMP)
   HEADER_P->AVG_C06_20 := If(Upper(Left(CdoW(EG0->EG0_COMP),2))<>"AS", Left(CdoW(EG0->EG0_COMP),3)+".", Alltrim(CdoW(EG0->EG0_COMP))) //Disch. Completed
EndIf                  
HEADER_P->AVG_D07_08 := EG0->EG0_COMP                                //Disch. Completed
HEADER_P->AVG_C07_20 := Alltrim(EG0->EG0_COMPT)                      //Disch. Completed
If lExistFret  //LRL 18/01/05
   If !Empty(EG0->EG0_TCFDT)
      HEADER_P->AVG_C13_60 := If(Upper(Left(CdoW(EG0->EG0_TCFDT),2))<>"AS", Left(CdoW(EG0->EG0_TCFDT),3)+".", Alltrim(CdoW(EG0->EG0_TCFDT)))
   EndIf
   HEADER_P->AVG_D08_08 := EG0->EG0_TCFDT                                
   HEADER_P->AVG_C14_60 := Alltrim(EG0->EG0_TCFTM)                      
EndIf

HEADER_P->AVG_C08_20 := Trans(EG0->EG0_CARGO,AVSX3("EG0_CARGO",6))   //Cargo Quantity
HEADER_P->AVG_C09_20 := Alltrim(Trans(EG0->EG0_RAT_LD,AVSX3("EG0_RAT_LD",6))) + If(EG0->EG0_RAT_HD $ "1 "," /Day"," /Hour") //Rate of load/disch.
HEADER_P->AVG_C10_20 := Alltrim(Trans(EG0->EG0_DEM_V,AVSX3("EG0_DEM_V",6)))  //Rate of Demurrage
HEADER_P->AVG_C11_20 := Alltrim(Trans(EG0->EG0_DES_V,AVSX3("EG0_DES_V",6)))  //Rate of Despatch
HEADER_P->AVG_C08_30 := EG0->EG0_MOEDA+" "+Alltrim(Trans(EG0->EG0_DEM_V,AVSX3("EG0_DEM_V",6))) + If(EG0->EG0_DEM_TP $ "1 "," /Day"," /Hour") //Rate of Demurrage
HEADER_P->AVG_C09_30 := EG0->EG0_MOEDA+" "+Alltrim(Trans(EG0->EG0_DES_V,AVSX3("EG0_DES_V",6))) + If(EG0->EG0_DES_TP $ "1 "," /Day"," /Hour") //Rate of Despatch
HEADER_P->AVG_C01_60 := Alltrim(EG0->EG0_COND)                       //Condition
HEADER_P->AVG_C32_60 := EG0->EG0_REVER                               //Reversível

SW8->(dbSetOrder(1))
EE9->(DBSetOrder(2))
EEC->(DBSetOrder(1))

//Grava os detalhes

DETAIL_P->(dbAppend())
DETAIL_P->AVG_FILIAL := xFilial("SY0")
DETAIL_P->AVG_SEQREL := cSeqRel
DETAIL_P->AVG_N01_04 := 4                               // Colunas de O/Ref e Products

 EG1->(dbSeek(xFilial("EG1")+EG0->EG0_MODULO+if(lExistDM,EG0->EG0_DEMURR,"") +EG0->EG0_NAVIO+EG0->EG0_VIAGEM+EG0->EG0_DEST)) //LRL 12/11/04 vide lExistDm

Do While !EG1->(EOF()) .and. EG1->EG1_FILIAL==xFilial("EG1") .and.;
   EG0->EG0_MODULO+if(lExistDM,EG0->EG0_DEMURR,"")+EG0->EG0_NAVIO+EG0->EG0_VIAGEM+EG0->EG0_DEST == EG1->EG1_MODULO+if(lExistDM,EG1->EG1_DEMURR,"")+EG1->EG1_NAVIO+EG1->EG1_VIAGEM+EG1->EG1_DEST
   DETAIL_P->(dbAppend())
   DETAIL_P->AVG_FILIAL := xFilial("SY0")
   DETAIL_P->AVG_SEQREL := cSeqRel
   DETAIL_P->AVG_N01_04 := 1                                  // Detalhe de O/Ref e Products
   If lExistDm 
      If  cEmb <> EG1->EG1_EMBARQ
         DETAIL_P->AVG_C02_60 := Alltrim(EG1->EG1_EMBARQ)           // O/Ref
         cEmb:=EG1->EG1_EMBARQ 
         If lMultifil          
            DETAIL_P->AVG_C05_60 := Alltrim(EG1->EG1_FILORI)         //Filial Origem
         EndIF
      EndIF   
   Else
      DETAIL_P->AVG_C02_60 := Alltrim(EG1->EG1_EMBARQ)
   EndIF
   If !lExistDm  //LRL 22/11/04
      If EG0->EG0_MODULO == "I"                                      //Importação 
         SW6->(DBSeek(cFilSW6+AVKey(EG1->EG1_EMBARQ,"W6_HAWB")))
         DETAIL_P->AVG_C03_60 := E_FIELD("W6_DEST","Y9_DESCR",,,2)  // Disch. Port.
         
         dDtEmb := SW6->W6_DT_EMB
         if EasyEntryPoint("AVGDM400")
            ExecBlock("AVGDM400",.F.,.F.,"DATA_DO_EMBARQUE")  
         Endif
         
         HEADER_P->AVG_C20_60 := DtoC(dDtEmb)  //Alcir -29-01-05 - data de conhecimento do embarque
                                               //ACSJ Revisão - Quando existir o campo W6_BL_DT sera usado este campo,
                                               //ACSJ Revisão - caso contrário será usado W6_DT_EMB. - 22/02/2005
                                         
         If SW8->(dbSeek(xFilial("SW8")+AvKey(EG1->EG1_EMBARQ,"W8_HAWB")))
            SB1->(dbSeek(xFilial("SB1")+SW8->W8_COD_I))
            DETAIL_P->AVG_C04_60 := Alltrim(SB1->B1_DESC)        // Product
            SW8->(dbSkip())
            Do While !SW8->(EOF()) .and. SW8->W8_FILIAL == xFilial("SW8") .and. SW8->W8_HAWB == AvKey(EG1->EG1_EMBARQ,"W8_HAWB")
               SB1->(dbSeek(xFilial("SB1")+SW8->W8_COD_I))
               DETAIL_P->(dbAppend())
               DETAIL_P->AVG_FILIAL := xFilial("SY0")
               DETAIL_P->AVG_SEQREL := cSeqRel
               DETAIL_P->AVG_N01_04 := 1                         // Detalhe de O/Ref e Products
               DETAIL_P->AVG_C04_60 := Alltrim(SB1->B1_DESC)     // Product
               SW8->(dbSkip())
            EndDo
         EndIf
      Else                                                          //Exportação
         EEC->(DBSeek(cFilEEC+AVKey(EG1->EG1_EMBARQ,"EEC_PREEMB")))
         DETAIL_P->AVG_C03_60 := E_FIELD("EEC_DEST","Y9_DESCR",,,2) // Disch. Port.
         HEADER_P->AVG_C20_60 := DtoC(EEC->EEC_DTCONH) //Alcir -29-01-05 - data de conhecimento do embarque
                                                       //ACSJ Revisão - 22/02/2005 - Campo Caracterer. OK
         
         DETAIL_P->AVG_C10_20 := E_FIELD("EEC_ORIGEM","Y9_DESCR",,,2) //Alcir -29-01-05 - Load Port

         If EE9->(DBSeek(cFilEE9+AVKey(EG1->EG1_EMBARQ,"EE9_PREEMB")))
            SB1->(dbSeek(xFilial("SB1")+EE9->EE9_COD_I))
            DETAIL_P->AVG_C04_60 := Alltrim(SB1->B1_DESC)           // Product
            EE9->(dbSkip())
            Do While !EE9->(EOF()) .And. cFilEE9 = EE9->EE9_FILIAL .And. EE9->EE9_PREEMB = AVKey(EG1->EG1_EMBARQ,"EE9_PREEMB")
               DETAIL_P->(dbAppend())
               DETAIL_P->AVG_FILIAL := xFilial("SY0")
               DETAIL_P->AVG_SEQREL := cSeqRel
               DETAIL_P->AVG_N01_04 := 1                            // Detalhe de O/Ref e Products
               SB1->(dbSeek(xFilial("SB1")+EE9->EE9_COD_I))
               DETAIL_P->AVG_C04_60 := Alltrim(SB1->B1_DESC)           // Product
               EE9->(DBSKIP())
            EndDo
         Endif
      EndIf
   Else       
      DETAIL_P->AVG_C03_60 := E_FIELD("EG1_DEST","Y9_DESCR",,,2)  // Disch. Port.
 
      //Alcir - 29-01-05
      //Begincomm
      IF EG0->EG0_MODULO == "I"                                  //Importação      
         IF SW6->(DBSeek(cFilSW6+AVKey(EG1->EG1_EMBARQ,"W6_HAWB")))
                          
         dDtEmb := SW6->W6_DT_EMB
         if EasyEntryPoint("AVGDM400")
            ExecBlock("AVGDM400",.F.,.F.,"DATA_DO_EMBARQUE")  
         Endif
         
         HEADER_P->AVG_C20_60 := DtoC(dDtEmb)  //Alcir -29-01-05 - data de conhecimento do embarque
                                               //ACSJ Revisão - Quando existir o campo W6_BL_DT sera usado este campo,
                                               //ACSJ Revisão - caso contrário será usado W6_DT_EMB. - 22/02/2005
                                    
         ENDIF
      ELSE
         IF EEC->(DBSeek(cFilEEC+AVKey(EG1->EG1_EMBARQ,"EEC_PREEMB")))
            HEADER_P->AVG_C20_60 := DtoC(EEC->EEC_DTCONH) //Alcir -29-01-05 - data de conhecimento do embarque
                                                          // Revisado por ACSJ em 21/02/2005 - Campo Caracterer                                                                                                 
            DETAIL_P->AVG_C10_20 := E_FIELD("EEC_ORIGEM","Y9_DESCR",,,2) //Alcir -29-01-05 - Load Port
         ENDIF
      ENDIF
      //endcomm
      
      SB1->(dbSeek(xFilial("SB1")+EG1->EG1_COD_I))
      DETAIL_P->AVG_C04_60 := Alltrim(SB1->B1_DESC)        // Product
   EndIF
   EG1->(dbSkip())
EndDo

DETAIL_P->(dbAppend())
DETAIL_P->AVG_FILIAL := xFilial("SY0")
DETAIL_P->AVG_SEQREL := cSeqRel
DETAIL_P->AVG_N01_04 := 2                               // Detalhe de colunas do EG2

DBSelectArea("EG0")
For i := 1 to EG0->( FCount() )
   M->&( FieldName(i) ) := EG0->&( FieldName(i) )
Next            
M->EG0_VM_OBS := MSMM( EG0->EG0_OBS, AVSX3("EG0_VM_OBS",4) )

//DM400EG2(.T.)

aHeader := {}
aCols   := {}

FillGetDados(PnOpc, "EG2", 1, "", {|| "" }, {|| .T. }, /*aNoFields*/, aYesFields, , /*cQuery*/, {|| DM400EG2(.T.), IncaCols(PnOpc) }, /*lInclui*/,,,,, {|| SetHeaderPos() } )

DM400Allowed(EG0->EG0_CARGO,EG0->EG0_RAT_LD,EG0->EG0_RAT_HD,.F.)
DM400LnOk(.F.,.F.)

nParcVal := (EG0->EG0_PARC_C / EG0->EG0_CARGO) * nTot

// Rodapé
If nLostSavD < 0     // Despatch
   HEADER_P->AVG_N01_04 := 1
ElseIF nLostSavD > 0 // Demurrage
   HEADER_P->AVG_N01_04 := 2
Else                 // No Despatch / No Demurrage
   HEADER_P->AVG_N01_04 := 3
EndIf
HEADER_P->AVG_C12_20 := Left(cTimeAllowed,2)                         // Time Allowed - D    
HEADER_P->AVG_C13_20 := SubStr(cTimeAllowed,4,2)                     // Time Allowed - H    
HEADER_P->AVG_C14_20 := Right(cTimeAllowed,2)                        // Time Allowed - M    
If lExistFret
   HEADER_P->AVG_C19_20 := Left(EG0->EG0_NOR,2)                         // Notice of Readiness - D    
   HEADER_P->AVG_C20_20 := SubStr(EG0->EG0_NOR,4,2)                     // Notice of Readiness - H    
   HEADER_P->AVG_C21_20 := Right(EG0->EG0_NOR,2)                        // Notice of Readiness - M    
EndIf

HEADER_P->AVG_C15_20 := Left(cTimeUsed,2)                            // Time Used - D
HEADER_P->AVG_C16_20 := SubStr(cTimeUsed,4,2)                        // Time Used - H
HEADER_P->AVG_C17_20 := Right(cTimeUsed,2)                           // Time Used - M
HEADER_P->AVG_C18_20 := Left(cTimeLS,2)                              // Time Lost/Saved - D
HEADER_P->AVG_C02_30 := SubStr(cTimeLS,4,2)                          // Time Lost/Saved - H
HEADER_P->AVG_C03_30 := Right(cTimeLS,2)                             // Time Lost/Saved - M
HEADER_P->AVG_C04_30 := Trans(nTot,AVSX3("EG0_DEM_V",6))             // Total Depatch/Demurrage
If EG0->EG0_DES_TP == "2"       // --- Horas 
   HEADER_P->AVG_C07_30 := Trans(EG0->EG0_TEMPO,"@E 99,999,999.99999999") + " /Hrs"   //Tempo em Horas
Else
   HEADER_P->AVG_C07_30 := Trans(EG0->EG0_TEMPO,"@E 99,999,999.99999999") + " /Days"  //Tempo em Dias
EndIf
HEADER_P->AVG_C05_30 := Trans(EG0->EG0_PARC_C,AVSX3("EG0_PARC_C",6)) //Hydro´s Cargo In
HEADER_P->AVG_C06_30 := Trans(nParcVal,AVSX3("EG0_DEM_V",6))         //Hydro´s Parcel

//AAF - 08/07/04
HEADER_P->AVG_C10_60 := STR0118//"Cargo in Value"
HEADER_P->AVG_C11_60 := STR0119//"Parcel Value"
if nLostSavD > 0
   HEADER_P->AVG_C12_60 := STR0120//"Time Lost"
elseif nLostSavD < 0
   HEADER_P->AVG_C12_60 := STR0121//"Time Saved"
endif
                       
If EasyEntryPoint("AVGDM400")                       
   ExecBlock("AVGDM400",.F.,.F.,"IMPRESSAOCRYSTAL")
EndIf

If lSair   //LRS - 03/02/2015  - Caso o Ponto de entrada preencher a váriavel lSair como .T., não será impresso o resto do relatorio.
   Return .T. 
EndIf

// Gravar Historico de Documentos
HEADER_H->(dbAppend())
AvReplace("HEADER_P","HEADER_H")

AvgCrw32("DEMURRAGE.RPT","Demurrage / Despatch")

E_HISTDOC(,"Demurrage / Despatch",dDataBase,,,"DEMURRAGE.RPT",cSeqrel)

EE9->(DBSetOrder(2))

Return .T.

*-----------------------------------------*
//LRL 16/07/04 
Function Dm400F3MS //Chamado do SXB, XB_ALIAS = 'MEB'
*-----------------------------------------*
Local cAlias, bWhile 
Local cNomeArq
Local oGetMS, oDlg
Local nOK:=0 
Private aHeader	:= {}
Private aEstru := {}
Private aCampos	
Aadd(aHeader, { STR0128  , "COD", "@!", 15, 0,"" ,nil,"C",nil,nil} ) //"Codigo  "
Aadd(aHeader, { STR0129  , "MEN", "@!", 60, 0,"",nil,"C",nil,nil} )  //"Menssagem  "
Aadd(aEstru,{"COD","C",15 ,0  })
Aadd(aEstru,{"MEN","C",60,0  }) 
cNomeArq :=E_CriaTrab(,aEstru,"WORK")
aCampos:=Array(len(aEstru))
If nModulo == 17 //Importação
   cAlias := "SY7"
   SY7->(DbSetOrder(3)) // Y7_FILIAL+Y7_POGI+Y7_COD
   bWhile := { || !SY7->(EOF()) .AND. SY7->Y7_FILIAL == cFilSY7 .AND. SY7->Y7_POGI == AvKey("B","Y7_POGI")  }
   SY7->(DbSeek(cFilSY7+AvKey("B","Y7_POGI")))//AAF - 23/08/04 - Posiciona na primeira mensagem para demurrage
Elseif nModulo == 29 //Exportação
   cAlias := "EE4"
   bWhile := { || !EE4->(EOF()) .AND. EE4->EE4_FILIAL == cFilEE4   }
   EE4->(DbSeek(cFilEE4))
EndIf                                                                      	

DbSelectArea(cAlias)
While Eval(bWhile )
   IF nModulo == 29 .AND. EE4_TIPMEN != "B" 
      (cAlias)->(DbSkip())
      Loop
   EndIf
   RecLock("WORK",.T.)
   WORK->COD := if(nModulo == 17 ,SY7->Y7_COD,EE4->EE4_COD)
   WORK->MEN := if(nModulo == 17 ,MSMM(SY7->Y7_TEXTO,60),MSMM(EE4->EE4_TEXTO,60))
   WORK->(MsUnlock())
   (cAlias)->(DbSkip())
Enddo

DEFINE MSDIALOG oDlg TITLE STR0127 ;//"Mensagens"  
       FROM oMainWnd:nTop   +200,oMainWnd:nLeft +1 ;
       TO   oMainWnd:nBottom-100,oMainWnd:nRight-100 OF oMainWnd PIXEL
       oGETMS:=WORK->(MsGetDB():New(15,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2,1,"","","",.F.,,,.F.,,"WORK"))
       oGETMS:oBROWSE:BADD := {||.F.}
       // oGetMS:bAval({|| nOk:=1,oDlg:End()})
       oGetMS:oBrowse:bwhen:={||(dbSelectArea("WORK"),.t.)}
       oGetMS:oBrowse:BLDBLCLICK:={|| nOk:=1,oDlg:End()} //{||.T.} 
	   oGetMS:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

ACTIVATE MSDIALOG oDlg ON INIT (DM400Bar( oDlg, {|| nOk:=1,oDlg:End()}, {||oDlg:End()}, 1))  CENTERED
If nOk == 1  
   cDMF3RET:=WORK->COD    
Else
   cDMF3RET:=M->EG2_CODMEN
EndIf
Work->(DbCloseArea())
FErase(cNomeArq)
Return .T.

/*
Função    : DM400INS
Autor     : Lucas Rolim Rosa Lopes
Data      : 04/11/04
Descrição : Rotina de Insersão de Linhas na Get Dados
*/
Function DM400INS
Local i,dData,cHorato,cHoraFrom,cDiaSem ,cTpLd          
Local lMenor24 //:= (n+1 < Len(aCols) .and. Val(Left(aCols[n,nColTo],2)) < 24 .and.  aCols[ n, nColData ] < aCols[ n+1, nColData ])
Local lMaior00 := (n<>1 .and. (Val(Left(aCols[n,nColFrom],2))+Val(Right(aCols[n,nColFrom],2)) > 0) .and.  aCols[ n-1, nColData ] < aCols[ n, nColData ])
Local aAux:= {}                                                                                                            
lMenor24 := (n+1 < Len(aCols) .and. Val(Left(aCols[n,nColTo],2)) < 24 .and. ;
            ( aCols[ n, nColData ] < aCols[ n+1, nColData ] .or. ;
             ( aCols[ n, nColData ] == aCols[ n+1, nColData ] .and. Val(Left(aCols[n+1,nColFrom],2)+Right(aCols[n+1,nColFrom],2)) > Val(Left(aCols[n,nColTo],2)+Right(aCols[n,nColTo],2)))))   


If     oGet:oBrowse:Cargo != 1 //Nao Posicionado na GetDados
  Return .f.
EndIF
If  n <> Len(aCols)  .and.  aCols[n,nColTo] <> cHoraVazia ;
   .and. aCols[n,nColFrom] <> cHoraVazia .and. (lMenor24 .OR. lMaior00 )  .and. DM400LnOk(.T.,.F.)
   dData      := aCols[ n, nColData ]
   cDiaSem    := aCols[ n, nColDtSem ]
   If lExistFret
      cTpLd      := aCols[ n, nColTpLd ]
   EndIf   
   If lMenor24
      //cHoraTo    := if (aCols[ n+1, nColFrom ]== "00:00" , "24:00",aCols[ n+1, nColFrom ]) //"24:00"
      /*
      cHoraTo    := if (aCols[ n , nColData ] > aCols[ n+1, nColData ] .AND. aCols[ n+1, nColFrom ]!= "00:00",;
      if (aCols[ n+1, nColFrom ]== "00:00" , "24:00",aCols[ n+1, nColFrom ]),"24:00") //"24:00"
      */          
      
      //** AAF 17/02/05 - Correção de problema ao inserir linha, pois o time TO era sempre 24:00.
      cHoraTo := iIf( aCols[n+1,nColData] == aCols[n,nColData], aCols[n+1,nColFrom], "  :  " )
      //**
      cHoraFrom  := aCols[ n, nColTo ]
   Else
      dData      := aCols[ n, nColData ]
      cHoraFrom  := "00:00"
      cHoraTo    := aCols[ n, nColFrom ]
   EndIf   
   //Remove registros  em branco
   For i := 1 to Len(aCols)
   If aCols[ i, ( Len(aHeader) + 1 ) ] == .f. .and. ( aCols[ i, nColTo ] <> cHoraVazia .and. ;
                                                      aCols[ i, nColFrom ] <> cHoraVazia )
      Aadd(aAux,aCols[i])
   Endif
   Next
   aCols := aAux     
   //Insere nova linha
   Aadd( aCols,Array( Len(aHeader) + 1 ) )
   If lMenor24
      n++ 
   EndIF   
   AIns(aCols ,n)    
   aCols[n] := Array( Len(aHeader) + 1 ) 
   For i := 1 to Len(aHeader)    
      aCols[n, i] := iif( aHeader[i,2] == "OBS",Space(30),;
                         iif( aHeader[i,2] == "EG2_FROM" .or. aHeader[i,2] == "EG2_TO","  :  ",;
                             iif( aHeader[i,2] == "EG2_TIMEUS", " :  :  ", CriaVar(aHeader[i,2]) ) ) )
   Next                     
   aCols[ n , nColData ]        := dData
   aCols[ n , nColDtSem]        :=  cDiaSem 
   If lExistFret
      aCols[ n  ,nColTpLD ]     := cTpLd
   EndIf   
   aCols[ n , nColFrom ]        := cHoraFrom
   aCols[ n , nColTo ]          := cHoraTo
   aCols[ n , nColTimeUs ]      := "0:00:00"
   aCols[ n, Len(aHeader) + 1] := .f.     
   IncaCols()
   oGet:oBrowse:Refresh(.F.)
Else
MsGInfo (STR0135  +AVSX3("EG2_FROM",5) + STR0136  +AVSX3("EG2_TO",5) + STR0137 ) //"Só é possivel iserir linha quando houver espaço de tempo no dia e "  -" for maior que 00:00 ou " " for menor que 24:00 "
EndIf 
Return .t. 

/*
Função    : GRVWORKEG1  
Autor     : Lucas Rolim Rosa Lopes
Data      : 16/11/04
Descrição : Rotina de Gravação da Work com os dados gravados em EG1
*/
*-------------------------------*
FUNCTION GRVWORKEG1(cTipo)       
*-------------------------------*
                
RecLock("WORKPROC",.t.)        
WORKPROC->MARCA := cMArca
If lMultiFil
  WORKPROC->FILORI := EG1->EG1_FILORI
EndIf
WORKPROC->&(if(cTipo == "IMP","W8_HAWB"   ,"EE9_PREEMB"))   := EG1->EG1_EMBARQ
WORKPROC->&(if(cTipo == "IMP","W6_DEST"   ,"EE9_DEST"  ))   := EG1->EG1_DEST
WORKPROC->&(if(cTipo == "IMP","W8_INVOICE","EE9_NRINVO"))   := EG1->EG1_NRINVO
WORKPROC->&(if(cTipo == "IMP","W8_COD_I"  ,"EE9_COD_I" ))   := EG1->EG1_COD_I
WORKPROC->&(if(cTipo == "IMP","W8_QTDEMT" ,"EE9_QTDEMT"))   := EG1->EG1_QTDMT
WORKPROC->&(if(cTipo == "IMP","W8_QTDEUC" ,"EE9_QTDEUC"))   := EG1->EG1_QTDUC
WORKPROC->&(if(cTipo == "IMP","W8_UNID"   ,"EE9_UNIDAD"))   := EG1->EG1_UNMED
WORKPROC->&(if(cTipo == "IMP","W8_PO_NUM" ,"EE9_PEDIDO"))   := EG1->EG1_PEDIDO
WORKPROC->&(if(cTipo == "IMP","W8_POSICAO","EE9_SEQUEN"))   := EG1->EG1_SEQUEN
WORKPROC->EG1_COEF                                          := EG1->EG1_COEF  
WORKPROC->TRB_ALI_WT:= "SW8"
WORKPROC->TRB_REC_WT:= SW8->(Recno())
WORKPROC->( MSUnlock() )
Return .t.

/*
Função    : REPLACEEG1
Autor     : Lucas Rolim Rosa Lopes
Data      : 16/11/04
Descrição : Repassa os dados para o EG1
*/
*-------------------------------*
FUNCTION REPLACEEG1      
*-------------------------------*
EG1->EG1_FILIAL := cFilEG1
EG1->EG1_MODULO := EG0->EG0_MODULO
EG1->EG1_NAVIO  := EG0->EG0_NAVIO
EG1->EG1_VIAGEM := EG0->EG0_VIAGEM
EG1->EG1_DEST   := EG0->EG0_DEST
EG1->EG1_EMBARQ := iif(nModulo == 17,WORKPROC->W8_HAWB  , WORKPROC->EE9_PREEMB) 
If lExistDM //LRL 12/11/04
   EG1->EG1_DEMURR := EG0->EG0_DEMURR
   EG1->EG1_NRINVO := iif(nModulo == 17,WORKPROC->W8_INVOICE, WORKPROC->EE9_NRINVO)
   EG1->EG1_PEDIDO := iif(nModulo == 17,WORKPROC->W8_PO_NUM , WORKPROC->EE9_PEDIDO)
   EG1->EG1_SEQUEN := iif(nModulo == 17,WORKPROC->W8_POSICAO, WORKPROC->EE9_SEQUEN)
   EG1->EG1_COD_I  := iif(nModulo == 17,WORKPROC->W8_COD_I  , WORKPROC->EE9_COD_I) 
   EG1->EG1_QTDUC  := iif(nModulo == 17,WORKPROC->W8_QTDEUC , WORKPROC->EE9_QTDEUC) 
   EG1->EG1_QTDMT  := iif(nModulo == 17,WORKPROC->W8_QTDEMT , WORKPROC->EE9_QTDEMT) 
   EG1->EG1_UNMED  := iif(nModulo == 17,WORKPROC->W8_UNID   , WORKPROC->EE9_UNIDAD) 
   EG1->EG1_COEF   := WORKPROC->EG1_COEF  //LRL 12/11/04
EndIF                                                  
If lExistFilORi  
   If lMultiFil
      EG1->EG1_FILORI:= WORKPROC->FILORI
   Else
      EG1->EG1_FILORI:= iif(nModulo == 17,cFilSW6,cFilEEC )    
   EndIf   
EndIf
         
                                       
Return .t.

/*
Função    : Dm400Marca
Autor     : Lucas Rolim Rosa Lopes
Data      : 16/11/04
Descrição : Marca e Desmarca
*/
*-------------------------------*
FUNCTION  Dm400Marca (nOpc)
*-------------------------------*
Local oDlg,oQtd,oMax
Local cCadastro := STR0138//"Quantidade neste Demurrage"
Local nQtd := Criavar("W8_QTDE")
Local nMax := Criavar("W8_QTDE")
Local lMarca:= If (WORKPROC->MARCA == cMarca,.F.,.T.)
Local lOk := .F.
Local nOrd1 := if (nModulo == 17 ,SW8->(IndexOrd()),EE9->(IndexOrd()))
Local nOrd2 := if (nModulo == 17 ,SW6->(IndexOrd()),EEC->(IndexOrd()))
Local nReg1 := if (nModulo == 17 ,SW8->(RecNo()),EE9->(RecNo()))
Local nReg2 := if (nModulo == 17 ,SW6->(RecNo()),EEC->(RecNo()))

//** AAF - 16/02/05
If Empty(if(nModulo==29,WORKPROC->EE9_QTDEMT,WORKPROC->W8_QTDEMT))
   MsgInfo(STR0168)//"Não é possivel converter o peso deste item para MT. Este Item não poderá ser utilizado."
   RETURN .F.
Endif
//**

If nOpc == 4 .or. nOpc == 3    
   If lMulTiFil 
      cFilEE9 := cFilEEC := If (lMultiFil,WORKPROC->FILORI,cFilEE9)   
      cFilSW8 := cFilSW6 := If (lMultiFil,WORKPROC->FILORI,cFilSW6)   
   EndIf
   If lExistFret .and. !Empty(M->EG0_CLIENT) .and. M->EG0_CLIENT != if (nModulo == 17,;
       AvKey(Posicione("SW6",1,cFilSW6+AvKeY(WORKPROC->W8_HAWB   ,"W6_HAWB")   ,"W6_IMPORT") ,"W6_IMPORT"),;
       AvKey(if(Posicione("EEC",1,cFilEEC+AvKeY(WORKPROC->EE9_PREEMB,"EE9_PREEMB"),"EEC_INTERM")="1",EEC->&(cCpoCliOff),EEC->EEC_IMPORT),"EEC_IMPORT"))
      MsGInfo (STR0160) //"O Cliente do Processo diferente do cliente informado na capa"
      lMarca:= .F.
   EndIf   
   IF nModulo == 17
      SW8->(DbSetOrder(6))
      SW6->(DbSetOrder(1))
      SW8->(DBSeek(cFilSW8+AVKey(WORKPROC->W8_HAWB,"W8_HAWB")+AVKey(WORKPROC->W8_INVOICE,"W8_INVOICE")+;
           AVKey(WORKPROC->W8_PO_NUM,"W8_PO_NUM")+AVKey(WORKPROC->W8_POSICAO,"W8_POSICAO"))) 
      SW6->( DBSeek(cFilSW6+AVKey(WORKPROC->W8_HAWB,"W6_HAWB")) )
      nMax += SW8->W8_QTDE
      If nOpc == 4 
         nQtd -= Posicione("EG1",2,cFilEG1+"I"+M->EG0_DEMURR+AVKey(WORKPROC->W8_HAWB,"EG1_EMBARQ")+AVKey(WORKPROC->W8_INVOICE,"EG1_NRINVO")+;
                 AVKey(WORKPROC->W8_PO_NUM,"EG1_PEDIDO")+AVKey(WORKPROC->W8_POSICAO,"EG1_SEQUEN"),"EG1_QTDUC")
      EndIf
   Else
      EE9->(DbSetOrder(2))
      EEC->(DbSetOrder(1))
      EE9->( DBSeek(cFilEE9+AVKey(WORKPROC->EE9_PREEMB,"EE9_PREEMB")+AVKey(WORKPROC->EE9_PEDIDO,"EE9_PEDIDO")+AVKey(WORKPROC->EE9_SEQUEN,"EE9_SEQUEN")) ) 
      EEC->( DBSeek(cFilEEC+AVKey(WORKPROC->EE9_PREEMB,"EEC_PREEMB")) )
      nMax += EE9->EE9_SLDINI 
      If nOpc == 4 
         nQtd -=  Posicione("EG1",2,cFilEG1+"E"+M->EG0_DEMURR+AVKey(WORKPROC->EE9_PREEMB,"EG1_EMBARQ")+AVKey(WORKPROC->EE9_NRINVO,"EG1_NRINVO")+;
                 AVKey(WORKPROC->EE9_PEDIDO,"EG1_PEDIDO")+AVKey(WORKPROC->EE9_SEQUEN,"EG1_SEQUEN"),"EG1_QTDUC")
      EndIf
   EndIF
   nQtd += iIF(iIF(lExistFret,!Empty(M->EG0_CLIENT),.T.),DMQtdUsd(),0)//AAF 22/02/05 - Verifica campo Cliente
   if nQtd > 0 
      nMax :=  nMAx - nQtd
   EndIf 
   nQtd :=  nMAx   //AAF 19/02/05 - Quantidade sempre inicializada com a maxima disponivel.
   If lMarca
      DEFINE MSDIALOG oDlg TITLE cCadastro FROM 200,200 TO 370,600  OF oMainWnd PIXEL
      
         oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 22/07/2015
		  oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
		  
         @ 16,10 SAY STR0139 Of oPanel Pixel //"Quantidade"
         @ 16,80 MsGet oQtd  Var nQtd Size 60,6 Picture AVSX3("W8_QTDE",6) Of oPanel pixel 
         @ 32,10 SAY STR0140 Of oPanel Pixel //"Saldo para demurrage" 
         @ 32,80 MsGet oMax  Var nMax Size 60,6 Picture AVSX3("W8_QTDE",6)  When .F.  Of oPanel pixel
      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, {|| lOk:= .T. ,oDlg:End()}, {||oDlg:End()}) CENTERED
      If lOk 
         If nQtd > nMax  
            MsGInfo( STR0141 +AllTrim(Transform (nMax,AVSX3("W8_QTDE",6)))) //"O saldo para demurrage é de : "
            lOk := .F.
         ElseIf nQtd <= 0//AAF 17/02/05 - Não permite numeros negativos.
            MsGInfo(STR0174)//"Quantidade deve ser maior que zero"
            lOk:= .F.
         Else  
            IF nModulo == 17
               GRVWORKW8("SW6",nQtd,.F.)                       
            Else 
               GrvWorkEE9('EEC',nQtd,.F.)   
            EndIF              
         WORKPROC->MARCA := cMarca
         SetParcelC()
         EndIF      
      EndIf
   Else
      IF nModulo == 17
         GRVWORKW8("SW6",nMax,.F.)
      Else 
         GrvWorkEE9('EEC',nMax,.F.)
      EndIF            
      WORKPROC->MARCA := ""  
      SetParcelC()
   EndIF
   IF nModulo == 17
      SW8->(DbSetOrder(nORd1))
      SW6->(DbSetOrder(nORd2))
      SW8->(DbGoTo(nReg1))
      SW6->(DbGoTo(nReg2))
   Else 
      EE9->(DbSetOrder(nORd1))
      EEC->(DbSetOrder(nORd2))
      EE9->(DbGoTo(nReg1))
      EEC->(DbGoTo(nReg2))                       
   EndIF  
Else
   lOk := .F.
EndIF   
Return lOk
/*
Função    : DMQtdUsd 
Autor     : Lucas Rolim Rosa Lopes
Data      : 17/11/04
Descrição : Returna a quanto do item ja foi amarrarado ao demurge
Obs       : Saldo Disponivel para demurage = Quantidade da Invoice - Retorno
*/
*--------------------------------------------*
Function DMQtdUsd (cAlias)
*--------------------------------------------*
Local nQtd := 0
If nModulo == 17
   EG1->(DBSeek(cFilEG1+"I"))
   Do While !EG1->(EOF())
      If EG1->EG1_EMBARQ == AVKey(SW8->W8_HAWB,"EG1_EMBARQ") .AND. EG1->EG1_NRINVO ==  AVKey(SW8->W8_INVOICE,"EG1_NRINVO");
         .AND.  EG1->EG1_PEDIDO == AVKey(SW8->W8_PO_NUM,"EG1_PEDIDO") .AND.  EG1->EG1_SEQUEN == AVKey(SW8->W8_POSICAO,"EG1_SEQUEN")  ;
          .AND. If (lMultiFil,IF(EG1->EG1_FILORI == (cAlias)->W6_FILIAL,.T.,.F.),.T.)         
         nQTd += EG1->EG1_QTDUC
      EndIf  
    EG1->(DBSKIP())
    EndDo
Else
   aOrd := SaveOrd( {"EG0"} )
    EG1->(DBSeek(cFilEG1+"E"))
    Do While !EG1->(EOF())
       If EG1->EG1_EMBARQ == AVKey(EE9->EE9_PREEMB,"EG1_EMBARQ") .AND. EG1->EG1_NRINVO ==  AVKey(EEC->EEC_NRINVO,"EG1_NRINVO");
          .AND.  EG1->EG1_PEDIDO == AVKey(EE9->EE9_PEDIDO,"EG1_PEDIDO") .AND.  EG1->EG1_SEQUEN == AVKey(EE9->EE9_SEQUEN,"EG1_SEQUEN") ; 
          .AND. If (lMultiFil,IF(EG1->EG1_FILORI == (cAlias)->EEC_FILIAL,.T.,.F.),.T.)
         //** AAF 18/02/05 - Verifica se o demurrage é de cliente. Para demurrage de armador, não é necessario controlar saldo.
         EG0->( dbSetOrder(1) )
         EG0->( dbSeek(EG1->(EG1_FILIAL+"E"+EG1_DEMURR)) )
         If !Empty(EG0->EG0_CLIENT)
            nQTd += EG1->EG1_QTDUC
         Endif
         //**
      EndIf
    EG1->(DBSKIP())
    EndDo
   RestOrd(aOrd)
EndIF
Return nQTd 

/*
Função    : SetParcelC                                      
Autor     : Lucas Rolim Rosa Lopes
Data      : 18/11/04
Descrição : Ajusta Parcel Cargo e atualiza os Totais
*/

*------------------------------------*
Function SetParcelC                                      
*------------------------------------*
Local nOldRec := WORKPROC->(RecNO())
nParcelC:=0 
WORKPROC->(DbGoTop())
While WORKPROC->(!EOF())
   If WORKPROC->MARCA == cMarca   
      If nMOdulo == 17 //Importação
         nParcelC+= WORKPROC->W8_QTDEMT
      Else
         nParcelC+= WORKPROC->EE9_QTDEMT
      EndIF             
   EndIF   
   WORKPROC->(DbSkip())
EndDo
M->EG0_PARC_C:=nParcelC              
If M->EG0_CARGO < nParcelC //AAF 19/02/05 - Evita que a Carga total seja menor que a parcela.
   M->EG0_CARGO := nParcelC              
EndIf
DM400LnOk(.F.,.F.)
oGetPar:Refresh()
oGetParV:Refresh()           
WORKPROC->(DbGoTo(nOldRec))
Return .T.


/*
Função    : AddEmbarq
Autor     : Lucas Rolim Rosa Lopes
Data      : 19/11/04
Descrição : Adiciona um novo embarque a Work
*/
*------------------------------------*
Function AddEmbarq()
*------------------------------------*
Local oDlg,oEmb
Local cEmb:= CriaVar("EEC_PREEMB")
Local cCadastro := STR0142 //"Selecionar Embarque"                                                              
Local lOk := .F.  
Local lRet := .T.
Local bValid
Local nQtd := 0
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 200,200 TO /*280*/ 360,600  OF oMainWnd PIXEL    //*** GFP 02/08/2011 - Alterado tamanho de janela - M11.5
		  
		  oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 22/07/2015
		  oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
		  
         @ 20,10 SAY STR0143 Of oPanel Pixel //"Embarque" 
         If nModulo == 17 //Importação
            @ 20,60 MsGet cEmb  F3 "SW6" Size 80,6 Picture AVSX3("W6_HAWB",6) Of oPanel pixel HASBUTTON
            bValid := {||NAOVAZIO(cEmb) .AND. AVGEXISTCPO("SW6",AvKeY(cEmb,"W6_HAWB"))}
         Else
            @ 20,60 MsGet cEmb F3 "EEC" Size 80,6 Picture AVSX3("EEC_PREEMB",6) Of oPanel pixel HASBUTTON
            bValid :={||NAOVAZIO(cEmb) .AND. AVGEXISTCPO("EEC",AvKeY(cEmb,"EEC_PREEMB")) }
         EndIF   
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, {|| lOk:= .T. ,oDlg:End() }, {||oDlg:End()}) CENTERED
If lOk
  If !Eval(bValid)
     lRet := .F.
  EndIf                                                                                                                                                        
  If lExistFret .and. !Empty(M->EG0_CLIENT) .and. M->EG0_CLIENT != if (nModulo == 17,AvKey(Posicione("SW6",1,cFilSW6+AvKeY(cEmb,"W6_HAWB"),"W6_IMPORT"),"W6_IMPORT"),AvKey(if(Posicione("EEC",1,cFilEEC+AvKeY(cEmb,"EE9_PREEMB"),"EEC_INTERM")="1",EEC->&(cCpoCliOff),EEC->EEC_IMPORT),"EEC_IMPORT"))
      MsGInfo(STR0183)//"O Cliente do Processo diferente do cliente informado na capa"
      lRet := .F.
  EndIf   
  /*
  If WORKPROC->(DbSeek(if (nModulo == 17,AvKeY(cEmb,"W8_HAWB"),AvKeY(cEmb,"EE9_PREEMB")))) 
     MsGInfo (STR0144)//"Embarque ja selecionado"
     lRet := .F.
  EndIf  
  */
  If  nModulo == 17 
      If !SW8->( DBSeek(cFilSW8+AVKey(cEmb,"W8_HAWB")) )
         MsGInfo (STR0145)//"Não existe invoice para este embarque"
         lRet := .F.
      EndIf
      If lRet .AND. SW6->( DBSeek(cFilSW6+AVKey(cEmb,"W6_HAWB")) ) 
         IF Empty(SW6->W6_DT_EMB) //.AND. Empty(SW6->W6_DT_ENCE)
            MsGInfo (STR0146)//"Processo não tem data de embarque"
            lRet := .F.
         ElseIf M->EG0_REVER <> "1" .AND. SW6->W6_DEST <> M->EG0_DEST
            MsGInfo (STR0147)//"Para incluir embarque com o porto destino  diferente o demurrage tem que ser reversivel"
            lRet := .F.
         Else  
           If M->EG0_NAVIO <> SW6->W6_IDENTVE  .AND. If (lCpoViagem,Eval({|| M->EG0_VIAGEM <> SW6->W6_VIAGEM}),.T.) ;
                 .AND. MsGYEsNO(STR0148) //"Navio e viagem do processo de embarque diferente do processo de demurrage. Deseja corrigir o processo de embarque"
              RecLock ("SW6",.F.)       
              SW6->W6_IDENTVE := M->EG0_NAVIO                                                                      
              If (lCpoViagem,Eval({||  SW6->W6_VIAGEM:= M->EG0_VIAGEM}),.T.)
              SW6->(MsUnlock())
           EndIF
           Do While ! SW8->(EOF()) .And. cFilSW8 = SW8->W8_FILIAL .And. SW8->W8_HAWB = AVKey(cEmb,"W8_HAWB")
               nQtd:=DMQtdUsd("SW6")
               If  nQTd < SW8->W8_QTDE
                  GrvWorkW8('SW6',SW8->W8_QTDE - nQTd)
               Else
                  MsgInfo(STR0184)//"Não há saldo para inclusão deste item."
               EndIF
               SW8->(DBSKIP())
            EndDo                    
         EndIf   
      EndIf  
  Else
     EE9->(DbSetOrder(2))
     If !EE9->( DBSeek(cFilEE9+AVKey(cEmb,"EE9_PREEMB")) ) 
         MsGInfo (STR0145)//"Não existe invoice para este embarque"
         lRet := .F.
     EndIF               
     EE9->(DbSetOrder(1))
     If lRet .AND. EEC->( DBSeek(cFilEEC+AVKey(cEmb,"EEC_PREEMB")) ) //.AND. !EMPTY(EEC->EEC_DTEMBA)
        If M->EG0_REVER <> "1" .AND. EEC->EEC_DEST <> M->EG0_DEST
            MsGInfo (STR0147)//"Para incluir portos diferentes o demurrage tem que ser reversivel"
            lRet := .F.
        Else    
           If M->EG0_NAVIO <> EEC->EEC_EMBARC  .AND. M->EG0_VIAGEM <> EEC->EEC_VIAGEM ;
              .AND. MsGYEsNO(STR0148) //"Navio e viagem do processo de embarque diferente do processo de demurrage. Deseja corrigir o processo de embarque"
              RecLock ("EEC",.F.)       
              EEC->EEC_EMBARC := M->EG0_NAVIO                                                                      
              EEC->EEC_VIAGEMW6_VIAGEM:= M->EG0_VIAGEM
              EEC->(MsUnlock())
           EndIF
           lIncluso := .F.

           Do While ! EE9->(EOF()) .And. cFilEE9 = EE9->EE9_FILIAL .And. EE9->EE9_PREEMB = AVKey(cEmb,"EE9_PREEMB")
              
              //AAF 16/02/05 - Verifica se o item já foi incluso.
              If ! WORKPROC->( dbSeek( EE9->EE9_PREEMB+EEC->EEC_NRINVO+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN ) )
                 nQtd:=DMQtdUsd()
                 If nQTd < EE9->EE9_SLDINI
                    GrvWorkEE9('EEC',EE9->EE9_SLDINI - nQTd)
                 Else
                    MsgInfo(STR0184)//"Não há saldo para inclusão deste item."
                 EndIF
                 lIncluso := .T.
              Endif

              EE9->(DBSKIP())
           EndDo

           //AAF 16/02/05 - Avisa o usuário.
           If !lIncluso
              MsgStop(STR0182)//"Os itens deste embarque já estão neste demurrage."
              lRet := .F.
           Endif
        EndIf   
     EndIf
  EndIF   
EndIf
WORKPROC->(DbGoTop())
Return lRet

/*
Função    : CopyDiario                 
Autor     : Lucas Rolim Rosa Lopes
Data      : 14/01/05
Descrição : Copia o Diario
*/
*------------------------------------*
Function CopyDiario                 
*------------------------------------*
Local dDtInicio, dDtFim , lRet , i 
Local OldAlias := Alias()
Local nRecEg2:= EG2->(RecNo())    
Local nRecSx3:= SX3->(Recno())
Local nOrdSx3:= SX3->(IndexOrd())
// AAF 19/02/05 - Já Existe um cMarca PRIVATE declarado. Variavel não pode ser redefinida. //Local cMarca := GetMark()
Local lMarca ,oDlg , oGet
Local lOk := .F.
Local nPos        
Local aAux := {} 
Local aBtn :=  {{"LBTIK",{|| MarkDiario() },"Marca/Desmarca Todos","Todos" }} 
Private oDlgA, oMsSel // AAF 21/02/05 - Variaveis devem ser private.
Private aDiario := {}                                  
Private cWorkDia     
Private aCposDia:= {}

If Empty(M->EG0_NAVIO) .or. Empty(M->EG0_VIAGEM)
  MsgInfo(Avsx3("EG0_NAVIO",5)+STR0162+Avsx3("EG0_VIAGEM",5)+ STR0163  ) //" e " - " devem estar preenchidos"            
  Return .F.
EndIf
If !Pergunte("DM400PE")
   Return .F.
EndIf     
SY7->(DBSETORDER(3))   
dDtInicio := mv_par01                               
dDtFim    := mv_par02
lRet :=E_Periodo_Ok(dDtInicio,dDtFim)
If lRet                     
   //Cria a WorkDia-----------------------------------------------------------------------------------
   SX3->( DBSetOrder(2) )   
   SX3->(DbSeek("EG2_DATA  "))
   SX3->( DBSetOrder(1) )   
   Aadd( aDiario,{ "MARCA"   , "C",2,0} )   
   Aadd( aDiario,{ "SUB"     , "C",1,0} )   
   Aadd( aDiario,{ "EG2_DEMURR", AVSX3("EG2_DEMURR",2),AVSX3("EG2_DEMURR",3),AVSX3("EG2_DEMURR",4)} ) //AAF 19/02/05 - Campo Código do Demurrage.
  
  //TRP - 01/02/07 - Campos do WalkThru
   AADD(aDiario,{"TRB_ALI_WT","C",03,0})
   AADD(aDiario,{"TRB_REC_WT","N",10,0})
  
   While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == "EG2"
      Aadd(  aDiario,{ ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,If (ALLTRIM(SX3->X3_CAMPO) = "EG2_TP_LD" ,8,SX3->X3_TAMANHO), SX3->X3_DECIMAL} ) 
      If ALLTRIM(SX3->X3_CAMPO) == "EG2_CODMEN"  
         Aadd(aDiario, { "OBS", "C", 30,0 } ) 
      EndIf
      SX3->(DbSkip())
   EndDo
   cWorkDia:=E_CriaTrab(,aDiario,"WORKDIA") 
   IndRegua("WORKDIA",cWorkDia+TEOrdBagExt(),"DTOS(EG2_DATA)+EG2_FROM")                                                               
   Aadd(aCposDia,{"MARCA"     ,,""})
   Aadd( aCposDia,{ {|| WORKDIA->EG2_DEMURR } , "" ,Avsx3("EG2_DEMURR",5)}) 
   Aadd( aCposDia,{ {|| WORKDIA->EG2_DATA   } , "" ,Avsx3("EG2_DATA"  ,5)}) 
   Aadd( aCposDia,{ {|| WORKDIA->EG2_DIASEM } , "" ,Avsx3("EG2_DIASEM",5)}) 
   Aadd( aCposDia,{ {|| WORKDIA->EG2_TP_LD  } , "" ,Avsx3("EG2_TP_LD" ,5)}) 
   Aadd( aCposDia,{ {|| WORKDIA->EG2_FROM }   , "" ,Avsx3("EG2_FROM"  ,5)}) 
   Aadd( aCposDia,{ {|| WORKDIA->EG2_TO }     , "" ,Avsx3("EG2_TO"    ,5)}) 
   Aadd( aCposDia,{ {|| WORKDIA->EG2_TIMEUS } , "" ,Avsx3("EG2_TIMEUS",5)})    
   Aadd( aCposDia,{ {|| WORKDIA->EG2_CODMEN } , "" ,Avsx3("EG2_CODMEN",5)})    
   Aadd( aCposDia,{ {|| WORKDIA->OBS    } , "" ,STR0005              })    //Observações 
   Aadd( aCposDia,{ {|| WORKDIA->EG2_REMARK } , "" ,Avsx3("EG2_REMARK",5)})    
  //-----------------------------------------------------------------------------------Cria a WorkDia
   EG2->(DBSeek(cFilEG0+if(nModulo == 17, "I","E"  ) ) ) 
   Do While EG2->(!EOF()) .AND. cFilEG0 == EG2->EG2_FILIAL .AND. if(nModulo == 17, "I","E"  ) == EG2->EG2_MODULO 
      If  M->EG0_NAVIO != EG2->EG2_NAVIO  .OR. M->EG0_VIAGEM != EG2->EG2_VIAGEM 
         EG2->(DbSkip())                            
         Loop
      EndIf
      If (!Empty(dDtInicio) .AND. dDtInicio > EG2->EG2_DATA ).OR. (!Empty(dDtFim) .AND. dDtFim < EG2->EG2_DATA )
         EG2->(DbSkip())
         Loop
      EndIF
      //** AAF 19/02/05 - Controle do Fretador.
      If (nModulo == 29 .AND. ( M->EG0_FRETE == "2"   .AND. EG2->EG2_TP_LD == "2" ) ) .OR.; //Não permite descarga se não for fretador.
         (nModulo == 27 .AND. ( M->EG0_FRETE == "2"   .AND. EG2->EG2_TP_LD == "1" ) ) .OR.; //Não permite descarga se não for fretador.
         (!Empty(M->EG0_CLIENT) .AND. EG2->EG2_TP_LD == "1" )                               //Não permite carga se for demurrage para cliente.
         
         EG2->( dbSkip() )
         Loop
      EndIF
      //**
      
      
      //** AAF 19/02/05 - Verifica conflito com os periodos já adicionados na work.
      lMarca := .T.
      WORKDIA->( dbSeek(DTOS(EG2->EG2_DATA)) )
      Do While !WORKDIA->( EoF() ) .AND. WORKDIA->EG2_DATA == EG2->EG2_DATA  
         If !( EG2->EG2_FROM == EG2->EG2_TO .OR. WORKDIA->EG2_FROM == WORKDIA->EG2_TO)  .AND. (;     //LRL 09/08/2005
            ( DM400ValTime(EG2->EG2_FROM) >= DM400ValTime(WORKDIA->EG2_FROM) .AND. DM400ValTime(EG2->EG2_TO) <= DM400ValTime(WORKDIA->EG2_TO)   ) .OR.;
            ( DM400ValTime(EG2->EG2_FROM) <= DM400ValTime(WORKDIA->EG2_FROM) .AND. DM400ValTime(EG2->EG2_TO) >= DM400ValTime(WORKDIA->EG2_TO)   ) .OR.;
            ( DM400ValTime(EG2->EG2_FROM) <  DM400ValTime(WORKDIA->EG2_TO  ) .AND. DM400ValTime(EG2->EG2_TO) >= DM400ValTime(WORKDIA->EG2_TO)   ) .OR.;
            ( DM400ValTime(EG2->EG2_FROM) <= DM400ValTime(WORKDIA->EG2_FROM) .AND. DM400ValTime(EG2->EG2_TO) >  DM400ValTime(WORKDIA->EG2_FROM) ) )           
            WORKDIA->SUB := "S"
            lMarca := .F.
         Endif
         
         WORKDIA->( dbSkip() )
      EndDo
      //**
      
      If lMarca
         For i:= 1 To Len(aCols)
            If aCols[i,nColData] == EG2->EG2_DATA .And. !(;
               ( EG2->EG2_FROM <  aCols[i,nColFrom]  .AND.   EG2->EG2_TO <= aCols[i,nColFrom] .And. If (i>1 ,IF(aCols[i-1,nColTo] <= EG2->EG2_FROM,.T.,.F.),.T.) ) .or. ;
               ( EG2->EG2_FROM >= aCols[i,nColTo]  .and. if(Len(aCols) != i,;
               If((aCols[i+1,nColData]>aCols[i,nColData]).or.(EG2->EG2_TO <= aCols[i+1,nColFrom]),.T.,.F.),.T.)  );
                                                      )
               lMarca := .F.
            EndIf
            If !lMarca
               Exit
            EndIf   
         Next
      Endif
      
      RecLock("WORKDIA",.T.)
      WORKDIA->EG2_DEMURR := EG2->EG2_DEMURR
      WORKDIA->EG2_DATA   := EG2->EG2_DATA
      WORKDIA->EG2_DIASEM := CdoW(EG2->EG2_DATA)
      WORKDIA->EG2_TP_LD  := If (EG2->EG2_TP_LD = "1","Load","Discharge")
      WORKDIA->EG2_FROM   := EG2->EG2_FROM
      WORKDIA->EG2_TO     := EG2->EG2_TO
      WORKDIA->EG2_RATE   := EG2->EG2_RATE
      WORKDIA->EG2_TIMEUS := EG2->EG2_TIMEUS
      WORKDIA->EG2_CODMEN := EG2->EG2_CODMEN
      If !Empty(EG2->EG2_CODMEN) .And.  iif(nModulo == 17 ,SY7->(DBSEEK(cFilSY7+"B"+AvKey(EG2->EG2_CODMEN,"Y7_COD"))), EE4->(DBSEEK(cFilEE4+AvKey(EG2->EG2_CODMEN,"EE4_COD"))))
         WORKDIA->OBS := if(nModulo == 17 ,MSMM(SY7->Y7_TEXTO,60,1),MSMM(EE4->EE4_TEXTO,60,1))
      EndIf   
      WORKDIA->EG2_REMARK := EG2->EG2_REMARK
      WORKDIA->MARCA :=  If(lMarca,cMarca,"  ")
      WORKDIA->SUB   :=  If(lMarca,"N","S")
      WORKDIA->TRB_ALI_WT:= "EG2"
      WORKDIA->TRB_REC_WT:= EG2->(Recno())
      WORKDIA->(MsUnlock())
      EG2->(DbSkip())
   EndDo   
   WorkDia->(DbGoTop())
   DEFINE MSDIALOG oDlgA TITLE STR0177 FROM oMainWnd:nTop   +200,oMainWnd:nLeft +1  TO   oMainWnd:nBottom-100,oMainWnd:nRight-100 OF oMainWnd PIXEL //"Copia Diario"
      oMsSel:= MsSelect():New("WORKDIA","MARCA",,aCposDia,@lInvert,@cMarca,{15,1,(oDlgA:nClientHeight-6)/2,(oDlgA:nClientWidth-4)/2})
      oMsSel:bAval:={|| MarcaDia (cMarca)}
	  oMsSel:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   ACTIVATE MSDIALOG oDlgA ON INIT (DM400Bar( oDlgA, {||lOk:= .T. , oDlgA:End()}, {||oDlgA:End()}, 1,aBtn))  CENTERED //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   If lOk
      WORKDIA->(DbGoTop())
      If aCols[Len(aCols),nColTimeUs] <> " :  :  " .and.;
                 ( aCols[Len(aCols),nColTo] <> cHoraVazia .and. aCols[Len(aCols),nColTo] <> cHoraVazia )
         aCols[Len(aCols), ( Len(aHeader) + 1 ) ] := .t.
      EndIf
      Do While WORKDIA->(!EOF())
         If WORKDIA->MARCA == cMarca
            If WORKDIA->SUB == "S"
              nPos:=Len(aCols)
              Do While nPos > 0 
                 nPOs := AScan( aCols, {|x| x[nColData] == WORKDIA->EG2_DATA .And. x[nColFROM] >= WORKDIA->EG2_FROM .AND. x[nColTo] <= WORKDIA->EG2_TO .AND. x[Len(aHeader)+ 1] = .F. } )
                 If nPos > 0
                   aCols[nPos, ( Len(aHeader) + 1 ) ] := .t.
                 EndIf
              EndDo
            EndIf
            Aadd( aCols,Array( Len(aHeader) + 1 ) )
            nPos := Len(aCols)
            aCols[nPos,nColTpLD  ] := IF(Left(WORKDIA->EG2_TP_LD,1 )== "L","1","2")
            aCols[nPos,nColRate  ] := WORKDIA->EG2_RATE
            aCols[nPos,nColFrom  ] := WORKDIA->EG2_FROM
            aCols[nPos,nColTo    ] := WORKDIA->EG2_TO
            aCols[nPos,nColData  ] := WORKDIA->EG2_DATA
            aCols[nPos,nColDtSem ] := WORKDIA->EG2_DIASEM
            aCols[nPos,nColTimeUs] := WORKDIA->EG2_TIMEUS
            aCols[nPos,nColCodMen] := WORKDIA->EG2_CODMEN
            aCols[nPos,nColOBS   ] := WORKDIA->OBS
            aCols[nPos,nColRemark] := WORKDIA->EG2_REMARK 
            aCols[Len(aCols), ( Len(aHeader) + 1 ) ] := .f.        
         EndIf   
         WORKDIA->(DbSkip())
      EndDo
      For i := 1 to Len(aCols)
         If aCols[ i, ( Len(aHeader) + 1 ) ] == .f. .and. ( aCols[ i, nColTo ] <> cHoraVazia .and. ;
                                                      aCols[ i, nColFrom ] <> cHoraVazia )
            Aadd(aAux,aCols[i])
         Endif
      Next
      aCols := aAux     
      Asort(aCols,,, { |x,y| DTOS(x[nColData]) + x[nColFrom] < DTOS(y[nColData]) + y[nColFrom] })
      IncaCols()
      DM400LnOK() //AAF 21/02/05 - 
   EndIf
   WORKDIA->(dbCloseArea())
   FErase(cWorkDia)
EndIf      
EG2->(DbGoTo(nRecEg2))
SX3->(DbSetOrder(nOrdSX3))
SX3->(DbGoTo(nRecSx3))
DbSelectArea(OldAlias)
Return lRet

/*
Função    : MarcaDia
Autor     : Lucas Rolim Rosa Lopes
Data      : 14/01/05
Descrição : Copia o Diario
*/
*------------------------------------*
Function MarcaDia(cMarca)                 
*------------------------------------*
Local nRec,nFrom,nTo //AAF 19/02/05
Local lMarcar := .F. //AAF 19/02/05
If  WORKDIA->MARCA == cMarca  
  WORKDIA->MARCA:= ""
  lMarcar := .T. //AAF 19/02/05
Else 
   If (WORKDIA->SUB  = "S" .AND.  MsgNoYes( STR0152 + ;//"Já existe um periodo entre : "
       DTOC(WORKDIA->EG2_DATA) +" - " + WORKDIA->EG2_FROM + " - " + WORKDIA->EG2_TO + ;
       STR0153 ))  .OR.  WORKDIA->SUB  = "N"//" .Deseja subistitui-lo ?"
      WORKDIA->MARCA:= cMarca
      lMarcar := .T. //AAF 19/02/05
   EndIf   
EndIf
//** AAF 19/02/05 - Verifica conflito com os periodos já adicionados na work.      
If lMarcar
   nRec     := WORKDIA->( RecNo() )
   nFrom    := DM400ValTime(WORKDIA->EG2_FROM)
   nTo      := DM400ValTime(WORKDIA->EG2_TO)
   dDia     := WORKDIA->EG2_DATA
   lDesmarca:= Empty(WORKDIA->MARCA)
   
   WORKDIA->( dbSeek(DTOS(dDia)) )
   Do While !WORKDIA->( EoF() ) .AND. WORKDIA->EG2_DATA == dDia
      If nRec <> WORKDIA->( RecNo() ) .AND.;
         ( ( nFrom >= DM400ValTime(WORKDIA->EG2_FROM) .AND. nTo <= DM400ValTime(WORKDIA->EG2_TO)   ) .OR.;
           ( nFrom <= DM400ValTime(WORKDIA->EG2_FROM) .AND. nTo >= DM400ValTime(WORKDIA->EG2_TO)   ) .OR.;
           ( nFrom <  DM400ValTime(WORKDIA->EG2_TO  ) .AND. nTo >= DM400ValTime(WORKDIA->EG2_TO)   ) .OR.;
           ( nFrom <= DM400ValTime(WORKDIA->EG2_FROM) .AND. nTo >  DM400ValTime(WORKDIA->EG2_FROM) ) )
         
         If !lDesmarca   
            WORKDIA->MARCA := ""
            WORKDIA->SUB := "S"
         Else
            WORKDIA->SUB := "N"
         Endif
      Endif
       
      WORKDIA->( dbSkip() )
   EndDo
      
   WORKDIA->( dbGoTo(nRec) )
   oMsSel:oBrowse:Refresh()
Endif
//**
Return .T.

/*
Função    : ValidaPro
Autor     : Lucas Rolim Rosa Lopes
Data      : 14/01/05
Descrição : Valida Processos
*/
*------------------------------------*
Function ValidaPro
*------------------------------------*
Local lRet := .T.
Local nRec := WORKPROC->(RecNo())
WORKPROC->(DbGoTop())
If !Empty(M->EG0_CLIENT) .and. !(WORKPROC->(EOF()) .AND. WORKPROC->(BOF()))
   Do While WORKPROC->(!EOF())  
       If WORKPROC->MARCA == cMarca
          If nModulo == 17 //Import
             SW6->(DBSeek(cFilSW6+AVKey(WORKPROC->W8_HAWB,"W6_HAWB")))
             If SW6->W6_IMPORT != M->EG0_CLIENT
                lRet := .f.
             EndIf
          Else 
             EEC->(DBSeek(cFilEEC+AVKey(WORKPROC->EE9_PREEMB,"EEC_PREEMB")))
             If EEC->EEC_INTERM == "1"
                If EEC->&(cCpoCliOff) != M->EG0_CLIENT
                   lRet := .f.
                EndIf
             Else     
                If EEC->EEC_IMPORT != M->EG0_CLIENT
                   lRet := .f.
                EndIf
             EndIf   
          EndIf  
          If !lRet
             Exit
          EndIf   
       EndIf          
       WORKPROC->(DbSkip())
    EndDo
EndIf  
WORKPROC->(DbGoTo(nRec))
Return lRet

//AAF 19/02/05 - Função não é mais necessária.
/*
Função    : ValTipoLd
Autor     : Lucas Rolim Rosa Lopes
Data      : 17/01/05
Descrição : Valida se só Tipo Load ou Tipo Carga
*------------------------------------*
Function ValTipoLD
*------------------------------------*
Local lRet := .T.
Local i 
Local cTipo 
If Len(aCols) > 1
  cTipo := aCols[1,nCOlTpLD]
  For i:= 1 to Len(aCols)
    If cTipo != aCols[i,nCOlTpLD] 
       lRet:= .F.
     EndIf
     If !lRet
        Exit
     EndIf   
  Next
EndIf  
Return lRet
*/

/*
Função    : SetFil
Autor     : Lucas Rolim Rosa Lopes
Data      : 17/01/05
Descrição : Ajusta  as Filiais
*/
*------------------------------------*
Function SetFil
*------------------------------------*
cFilSx5 := xFilial("SX5")
cFilSw6 := xFilial("SW6")
cFilEE6 := xFilial("EE6")
cFilSY9 := xFilial("SY9")
cFilSA2 := xFilial("SA2")
cFilSYF := xFilial('SYF')
cFilSA1 := xFilial("SA1")
cFilSW8 := xFilial("SW8")
cFilEG0 := xFilial("EG0")
cFilEG1 := xFilial("EG1")
cFilEG2 := xFilial("EG2")
cFilSAH := xFilial("SAH")
cFilSW7 := xFilial("SW7")
cFilSY7 := xFilial('SY7')
cFilEEC := xFilial("EEC")
cFilEE9 := xFilial("EE9")
cFilEE4 := xFilial("EE4")
Return .T.

/*
Função    : Dm400ValTime()
Autor     : Alessandro Alves Ferreira
Data      : 19/02/05
Descrição : Retorna Tempo em minutos.
*/
*--------------------------*
Function Dm400ValTime(cTime)
*--------------------------*
Local nTime := 0

nTime := (Val(Left(cTime,2))*60)+Val(Right(cTime,2))

Return nTime

/*
Função    : MarkDiario()
Autor     : Lucas Rolim Rosa Lopes
Data      : 03/06/05
Descrição : Apresenta uma tela de selecao de marca/desmarcatodos
*/                                                              
*--------------------------*
Function MarkDiario()
*--------------------------*  
Local oDlg
Local cCadastro := "Marca/Desmarca Todos"
Local cText     := "Marca/Desmarca Todos"
Local oCmbMArk                          
Local cMark                                         
Local lOk := .F.
Local aMark := {}
Local lMarca :=.T.
Local lPvez  := .T.
Local nOldRec := WORKDIA->( RecNo() )  
Aadd( aMark , "1-Load") 
Aadd( aMark , "2-Discharge")
Aadd( aMark , "3-Marca Todos")
Aadd( aMark , "4-Desmarca Todos")
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 200,200 TO 270,550  OF oMainWnd PIXEL
         @ 20,08 SAY cText Of oDlg Pixel 
         @ 18,68 ComboBox oCmbMArk  Var cMark Items aMark Of oDlg Pixel Size 70,6  
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, {|| lOk:= .T. ,oDlg:End()}, {||oDlg:End()}) CENTERED
If lOk
  cMark := If (Left(cMark,1)=="1","L",If (Left(cMark,1)=="2","D",If (Left(cMark,1)=="3","M","T")) )
  WORKDIA->( DbGoTop() )  
  Do While WORKDIA->( !EOF() )
     Do Case  
        Case cMark == "L" 
          If Left(WORKDIA->EG2_TP_LD,1) = "L" 
             IF WORKDIA->SUB=="N" 
                WORKDIA->MARCA := cMarca
             EndIf
          Else                       
             WORKDIA->MARCA :=  ""
          EndIf
        Case cMark == "D" 
          If Left(WORKDIA->EG2_TP_LD,1) = "D" 
             IF WORKDIA->SUB=="N" 
                WORKDIA->MARCA := cMarca
             EndIf
          Else                       
             WORKDIA->MARCA :=  ""
          EndIf
        Case cMark == "M" 
          IF WORKDIA->SUB=="N" 
             WORKDIA->MARCA := cMarca
          EndIf
        Case cMark == "T" 
            WORKDIA->MARCA := ""
     EndCase  
     WORKDIA->( DbSkip() )
  EndDo                  
  WORKDIA->( DbGoTo(nOldRec) ) 
EndIF
Return .T.

*----------------------------*
Static Function SetHeaderPos()
*----------------------------*

// --- Acha as posicoes das coluna partindo do aHeader.
nColRate     := AScan( aHeader, {|x| Alltrim(x[2]) == "EG2_RATE"  } )
nColTo       := AScan( aHeader, {|x| Alltrim(x[2]) == "EG2_TO"    } )
nColFrom     := AScan( aHeader, {|x| Alltrim(x[2]) == "EG2_FROM"  } )
nColData     := AScan( aHeader, {|x| Alltrim(x[2]) == "EG2_DATA"  } )
nColDtSem    := AScan( aHeader, {|x| Alltrim(x[2]) == "EG2_DIASEM"} )
nColTimeUs   := AScan( aHeader, {|x| Alltrim(x[2]) == "EG2_TIMEUS"} )
nColCodMen   := AScan( aHeader, {|x| Alltrim(x[2]) == "EG2_CODMEN"} )
nColRemark   := AScan( aHeader, {|x| Alltrim(x[2]) == "EG2_REMARK"} )
nColOBS      := AScan( aHeader, {|x| Alltrim(x[2]) == "OBS"} )
If lExistFret                                        
   nColTpLD     := AScan( aHeader, {|x| Alltrim(x[2]) == "EG2_TP_LD"} )
EndIF

Return Nil
