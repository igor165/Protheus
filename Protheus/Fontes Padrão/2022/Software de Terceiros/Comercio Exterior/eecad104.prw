#Include "EEC.cH"
#Include "EECAD104.CH"

/*
Programa        : EECAD104.PRW
Objetivo        : Controlar a internação de recursos no exterior
Autor           : Rodrigo Mendes Diaz
Data/Hora       : 27/11/2007
Obs. 
*/

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Function EECAD104()
Local aOrd := SaveOrd({"EYV"})

Private aRotina := MenuDef()

Private cAlias  := "EYV",;
        cTitulo := STR0006 //"Manutenção de Câmbio Simultâneo"

mBrowse(6, 1, 22, 75, cAlias,,,,,,,,,,,,,, "EYV_TIPO = '2'")

RestOrd(aOrd, .F.)
Return Nil

/*
Funcao      : 
Parametros  : cAlias - Alias da tabela em que será feita a manutenção
              nReg - Recno do registro que será alterado
              nOpc - Indica o tipo de operação que será efetuada no registro
Retorno     : lOk
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 
Revisao     : 
Obs.        : 
*/

Function AD104MAN(cAlias, nReg, nOpc)
Local oDlg
Local bOk     := {|| If(lOk := (Obrigatorio(aGets,aTela) .And. AD103VLD("BOK")), oDlg:End(), )},;
      bCancel := {|| oDlg:End()}
Local lRet := .F.

Private lOk := .F.
Private aGets[0],aTela[0]
Private cProcOrigem:= "AD104MAN"

RegToMemory(cAlias, nOpc == INCLUIR)
If nOpc == INCLUIR
   M->EYV_TIPO := "2"//Câmbio Simultâneo
EndIf

Do While !lRet //AAF 27/02/08 - Não sair enquanto não gravar ou o usuário cancelar
   
   //** AAF 27/02/08 - Limpar aGets e aTela para serem carregados numa segunda execução da enchoice.
   aGets := {}
   aTela := {}
   lOk := .F. 
   //**
   
   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 350,636 OF oMainWnd PIXEL

      EnChoice(cAlias, nReg, nOpc,,,,GetCampos(nOpc),PosDlg(oDlg), GetCamposEdit(nOpc))

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If lOk
      BEGIN TRANSACTION
         
         Begin Sequence
            
            //ConfirmSx8()
                 
            If nOpc == INCLUIR
               If !(lRet := Ad103IntRec(.T.))
                  Break
               EndIf
            EndIf
                        
            If nOpc == EXCLUIR
               MsAguarde({|| lRet := Ad103EIntRec() }, STR0007, STR0008)//"Aguarde"###"Cancelando contratação de câmbio simultâneo"
               If !lRet
                  Break
               EndIf
            EndIf
   
            (cAlias)->(RecLock(cAlias, nOpc == INCLUIR))

            If nOpc == EXCLUIR
               (cAlias)->(DbDelete())
            Else
               AvReplace("M", cAlias)
            EndIf
            (cAlias)->(MsUnlock())
            
            ConfirmSx8() //AAF 27/02/08 - Confirma a sequencia somente com a gravação.
            lRet := .T.
         End Sequence
         
         If !lRet
            While __lSX8
               RollBackSX8()
            Enddo
         EndIf

      END TRANSACTION
   Else
      RollBackSxE()
      lRet := .T.
   EndIf
   
EndDo

Return lOk

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function GetCamposEdit(nOpc)
Local aCampos

  If nOpc == ALTERAR
     aCampos := {"EYV_RFBC", "EYV_CORR"}
                                            
     //OAP - 17/11/2010 - Inclusão de campos adicionados pelo usuário. Ao inserir tais campos em aCampos, permitimos sua alteração em nOpc == ALTERAR.
     aCampos := AddCpoUser(aCampos,"EYV","1")
     
  ElseIf nOpc <> INCLUIR
     aCampos := {}
  EndIf

Return aCampos

/*
Funcao      : 
Parametros  : 
Retorno     : aCampos
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 13/12/07
Revisao     : 
Obs.        : 
*/
Static Function GetCampos(nOpc)
Local aOrd := SaveOrd("SX3")
Local aCampos := {}
Local aCpoCambio := {"EYV_BCODES", "EYV_AGEDES", "EYV_CTADES", "EYV_NBCDES"}

   SX3->(DbSetOrder(1))
   SX3->(DbSeek("EYV"))
   While SX3->(!Eof() .And. X3_ARQUIVO == "EYV")
      If X3Uso(SX3->X3_USADO)
         aAdd(aCampos, SX3->X3_CAMPO)
      EndIf
      SX3->(DbSkip())
   EndDo
   
   aEval(aCpoCambio, {|x| If(aScan(aCampos, IncSpace(x, Len(SX3->X3_CAMPO), .F.)) == 0, aAdd(aCampos, IncSpace(x, Len(SX3->X3_CAMPO), .F.)), ) })

RestOrd(aOrd, .T.)
Return aCampos

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Retornar as definições de menu
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 24/10/07 - 11:00
*/
Static Function MenuDef()
Local aRotAdic
Local aRotina  := { { STR0001, "AxPesqui" , 0 , 1},;   //"Pesquisar"
                    { STR0002, "AD104MAN" , 0 , 2},;   //"Visualizar"
                    { STR0003, "AD104MAN" , 0 , 3},;   //"Incluir"
                    { STR0004, "AD104MAN" , 0 , 4},;   //"Alterar"
                    { STR0005, "AD104MAN" , 0 , 5,3}}  //"Cancelar"

Begin Sequence

   If EasyEntryPoint("EAD104MNU")
      aRotAdic := ExecBlock("EAD104MNU",.f.,.f.)
   EndIf

   If ValType(aRotAdic) == "A"
      aEval(aRotAdic,{|x| AAdd(aRotina,x)})
   EndIf

End Sequence

Return aRotina
