//Alcir Alves - Revisão - 14-12-05 - Acerto do tamanho e posicionamento das janelas e objetos 
#INCLUDE "ECOBC400.CH"
#include "EEC.cH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função....: ECOBC400 Autor: Alessandro Alves Ferreira  Data: 25/08/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição.: Manutenção de bancos                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*******************
FUNCTION ECOBC400()
*******************

PRIVATE cCadastro := STR0001//"Bancos"
PRIVATE aRotina   := MenuDef()
PRIVATE cFilSA6 := xFILIAL("SA6")
PRIVATE cFilECI := xFILIAL("ECI")
PRIVATE cFilSX5 := xFILIAL("SX5")

SA6->( DbSetOrder(1) )//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
DbSelectArea("SA6")
//MBROWSE(0,0,0,0,"SA6")
MBROWSE(6,1,22,75,"SA6")
RETURN .T.

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 17/01/07 - 15:04
*/
Static Function MenuDef()
Local aRotAdic   
Local aRotina := {  { STR0002,"AxPesqui" , 0, 1 } , ;//"Pesquisar"
                    { STR0003,"BC400Manu", 0, 2 } , ;//"Visualizar"
                    { STR0004,"BC400Manu", 0, 3 } , ;//"Incluir"
                    { STR0005,"BC400Manu", 0, 4 } , ;//"Alterar"
                    { STR0006,"BC400Manu", 0, 5 } }//"Excluir"

//³ P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("CBC400MNU")
	aRotAdic := ExecBlock("CBC400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf
Return aRotina


***************************************
FUNCTION BC400Manu(alias, nRec, nTipo)
***************************************
Local i, i2, cQuery
PRIVATE lOK := .F.
PRIVATE nTip := nTipo

//Arrays para GetDados
PRIVATE aHeader := {}
PRIVATE aCols   := {}
PRIVATE aAlter  := {}

//Usada para gravar o Recno dos registros exibidos na GetDados
PRIVATE aRecn   := {}

//Arrays passadas para Enchoice
PRIVATE aTela[0][0]
PRIVATE aGets[0]

//Declara variaveis para Enchoice
for i := 1 to SA6->( FCount() )
   if nTipo == 3
      M->&( SA6->( FieldName(i) ) ) = CriaVar(SA6->( FieldName(i) ))
   else
      M->&( SA6->( FieldName(i) ) ) = SA6->( FieldGet(i) )
   endif
next

//Colunas da GetDados
//aAdd(aHeader,{AvSX3("ECI_CONTAB",5),"ECI_CONTAB",AvSX3("ECI_CONTAB",6),AvSX3("ECI_CONTAB",3),AvSX3("ECI_CONTAB",4),nil,nil,AvSX3("ECI_CONTAB",2),nil,nil } )
//AAF 20/12/04 - Adicionado o campo Tipo de Conta
aAdd(aHeader,{AvSX3("ECI_TPCONT",5),"ECI_TPCONT","@!",AvSX3("ECI_TPCONT",3)+3+Len(SX5->X5_DESCRI),0,nil,nil,"C",nil,nil } )
//aAdd(aHeader,{AvSX3("ECI_TPMODU",5),"ECI_TPMODU",AvSX3("ECI_TPMODU",6),AvSX3("ECI_TPMODU",3),AvSX3("ECI_TPMODU",4),nil,nil,AvSX3("ECI_TPMODU",2),nil,nil } )

//Colunas alteráveis
aAdd(aAlter, "ECI_CONTAB" )
If ECI->(FieldPos("ECI_PORTAD")) > 0 .And. ECI->(FieldPos("ECI_TPPORT")) > 0
   aAdd(aAlter, "ECI_PORTAD" )
   aAdd(aAlter, "ECI_TPPORT" )
EndIf

//Ler os modulos do SX5, da tabela CJ e C0, Ler os dados do ECI para o aCols
//BC400DADOS()
If ECI->(FieldPos("ECI_PORTAD")) > 0 .And. ECI->(FieldPos("ECI_TPPORT")) > 0
   aYesFields := { "ECI_CONTAB" ,;
                   "ECI_PORTAD" ,;
                   "ECI_TPPORT" ,;
                   "ECI_TPMODU"  }
   aOrdHeader := { "ECI_CONTAB" ,;
                   "ECI_PORTAD" ,;
                   "ECI_TPPORT" ,;
                   "ECI_TPCONT" ,;
                   "ECI_TPMODU"  }
Else
   aYesFields:=    {  "ECI_CONTAB" ,;
                      "ECI_TPMODU"   }
   aOrdHeader := { "ECI_CONTAB" ,;
                   "ECI_TPCONT" ,;
                   "ECI_TPMODU"  }
EndIf
                   

cSeek:= ""  
cWhile:= "" 
FillGetDados(nTip, "ECI", 2, /*cSeek*/,/*{||&cWhile}*/, {||.T.}, /*aNoFields */, aYesFields,,,{||BC400DADOS()},,,,{|aCols| AddAcols(aCols, nTip) },,{|a| OrdHeader(@a, aOrdHeader) })
aCols := aSort(aCols,NIL,NIL,&("{|X,Y| X["+Str(GDFieldPos("ECI_TPMODU"))+"]+X["+Str(GDFieldPos("ECI_TPCONT"))+"] < Y["+Str(GDFieldPos("ECI_TPMODU"))+"]+Y["+Str(GDFieldPos("ECI_TPCONT"))+"]}"))

//DEFINE MSDIALOG oDlg TITLE STR0001 FROM 8, 8 TO 425, 700 OF oMainWnd PIXEL//"Bancos"
DEFINE MSDIALOG oDlg TITLE STR0001 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

   //oEnch:=MsMGet():NEW("SA6",nRec, nTipo,nil,nil,nil,nil,{12, 0, 150, 347},nil)
   oEnch:=MsMGet():NEW("SA6",nRec, nTipo,nil,nil,nil,nil,PosDlgUp(oDlg),nil)
   oEnch:oBox:Align := CONTROL_ALIGN_TOP
   //oMSGD:= MsGetDados():New(151, 0, 208, 347, nTipo,nil,nil,nil,.T.,aAlter,nil,nil,5)
   oMSGD:= MsGetDados():New(PosDlgDown(oDlg)[1], PosDlgDown(oDlg)[2], PosDlgDown(oDlg)[3]-17, PosDlgDown(oDlg)[4], nTipo,nil,nil,nil,.T.,aAlter,nil,nil,5)
   oMSGD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| iif(BC400VLTD(),EVAL({ || If(nTipo <> 5 .OR. MsgYesNo(STR0007+M->A6_COD),(lOK:= .T.,oDlg:END()),.F.) }),.F.) }, {||lOK:= .F., oDlg:END()} ) CENTERED

