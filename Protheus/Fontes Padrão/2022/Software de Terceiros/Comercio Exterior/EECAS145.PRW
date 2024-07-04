#INCLUDE "EECAS145.ch"
/*
Programa        : EECAS145()
Objetivo        : Manutencao de NCM integrado ao TecWin
Autor           : Heder M Oliveira
Data/Hora       : 03/12/98 13:44
Obs.            :
Revisão         : Clayton Fernandes - 29/03/2011
Obs             : Adaptação do Codigo para o padrão MVC
*/
#include "EEC.cH"

/*
Funcao		: EECAS145()
Parametros	: Nenhum
Retorno		: .T.
Objetivos	: Executar mbrowse
Autor		: Heder M Oliveira
Data/Hora	: 03/02/98 13:45
Revisao		:
Obs.		:
*/
Function EECAS145()

// EJA - 06/07/2017
// Passou a utilizar cadastro de NCM do módulo de importação,
// Pois possui todas as funcionalidades e está em MVC
Return EICA130()

    /*Local lRet:=.T.,cOldArea:=select()
    Local aOrd := SaveOrd("SX3",2)
    Private cCadastro:=AVTITCAD("SYD") //Oemtoansi("N.C.M./TEC")
	PRIVATE aMEMOS:={{"YD_TEXTO","YD_VM_TEXT"}}
    Private aRotina := MenuDef(ProcName())
 
    Begin Sequence
       IF SX3->(dbSeek("YD_TXTESP") .And. dbSeek("YD_VM_TESP"))
         aAdd(aMemos,{"YD_TXTESP","YD_VM_TESP"})
       Endif 
       mBrowse( 6, 1,22,75,"SYD")
    End Sequence
    RestOrd(aOrd)
    dbselectarea(cOldArea)
Return lRet*/
                               

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 24/01/07 - 11:29
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}
Local aRotina 
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))

   Do Case
      Case cOrigem $ "EECAS145"
           aRotina :=  { { STR0001   ,"AxPesqui"   , 0 , 1},; //"Pesquisar"
                         { STR0002   ,"AxVisual"   , 0 , 2},; //"Visualizar"
                         { STR0003   ,"AS145Inclui", 0 , 3},; //"Incluir"
                         { STR0004   ,"AxAltera"   , 0 , 4},; //"Alterar"
                         { STR0005   ,"AS145MANE"  , 0 , 5,3}}  //"Excluir"


           If EasyGParam("MV_TECWIN")
              Aadd(aRotina,{ "TecWin","AS145TEC",0,6,3})
           EndIf
             
           // P.E. utilizado para adicionar itens no Menu da mBrowse
           If EasyEntryPoint("EAS145MNU")
              aRotAdic := ExecBlock("EAS145MNU",.f.,.f.)
              If ValType(aRotAdic) == "A"
                 AEval(aRotAdic,{|x| AAdd(aRotina,x)})
              EndIf
           EndIf
        
      OtherWise
         aRotina := StaticCall(MATXATU,MENUDEF)
            
   End Case
Return aRotina

/*
Funcao		: AS145NSH()
Parametros	: Nenhum
Retorno		: .T.
Objetivos	: Manutencao de Naladi SH
Autor		: Heder M Oliveira
Data/Hora	: 07/05/99 15:18
Revisão     : Clayton Fernandes - 29/03/2011
Obs         : Adaptação do Codigo para o padrão MVC
*/
Function AS145NSH()
Local lRet:=.T.,cOldArea:=select()
If !EasyCallMVC("MVC_ASNSH145",1)//CRF

    Begin sequence
       lRET:=AXCADASTRO("SJ1",STR0006,"INTEGREF('SJ1')") //"NALADI S H"
    Endsequence
    dbselectarea(cOldArea)
EndIf    
Return lRet


