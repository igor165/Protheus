#INCLUDE "EECAT145.ch"
/*
Programa        : EECAT145.PRW
Objetivo        : Permitir manutencao em divisao, grupo e familia de produtos
Autor           : Heder M Oliveira
Data/Hora       : 26/11/98 17:39
Obs.            : OC0467/98 - OS 1408/98
Revisão         : Clayton Fernandes - 29/03/2011
Obs             : Adaptação do Codigo para o padrão MVC
*/
#include "EEC.cH"
#DEFINE   Divisao  "1"
#DEFINE   Grupo    "2"
#DEFINE   Familia  "3"

/*
Funcao          : AT145DIV()
Parametros      : Nenhum
Retorno         : .T.
Objetivos       : Chamar AT145BROW com filtro para Divisao
Autor           : Heder M Oliveira
Data/Hora       : 26/11/98 17:43
Revisao         : CAF 07/06/99
Obs.            :              
Revisão         : CRF - 14/03/11 
Obs.            : Criação de validação para saber se as Funções para construção no padrão MVC estão compiladas. 

*/
Function AT145DIV()
    Local lRet:=.T.,cOldArea:=select()
    Private cQual:= Divisao  //TRP-08/01/08
    Begin sequence
   
   	// CRF - 14/03/11
   	//Verifica se existe a função MVC Compilada.
    If !EasyCallMVC("MVC_AT145DIV",1)
		lRet := AT145Brow("EEG",AVTITCAD("EEG"))//"Divisão de Produtos")
	EndIF
   
	Endsequence
    dbselectarea(cOldArea)
Return lRet

/*
Funcao          : AT145GRU()
Parametros      : Nenhum
Retorno         : .T.
Objetivos       : Chamar AT145BROW com filtro para Grupo
Autor           : Heder M Oliveira
Data/Hora       : 26/11/98 17:43
Revisao         : CAF 07/06/99
Obs.            :
*/
Function AT145GRU()
    Local lRet:=.T.,cOldArea:=select()
    Private cQual:= Grupo  //TRP-08/01/08
    Begin sequence
	
	// CRF - 14/03/11
	//Verifica se existe a função MVC Compilada.
	If !EasyCallMVC("MVC_AT145GRU",1)
	   lRet := AT145Brow("EEH",AVTITCAD("EEH"))//"Grupo de Produtos")
	EndIF
    Endsequence
    dbselectarea(cOldArea)
Return lRet

/*
Funcao          : AT145FAM()
Parametros      : Nenhum
Retorno         : .T.
Objetivos       : Chamar AT145BROW com filtro para Familia
Autor           : Heder M Oliveira
Data/Hora       : 26/11/98 17:43
Revisao         : CAF 07/06/99
Obs.            :
*/
Function AT145FAM(xAutoCab,xAutoItens,xAutoOpc)
    Local lRet:=.T.,cOldArea:=select()
	Local lExecAuto := xAutoCab <> NIL .And. xAutoOpc <> Nil
	Local lExcMVcAuto := .F.
	Private cQual:= Familia  //TRP-08/01/08
	Private aCapAuto := xAutoCab
    Private nOpcAuto := xAutoOpc

	Begin sequence
		
        // CRF - 14/03/11
		//Verifica se existe a função MVC Compilada.
		If (lExcMVcAuto := !EasyCallMVC("MVC_AT145FAM",1)) .And. !lExecAuto
		   lRet := AT145Brow("SYC",AVTITCAD("SYC")) //"Família de Produtos")
        ElseIf lExecAuto .And. lExcMVcAuto 
           EasyHelp("Rotina não habilitada para ExecAuto.","Aviso")
		EndIf
    
    End sequence
    dbselectarea(cOldArea)
Return lRet



/*
Funcao          : AT145BROW()
Parametros      : cAlias := Alias do arquivo
	              cTitle := Titulo do cadastro 
Retorno         : .T.
Objetivos       : Filtrar browse conforme tipo
Autor           : Heder M Oliveira
Data/Hora       : 26/11/98 17:52
Revisao         : CAF 07/06/99
Obs.            :
*/
Function AT145BROW(cAlias,cTitle)
    Local lRet:=.T.,cOldArea:=select()
    Private cCadastro := cTitle
    Private aRotina := MenuDef(ProcName(1))
    
    EEG->(dbSetOrder(1))
    EEH->(dbSetOrder(1))
    SYC->(dbSetOrder(1))                     
			 
    Begin sequence
       mBrowse( 6, 1,22,75,cAlias)
    End sequence
    
    dbselectarea(cOldArea)