if lOK
   if nTipo == 5

      If !ValidExc()
         Return .F.
      EndIf
      
      //Exclusão
      //if MsgYesNo(STR0007+M->A6_COD)//"Tem certeza que deseja excluir banco ? Código: "
         //Exclui Contas Contabeis
         ECI->( dbSetOrder(2) )
         ECI->( dbSeek(cFilECI+M->A6_COD+M->A6_AGENCIA+M->A6_NUMCON) )
         Do While !ECI->( EoF() ) .AND. ECI->ECI_FILIAL == cFilECI .AND. ECI->ECI_BANCOD == M->A6_COD .AND. ECI->ECI_AGENCI == M->A6_AGENCIA .AND. ECI->ECI_NUMCON == M->A6_NUMCON
            RecLock("ECI",.F.)
            ECI->( DBDelete() )
            ECI->( msunlock() )
            ECI->( DBSkip() )
         EndDo
         //Exclui Banco
         SA6->( dbSeek(cFilSA6+M->A6_COD+M->A6_AGENCIA+M->A6_NUMCON) )
         RecLock("SA6",.F.)
         SA6->( DBDelete() )
         SA6->( msunlock() )
      //endif

   elseif nTipo == 3 .OR. nTipo == 4
      //Inclusão/Alteração
      
      //Grava Banco
      RecLock("SA6",iif(nTipo == 3,.T.,.F.))
      For i2:= 1 to SA6->( FCount() )
         SA6->( FieldPut(i2, M->&(SA6->( FieldName(i2) ))) )
      Next
      SA6->A6_FILIAL := xFilial("SA6")
      SA6->( msUnlock())
      
      //Grava Contas Contabeis
      For i:= 1 to Len(aCols)
         If GDDeleted(i) //.OR. Empty(GDFieldGet("ECI_CONTAB",i))

            //Caso esteja marcado para deleção ou a conta contabil esteja vazia
            nPos:= aScan(aRecn, { |X| X[1] == i })
            if nPos > 0
               //Caso o registro esteja gravado no ECI, posiciona no registro e o deleta
               ECI->( DbGoTo(aRecn[nPos][2]) )
               RecLock("ECI", .F.)
               ECI->( DbDelete() )
               ECI->( MsUnLock() )
            endif

         Else

            //Se o registro estiver não gravado no ECI, grava num novo registro
            nPos:= aScan(aRecn, { |X| X[1] == i })
            if nPos == 0
               RecLock("ECI",.T.)
            else
               ECI->( DbGoto(aRecn[nPos][2]) )            
               RecLock("ECI",.F.)
            endif
            
            ECI->ECI_FILIAL := cFilECI
            ECI->ECI_BANCOD := M->A6_COD
            ECI->ECI_AGENCI := M->A6_AGENCIA//AAF 21/12/04 - Adicionado o campo Agencia do Banco
            ECI->ECI_NUMCON := M->A6_NUMCON //AAF 21/12/04 - Adicionado o campo Numero da Conta
            ECI->ECI_TPMODU := GDFieldGet("ECI_TPMODU" ,i)
            ECI->ECI_TPCONT := Left(GDFieldGet("ECI_TPCONT" ,i),1)//AAF 20/12/04 - Adicionado o campo Tipo de Conta
            ECI->ECI_CONTAB := GDFieldGet("ECI_CONTAB" ,i)
            If ECI->(FieldPos("ECI_PORTAD")) > 0 .And. ECI->(FieldPos("ECI_TPPORT")) > 0
               ECI->ECI_PORTAD := GDFieldGet("ECI_PORTAD" ,i)
               ECI->ECI_TPPORT := GDFieldGet("ECI_TPPORT" ,i)
            EndIf
            ECI->( MsUnLock() )
         Endif
      Next

   endif

   SA6->( DbCommit() )
   ECI->( DbCommit() )   