/*
Funcao		: AS145NCC()
Parametros	: Nenhum
Retorno		: .T.
Objetivos	: Manutencao de Naladi Ncca
Autor		: Heder M Oliveira
Data/Hora	: 07/05/99 15:09
Revisão     : Clayton Fernandes - 29/03/2011
Obs         : Adaptação do Codigo para o padrão MVC
*/
Function AS145NCC()
    Local lRet:=.T.,cOldArea:=select()
    Private aMemos:={}  // By JPP - 27/10/2006 - 15:50 - Este array permite informar para a função axcadastro quais
                        // quais são os campos memos a serem tratados pela função exemplo: 
                        // aMemos:= {{Campo_Codigo_Memo, Campo_virtual}}
If !EasyCallMVC("MVC_AS145NCC",1) //CRF                       
    Begin sequence    
      If EasyEntryPoint("AS145NCC") // By JPP - 27/10/2006 - 15:50 - Ponto de entrada para customização de campos memo na função AxCadastro.
         ExecBlock("AS145NCC",.F.,.F.,"ANTES_AXCADASTRO")
      EndIf
      lRET:=AXCADASTRO("SJ2",STR0007) //"NALADI N C C A"
    Endsequence
    dbselectarea(cOldArea)   
EndIf    
Return lRet

/*
Funcao		: AS145ALA()
Parametros	: Nenhum
Retorno		: .T.
Objetivos	: Definir tipo de Cadastro
Autor		: Heder M Oliveira
Data/Hora	: 03/12/98 16:15
Revisao		:
Obs.		:
*/
Function AS145ALA()
    Local lRet:=.T.,cOldArea:=select()
    Begin sequence
		lRET:=AXCADASTRO("SJC",STR0008) //"ALADI"
    Endsequence
    dbselectarea(cOldArea)
Return lRet

/*
Funcao    : AS145MANE()
Parametros: Nenhum
Objetivos : Excluir um registro
Autor     : A.W.R.
Data/Hora : 12/08/99
Obs.      : quando todos os processo estiverem prontos, validar uso antes de deletar
*/
Function AS145MANE(cAlias,nReg,nOpc)

Local lRet:=.T.,cOldArea:=select(),nOldorder:=indexord()
Local oDlg1,nInc,nOpc1:=0,cNewtit

Begin sequence

  Private aTela[0][0],aGets[0]

  IF nOPC = 5 .AND. ! INTEGREF("SYD")
     BREAK
  ENDIF
  (cAlias)->(DBSETORDER(1))
     
  DBSELECTAREA(cAlias)

  For nInc := 1 TO (cALIAS)->(FCount())
     M->&((cAlias)->(FIELDNAME(nInc))) := (cALIAS)->(FIELDGET(nInc))
  Next nInc

  cNewTit:=cCadastro
  bOk:={||IF(Msgnoyes(OemtoAnsi(STR0009),Oemtoansi(STR0010)),; //"Confirma ExclusÆo?"###"Aten‡Æo"
          (nOpc1:=1,oDlg1:End()),) }

  DEFINE MSDIALOG oDlg1 TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
 
      EnChoice("SYD",,nOpc,,,,,PosDlg(oDlg1),{},3)

  ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,bOK,{||oDlg1:End()})
  
  If nOpc1 == 1
     (cAlias)->(DBGOTO(nReg))
     Reclock(cAlias,.F.)
     (cAlias)->(DBDELETE())
     (cAlias)->(MsUnlock())    
  EndIf
 
  dbselectarea(cOldArea)

  (cAlias)->(DBSETORDER(nOldorder))

End sequence

Return lRet

/*
Funcao    : AS145Inclui()
Parametros: Nenhum
Objetivos : Inclui uma NCM
Autor     : CAF
Data/Hora : 10/10/2000 10:07
Obs.      : 
*/
Function AS145Inclui(cAlias,nReg,nOpc)

Return AxInclui(cAlias,nReg,nOpc,,,,"ExistChav('SYD',M->YD_TEC+M->YD_EX_NCM+M->YD_EX_NBM)")