Return lRet


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 23/01/07 - 13:41
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}
Local aRotina :=  { { STR0001, "AxPesqui" , 0 , 1},; //"Pesquisar"
			       { STR0002,  "AxVisual" , 0 , 2},; //"Visualizar"
			       { STR0003,  "AxInclui" , 0 , 3},; //"Incluir"
        		   { STR0004,  "AxAltera" , 0 , 4},; //"Alterar"
			       { STR0005,  "AT145MAN" , 0 , 5,3} } //"Excluir"
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))
			       
   // P.E. utilizado para adicionar itens no Menu da mBrowse
   Do case
      
      Case cOrigem $ "AT145DIV" //Divisão
           If EasyEntryPoint("E145DIVMNU")
              aRotAdic := ExecBlock("E145DIVMNU",.f.,.f.)
	       EndIf

      Case cOrigem $ "AT145GRU" //Grupo
           If EasyEntryPoint("E145GRUMNU")
              aRotAdic := ExecBlock("E145GRUMNU",.f.,.f.)
	       EndIf

      Case cOrigem $ "AT145FAM" // Família
           If EasyEntryPoint("E145FAMMNU")
              aRotAdic := ExecBlock("E145FAMMNU",.f.,.f.)
	       EndIf
   End Case

   If ValType(aRotAdic) == "A"
	     AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	  EndIf       

Return aRotina

/*
Funcao          : AT145MAN
Parametros      : cAlias:= alias arq.
			  nReg:=num.registro
			  nOpc:=opcao escolhida
Retorno         : .T.
Objetivos       : Manutencao com enchoice
Autor           : Heder M Oliveira
Data/Hora       : 27/11/98 09:17
Revisao         :
Obs.            :
*/
Function AT145MAN(cAlias,nReg,nOpc)

Local lRet:=.T., cOldArea:=select(), oDlg, nOpca, i

Private aGets[0], aTela[0][0]

Begin Sequence

   //TRP-08/01/08- Tratamento apenas para o cadastro de Familias.
   If cQual = Familia
      If cAlias == "SYC" .And. !InteGref(cAlias)
         Break
      EndIf
   Endif
   
   For i:=1 To (cAlias)->(FCount())
      (cAlias)->( M->&(FieldName(i)) := FieldGet(i) )
   Next
    
   bVal_OK:={||nOpca:=0,AT145MANE(cAlias,nReg),oDlg:End()}
   nOpca:=0

   DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

   EnChoice( cAlias, nReg, nOpc, , , , ,PosDlg(oDlg))

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||EVAL(bVal_OK)},{||nOpca:=0,oDlg:End()})

End Sequence    

(cAlias)->(DBGOTO(nReg))

dbselectarea(cOldArea)

Return lRet

/*
Funcao    : AT145MANE()
Parametros: Nenhum
Objetivos : Excluir um registro
Autor     : Heder M Oliveira
Data/Hora : 27/11/98 09:33
Obs.      : quando todos os processo estiverem prontos, validar uso antes de deletar
*/
Static Function AT145MANE(cAlias,nReg)
   Local lRet:=.T., cOldArea := Select(), nOldOrder := IndexOrd()
    
   Begin sequence
      If MsgNoYes(STR0006,STR0007) //"Confirma Exclusão?"###"Atenção"
      
         If cAlias == "EEG" // Exclusao da Divisao de Produtos
            EEH->(dbSetOrder(3))
            If EEH->(dbSeek(xFilial()+EEG->EEG_COD))
               Help(" ",1,"AVG0005007") //MsgStop("Registro usado para relacionar Grupo ! Exclusão não será efetuada.", "Atenção")
               lRet := .F.
               Break
            EndIf
         ElseIf cAlias == "EEH" // Exclusao de Grupo de Produtos
            SYC->(dbSetOrder(3))
            If SYC->(dbSeek(xFilial()+EEH->EEH_COD))
               Help(" ",1,"AVG0005008") //MsgStop("Registro usado para relacionar Família ! Exclusão não será efetuada.", "Atenção")
               lRet := .F.
               Break
            EndIf
         EndIf
	  
         (cAlias)->(DbGoTo(nReg))
         Reclock(cAlias,.F.)
         (cAlias)->(DbDelete())
         (cAlias)->(MsUnlock())    
      EndIf
   End Sequence
   DbSelectArea(cOldArea)
   (cAlias)->(DbSetOrder(nOldorder))
Return lRet

*------------------------------------------------------------------------*
* FIM DO PROGRAMA ECCAT145.PRW                                           *
*------------------------------------------------------------------------*