endif 

aCols:= {}
RETURN .T.

//Valida no OK
*********************
FUNCTION BC400VLTD()
*********************
Local lRet := .T.

//Verifica existencia desse código e prenchimento dos campos obrigatórios
if !ExistChav("SA6",M->A6_COD+M->A6_AGENCIA+M->A6_NUMCON) .or. !Obrigatorio(aGets,aTela)
   lRet := .F.
endif
// MPG - 26/10/2018 - VALIDAÇÃO PARA QUE NÃO PERMITA O CADASTRO DE UM BANCO COM AS MOEDAS DIFERENTES DE ACORDO COM MÓDULOS E PARÂMETROS
if EasyGParam("MV_EFF_FIN",,.F.) == .T.
      if SYF->( dbsetorder(1),dbseek(xfilial("SYF")+M->A6_MOEEASY) ) .and. M->A6_MOEDA <> SYF->YF_MOEFAT
            lRet := .F.
            msgstop("Os campos de moeda não podem estar diferentes um do outro.","Atenção")
      endif
endif

RETURN lRet

//Ler os modulos do SX5, da tabela CJ e C0, Ler os dados do ECI para o aCols
**********************
Function BC400DADOS()
**********************
Local nPosX5, cTpModu
Local lCpoPortador := ECI->(FieldPos("ECI_PORTAD")) > 0 .And. ECI->(FieldPos("ECI_TPPORT")) > 0

SX5->( dbSetOrder(1) )//X5_FILIAL+X5_TABELA+X5_CHAVE

If SX5->(dbSeek(xFilial("SX5")+"C0"+"A"))
   RecLock("SX5",.F.)
   SX5->(dbDelete())
   SX5->(MsUnLock())
EndIf

If lCpoPortador
   //Inclui linha em branco e inicializa os campos
   If (nPos := aScan(aCols,&("{|X| AllTrim(X["+Str(GDFieldPos("ECI_TPMODU"))+"])+Left(X["+Str(GDFieldPos("ECI_TPCONT"))+"],1) == 'EXPORT'+'A' }"))) == 0
      aAdd( aCols,Array( Len(aHeader) + 1 ) )
      GDFieldPut("ECI_TPMODU", "EXPORT"                                 , Len(aCols) )
      GDFieldPut("ECI_CONTAB", CriaVar("ECI_CONTAB")                   , Len(aCols) )
      If lCpoPortador
         GDFieldPut("ECI_PORTAD", CriaVar("ECI_PORTAD")                   , Len(aCols) )
         GDFieldPut("ECI_TPPORT", CriaVar("ECI_TPPORT")                   , Len(aCols) )
      EndIf
      aCols[Len(aCols)][Len(aHeader)+1] := .F. //Marca como não deletado
   Else
      nPos := Len(aCols)
   EndIf
   GDFieldPut("ECI_TPCONT", "A" + " - " + "COMP. ADIANT."           , Len(aCols) )
	  
   //Inclui linha em branco e inicializa os campos
   If (nPos := aScan(aCols,&("{|X| AllTrim(X["+Str(GDFieldPos("ECI_TPMODU"))+"])+Left(X["+Str(GDFieldPos("ECI_TPCONT"))+"],1) == 'EXPORT'+'B' }"))) == 0
      aAdd( aCols,Array( Len(aHeader) + 1 ) )
      GDFieldPut("ECI_TPMODU", "EXPORT"                                 , Len(aCols) )
      GDFieldPut("ECI_TPCONT", "B" + " - " + "INCLUSAO ADIANT."           , Len(aCols) )
      GDFieldPut("ECI_CONTAB", CriaVar("ECI_CONTAB")                   , Len(aCols) )
      If lCpoPortador
         GDFieldPut("ECI_PORTAD", CriaVar("ECI_PORTAD")                   , Len(aCols) )
         GDFieldPut("ECI_TPPORT", CriaVar("ECI_TPPORT")                   , Len(aCols) )
      EndIf
      aCols[Len(aCols)][Len(aHeader)+1] := .F. //Marca como não deletado
   Else
      nPos := Len(aCols)
   EndIf
   GDFieldPut("ECI_TPCONT", "B" + " - " + "INCLUSAO ADIANT."            , Len(aCols) )
EndIf

//Prenche o aCols com os tipos de modulo do SX5
SX5->( dbSetOrder(1) )//X5_FILIAL+X5_TABELA+X5_CHAVE
SX5->( dbSeek(cFilSX5+"CJ") )
Do While !SX5->( EoF() ) .AND. SX5->X5_FILIAL == cFilSX5 .AND. SX5->X5_TABELA == "CJ"
     
   If aScan(aCols,{|x| x[3] == SX5->X5_CHAVE}) > 0
      SX5->( dbSkip() )
      Loop
   Endif
     
   nPosX5 := SX5->( RecNo() )
   cTpModu:= SX5->X5_CHAVE
   SX5->(dbSeek(cFilSX5+"C0"))
   Do While !SX5->( EoF() ) .AND. SX5->( X5_FILIAL+X5_TABELA ) == cFilSX5+"C0"
      /*If AllTrim(Upper(SX5->X5_CHAVE)) == "A" .And. ((!AllTrim(Upper(cTpModu)) == "EXPORT"  .And. lCpoPortador) .Or. !lCpoPortador)
         SX5->( dbSkip() )
         Loop
      EndIf*/

      //Inclui linha em branco e inicializa os campos
      aAdd( aCols,Array( Len(aHeader) + 1 ) )
      GDFieldPut("ECI_TPMODU", cTpModu                                 , Len(aCols) )
      GDFieldPut("ECI_TPCONT", SX5->( Left(X5_CHAVE,1)+" - "+X5_DESCRI), Len(aCols) )
      GDFieldPut("ECI_CONTAB", CriaVar("ECI_CONTAB")                   , Len(aCols) )
      If lCpoPortador
         GDFieldPut("ECI_PORTAD", CriaVar("ECI_PORTAD")                   , Len(aCols) )
         GDFieldPut("ECI_TPPORT", CriaVar("ECI_TPPORT")                   , Len(aCols) )
      EndIf
      aCols[Len(aCols)][Len(aHeader)+1] := .F. //Marca como não deletado

      SX5->( dbSkip() )
   EndDo

   SX5->( dbGoTo(nPosX5) )
   SX5->( dbSkip() )
EndDo

if nTip <> 3
   //Joga os dados do ECI para a GetDados

   ECI->( dbSetOrder(2) )//ECI_FILIAL+ECI_BANCOD+ECI_AGENCI+ECI_NUMCON+ECI_TPMODU+ECI_TPCONT
   ECI->( dbSeek(cFILECI + M->A6_COD + M->A6_AGENCIA + M->A6_NUMCON ))

   Do While !ECI->( EoF() ) .AND. ECI->ECI_FILIAL == cFILECI .AND. ECI->ECI_BANCOD == M->A6_COD .AND. ECI->ECI_AGENCI == M->A6_AGENCIA .AND. ECI->ECI_NUMCON == M->A6_NUMCON

      nPos:= aScan(aCols,&("{|X| X["+Str(GDFieldPos("ECI_TPMODU"))+"]+AvKey(Left(X["+Str(GDFieldPos("ECI_TPCONT"))+"],1),'ECI_TPCONT') == ECI->ECI_TPMODU + ECI->ECI_TPCONT }"))
      
      If nPos > 0
         //Adiciona o Numero da Conta Contabil encontrado no ECI
         GDFieldPut("ECI_CONTAB", ECI->ECI_CONTAB, nPos)
         If lCpoPortador
            GDFieldPut("ECI_PORTAD", ECI->ECI_PORTAD,nPos)
            GDFieldPut("ECI_TPPORT", ECI->ECI_TPPORT,nPos)
         EndIf
         GDFieldPut("ECI_ALI_WT", "ECI", nPos)
         GDFieldPut("ECI_REC_WT", ECI->(Recno()), nPos)
         aAdd(aRecn,{ nPos, ECI->( RecNo() ) } )//Guarda RecNo
      Endif
      
      ECI->( DbSkip() )
   EndDo

Endif

Return .T.

//TRP- 16/02/07 - Adiciona campos de usuário no Acols
Static Function AddAcols(aCols, nOpc)

   aAdd(aCols[Len(aCols)], Nil)
   aIns(aCols[Len(aCols)], Len(aHeader) + 1)
   aCols[Len(aCols)][Len(aHeader) + 1] := If(nOpc <> 3 .Or. ECI->(Eof()), ECI->(Recno()), 0)

Return .T. 

Static Function ValidExc()
Local cQuery := ""
Local lRet := .T.

Begin Sequence
   /************ LINHA DE CRÉDITO ************/
   cQuery := "SELECT EFA_FILIAL, EFA_BANC, EFA_AGEN, EFA_NCON "
   cQuery += " FROM " + RetSqlName("EFA")
   cQuery += " WHERE D_E_L_E_T_ <> '*' AND EFA_FILIAL = '" + xFilial("EFA") + "' AND "
   cQuery += " EFA_BANC = '" + M->A6_COD + "' AND EFA_AGEN = '" + M->A6_AGENCIA + "' AND "
   cQuery += " EFA_NCON = '" + M->A6_NUMCON + "' "
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_EFA", .T., .T.)
   If !(WK_EFA->(Eof()) .AND. WK_EFA->(Bof()))
      EasyHelp(STR0008,STR0009)  //"Este registro não pode ser excluído, pois está em uso no cadastro de Linhas de Crédito." ## "Atenção"
      lRet := .F.
      Break
   EndIf
   
   /************ FORNECEDORES/CONSIGNATÁRIOS ************/
   cQuery := "SELECT A2_FILIAL, A2_BANCO, A2_AGENCIA, A2_NUMCON " 
   cQuery += " FROM " + RetSqlName("SA2")
   cQuery += " WHERE D_E_L_E_T_ <> '*' AND A2_FILIAL = '" + xFilial("SA2") + "' AND "
   cQuery += " A2_BANCO = '" + M->A6_COD + "' AND A2_AGENCIA = '" + M->A6_AGENCIA + "' AND "
   cQuery += " A2_NUMCON = '" + M->A6_NUMCON + "' "
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SA2", .T., .T.)
   If !(WK_SA2->(Eof()) .AND. WK_SA2->(Bof()))
      EasyHelp(STR0010,STR0009)  //"Este registro não pode ser excluído, pois está em uso no cadastro de Fornecedores/Consignatários." ## "Atenção"
      lRet := .F.
      Break
   EndIf
   
   /************ CLIENTES ************/
   cQuery := "SELECT A1_FILIAL, A1_BCO1, A1_BCO2, A1_BCO3, A1_BCO4, A1_BCO5 "
   cQuery += " FROM " + RetSqlName("SA1")
   cQuery += " WHERE D_E_L_E_T_ <> '*' AND A1_FILIAL = '" + xFilial("SA1") + "' AND "
   cQuery += " (A1_BCO1 = '" + M->A6_COD + "' OR A1_BCO2 = '" + M->A6_COD + "' OR "
   cQuery += " A1_BCO3 = '" + M->A6_COD + "' OR A1_BCO4 = '" + M->A6_COD + "' OR A1_BCO5 = '" + M->A6_COD + "') "
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SA1", .T., .T.)
   If !(WK_SA1->(Eof()) .AND. WK_SA1->(Bof()))
      EasyHelp(STR0011,STR0009)  //"Este registro não pode ser excluído, pois está em uso no cadastro de Clientes." ## "Atenção"
      lRet := .F.
      Break
   EndIf
   
   /************ EMPRESAS ************/
   cQuery := "SELECT Y5_FILIAL, Y5_BANCO, Y5_AGENCIA, Y5_CONTA "
   cQuery += " FROM " + RetSqlName("SY5")
   cQuery += " WHERE D_E_L_E_T_ <> '*' AND Y5_FILIAL = '" + xFilial("SY5") + "' AND "
   cQuery += " Y5_BANCO = '" + M->A6_COD + "' AND Y5_AGENCIA = '" + M->A6_AGENCIA + "' AND "
   cQuery += " Y5_CONTA = '" + M->A6_NUMCON + "' "
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SY5", .T., .T.)
   If !(WK_SY5->(Eof()) .AND. WK_SY5->(Bof()))
      EasyHelp(STR0012,STR0009)  //"Este registro não pode ser excluído, pois está em uso no cadastro de Empresas." ## "Atenção"
      lRet := .F.
      Break
   EndIf
   
   /************ PRÉ-VINCULAÇÃO ************/
   cQuery := "SELECT EF6_FILIAL, EF6_BANCO "
   cQuery += " FROM " + RetSqlName("EF6")
   cQuery += " WHERE D_E_L_E_T_ <> '*' AND EF6_FILIAL = '" + xFilial("EF6") + "' AND "
   cQuery += " EF6_BANCO = '" + M->A6_COD + "' "
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_EF6", .T., .T.)
   If !(WK_EF6->(Eof()) .AND. WK_EF6->(Bof()))
      EasyHelp(STR0013,STR0009)  //"Este registro não pode ser excluído, pois está em uso em uma Pré-Vinculação." ## "Atenção"
      lRet := .F.
      Break
   EndIf
   
   /************ CONTRATOS DE FINANCIAMENTO IMPORTAÇÃO/EXPORTAÇÃO ************/
   cQuery := "SELECT EF1_FILIAL, EF1_BAN_FI, EF1_AGENFI, EF1_NCONFI, EF1_BAN_MO, EF1_AGENMO, EF1_NCONMO "
   cQuery += " FROM " + RetSqlName("EF1")
   cQuery += " WHERE D_E_L_E_T_ <> '*' AND EF1_FILIAL = '" + xFilial("EF1") + "' AND "
   cQuery += " (EF1_BAN_FI = '" + M->A6_COD + "' AND EF1_AGENFI = '" + M->A6_AGENCIA + "' AND EF1_NCONFI = '" + M->A6_NUMCON + "') OR "
   cQuery += " (EF1_BAN_MO = '" + M->A6_COD + "' AND EF1_AGENMO = '" + M->A6_AGENCIA + "' AND EF1_NCONMO = '" + M->A6_NUMCON + "') "
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_EF1", .T., .T.)
   If !(WK_EF1->(Eof()) .AND. WK_EF1->(Bof()))
      EasyHelp(STR0014,STR0009)  //"Este registro não pode ser excluído, pois está em uso em um Contrato de Financiamento." ## "Atenção"
      lRet := .F.
      Break
   EndIf

   /************ CAMBIO DE IMPORTAÇÃO ************/
   cQuery := "SELECT WB_FILIAL, WB_BANCO, WB_AGENCIA, WB_CONTA "
   cQuery += " FROM " + RetSqlName("SWB")
   cQuery += " WHERE D_E_L_E_T_ <> '*' AND WB_FILIAL = '" + xFilial("SWB") + "' AND "
   cQuery += " WB_BANCO = '" + M->A6_COD + "' AND WB_AGENCIA = '" + M->A6_AGENCIA + "' AND "
   cQuery += " WB_CONTA = '" + M->A6_NUMCON + "' "
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SWB", .T., .T.)
   If !(WK_SWB->(Eof()) .AND. WK_SWB->(Bof()))
      EasyHelp(STR0015,STR0009)  //"Este registro não pode ser excluído, pois está em uso em um Câmbio de Importação." ## "Atenção"
      lRet := .F.
      Break
   EndIf
   
   /************ CAMBIO DE EXPORTAÇÃO ************/
   cQuery := "SELECT EEQ_FILIAL, EEQ_BANC, EEQ_AGEN, EEQ_NCON, EEQ_BCOEXT, EEQ_AGCEXT, EEQ_CNTEXT "
   cQuery += " FROM " + RetSqlName("EEQ")
   cQuery += " WHERE D_E_L_E_T_ <> '*' AND EEQ_FILIAL = '" + xFilial("SWB") + "' AND "
   cQuery += " (EEQ_BANC = '" + M->A6_COD + "' AND EEQ_AGEN = '" + M->A6_AGENCIA + "' AND EEQ_NCON = '" + M->A6_NUMCON + "') OR "
   cQuery += " (EEQ_BCOEXT = '" + M->A6_COD + "' AND EEQ_AGCEXT = '" + M->A6_AGENCIA + "' AND EEQ_CNTEXT = '" + M->A6_NUMCON + "') "
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_EEQ", .T., .T.)
   If !(WK_EEQ->(Eof()) .AND. WK_EEQ->(Bof()))
      EasyHelp(STR0016,STR0009)  //"Este registro não pode ser excluído, pois está em uso em um Câmbio de Exportação." ## "Atenção"
      lRet := .F.
      Break
   EndIf
   
   /************ CARTA DE CRÉDITO DE IMPORTAÇÃO ************/
   cQuery := "SELECT WC_FILIAL, WC_BANCO, WC_AGENCIA "
   cQuery += " FROM " + RetSqlName("SWC")
   cQuery += " WHERE D_E_L_E_T_ <> '*' AND WC_FILIAL = '" + xFilial("SWC") + "' AND "
   cQuery += " WC_BANCO = '" + M->A6_COD + "' AND WC_AGENCIA = '" + M->A6_AGENCIA + "' "
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SWC", .T., .T.)
   If !(WK_SWC->(Eof()) .AND. WK_SWC->(Bof()))
      EasyHelp(STR0017,STR0009)  //"Este registro não pode ser excluído, pois está em uso no cadastro de Cartas de Crédito." ## "Atenção"
      lRet := .F.
      Break
   EndIf
   
   /************ CARTA DE CRÉDITO DE EXPORTAÇÃO ************/
   cQuery := "SELECT EEL_FILIAL, EEL_BCOAV, EEL_AGCAV, EEL_BCOEM, EEL_AGCEM, EEL_BCOCON, EEL_AGCCON "
   cQuery += " FROM " + RetSqlName("EEL")
   cQuery += " WHERE D_E_L_E_T_ <> '*' AND EEL_FILIAL = '" + xFilial("EEL") + "' AND "
   cQuery += " (EEL_BCOAV = '" + M->A6_COD + "' AND EEL_AGCAV = '" + M->A6_AGENCIA + "') OR "
   cQuery += " (EEL_BCOEM = '" + M->A6_COD + "' AND EEL_AGCEM = '" + M->A6_AGENCIA + "') OR "
   cQuery += " (EEL_BCOCON = '" + M->A6_COD + "' AND EEL_AGCCON = '" + M->A6_AGENCIA + "') "
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_EEL", .T., .T.)
   If !(WK_EEL->(Eof()) .AND. WK_EEL->(Bof()))
      EasyHelp(STR0017,STR0009)  //"Este registro não pode ser excluído, pois está em uso no cadastro de Cartas de Crédito." ## "Atenção"
      lRet := .F.
      Break
   EndIf
End Sequence

If Select("WK_EFA") # 0
   WK_EFA->(DbCloseArea())
EndIf
If Select("WK_SA1") # 0
   WK_SA1->(DbCloseArea())
EndIf
If Select("WK_SA2") # 0
   WK_SA2->(DbCloseArea())
EndIf
If Select("WK_SY5") # 0
   WK_SY5->(DbCloseArea())
EndIf
If Select("WK_EF6") # 0
   WK_EF6->(DbCloseArea())
EndIf
If Select("WK_EF1") # 0
   WK_EF1->(DbCloseArea())
EndIf
If Select("WK_SWB") # 0
   WK_SWB->(DbCloseArea())
EndIf
If Select("WK_EEQ") # 0
   WK_EEQ->(DbCloseArea())
EndIf
If Select("WK_SWC") # 0
   WK_SWC->(DbCloseArea())
EndIf
If Select("WK_EEL") # 0
   WK_EEL->(DbCloseArea())
EndIf
Return lRet