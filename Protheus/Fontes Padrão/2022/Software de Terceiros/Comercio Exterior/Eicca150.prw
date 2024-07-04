//Funcao    : EICA150  ³ Autor : Gilson Nascimento     ³ Data : 28/08/96 
//Descricao : Desembaraco - Consulta Adiantamento Despachantes           
//Sintaxe   : EICCA150()
//Uso       : SIGAEIC
#INCLUDE "Eicca150.ch"
//#include "FiveWin.ch"
#include "Average.ch"

// EOS - OS 625/02 - Funcao chamada somente pelo SCHEDULE passando p/ a funcao EICCA150
// um parametro como .T. identificando que é schedulado 
*--------------------------*
FUNCTION EICCA150S()
*--------------------------*
E_Init()
EICCA150(.T.)
RETURN NIL

*-----------------------------------------------------------------*
Function EICCA150(lSXD)
*-----------------------------------------------------------------*
PRIVATE aRotina := MenuDef()
PRIVATE lEMail:=!lSXD = Nil
PRIVATE cCadastro := OemtoAnsi(STR0004) //"Adiantamento Despachantes"
PRIVATE lDeleta   := .T.//Usada no EICFI400.PRW (cParamIXB == "PRESTACAO_DE_CONTAS_2")
PRIVATE dDataIni, dDataFim, nDespesa, nTipRel
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))

Private lEmailDespForn:= EasyGParam("MV_DESPFOR",,.F.)  //Envia email para o Fornecedor quando este parametro estiver ligado - RS 04/09/07

Private lAvIntFinEIC:= AvFlags("AVINT_FINANCEIRO_EIC") //TRP - 09/08/2012 - Verifica se utiliza Financeiro AvInteg
// EOS - aCampos - ATENCAO, na funcao CA150Cons abaixo, há essa mesma definicao
// no caso da rotina ser chamada pelo EICFI400. Caso altere esse array, nao se esqueca
// de alterar la embaixo tambem.
Private aCampos:={ { "DESP"     , "C" , 03 , 0 } ,;
	               { "NOME"     , "C" , 27 , 0 } ,;
	               { "REF"      , "C" , 10 , 0 } ,;
                   { "DOCTO"    , "C" , 10 , 0 } ,;
	               { "HAWB"     , "C" , AvSx3("W6_HAWB", AV_TAMANHO), 0 } ,;
	               { "DTHAWB"   , "D" ,  8 , 0 } ,;
	               { "DATA_DI"  , "D" ,  8 , 0 } ,;
	               { "PO_NUM"   , "C" , AvSx3("W2_PO_NUM", AV_TAMANHO) , 0 } ,;
	               { "ADIANTA"  , "N" , 15 , 2 } ,;
	               { "FAT_D"    , "C" , 06 , 0 } ,;
	               { "DT_ADI"   , "D" ,  8 , 0 } ,;
	               { "DESPESA"  , "N" , 15 , 2 } ,;
                   { "SALDO"    , "N" , 15 , 2 } ,;
                   { "ACERTO"   , "N" , 15 , 2 } ,;
                   { "OBS"      , "C" , AvSX3("YB_DESCR", AV_TAMANHO) , 0 } ,;
	               { "DBDELETE" , "L" , 01 , 0 } }

EICFI400("ALTERA_ESTRUTURA") 

IF(EasyEntryPoint("EICCA150"),Execblock("EICCA150",.F.,.F.,"ALTERA_WORK"),)//AOM - 26/01/2010

// EOS - Criacao da Work e seus indices - Há duas criacoes idênticas da Work. Essa abaixo
// para a chamada do Setprint devido ao Schedule, e na funcao CA150Cons que é chamada
// do EICFI400, portanto se alterar uma criacao deve-se alterar a outra.

cNomArq := E_CriaTrab(,aCampos,"Work") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("Work",cNomArq+TEOrdBagExt(),"DESP+HAWB+DTOS(DT_ADI)",,,STR0024) //"Selecionando Registros..."

cNomInd := CriaTrab(,.F.)
IndRegua("Work",cNomInd+TEOrdBagExt(),"HAWB",,,STR0024) //"Selecionando Registros..."

SET INDEX TO (cNomArq+TEOrdBagExt()),(cNomInd+TEOrdBagExt())
	               
IF lEmailDespForn
	Private aCampos2:={{ "FORN"     , "C" , 06 , 0 } ,;	
		               { "NOME"     , "C" , 27 , 0 } ,;
		               { "REF"      , "C" , 03 , 0 } ,;
	                   { "DOCTO"    , "C" , 10 , 0 } ,;
		               { "HAWB"     , "C" , AvSx3("W6_HAWB", AV_TAMANHO), 0 } ,;
		               { "DTHAWB"   , "D" ,  8 , 0 } ,;
		               { "DATA_DI"  , "D" ,  8 , 0 } ,;
		               { "PO_NUM"   , "C" , AvSx3("W2_PO_NUM", AV_TAMANHO) , 0 } ,;
		               { "ADIANTA"  , "N" , 15 , 2 } ,;
		               { "FAT_D"    , "C" , 06 , 0 } ,;
		               { "DT_ADI"   , "D" ,  8 , 0 } ,;
		               { "DESPESA"  , "N" , 15 , 2 } ,;
	                   { "SALDO"    , "N" , 15 , 2 } ,;
	                   { "ACERTO"   , "N" , 15 , 2 } ,;
	                   { "OBS"      , "C" , AvSX3("YB_DESCR", AV_TAMANHO) , 0 } ,;
		               { "DBDELETE" , "L" , 01 , 0 } }

   cNomArq2 := E_CriaTrab(,aCampos2,"WkForn") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

	IndRegua("WkForn",cNomArq2+TEOrdBagExt(),"FORN+REF",,,STR0024) //"Selecionando Registros..."
	DBSELECTAREA("Work")
ENDIF

wnRel := "EICCA150"
aReturn:= { "Zebrado", 1,"Importacao", 2, 2, 1, "", 1 }

DO WHILE .T.
   If Pergunte(IF(!lEmail,"EICC20","EICC21"),IF(!lEmail,.T.,.F.)) 
      dDataIni := MV_PAR01
      dDataFim := MV_PAR02   
      nDespesa := MV_PAR03
      nTipRel  := MV_PAR04
      IF lEmail
         wnrel  := SetPrint("WORK",wnrel,"EICC21","",STR0018,STR0019,"",.F.,,.T.,"G")
         dDataIni := MV_PAR02
         dDataFim := MV_PAR03
         nDespesa := MV_PAR04
         nTipRel  := MV_PAR05
      ENDIF

      SWD->(DBSETORDER(2))
      SWD->(DBGOTOP())
      SWD->(DBSEEK(xFilial()+"901"+DTOS(dDataIni),.T.))
	  If SWD->WD_DES_ADI < dDataIni .OR. SWD->WD_DES_ADI > dDataFim
	     IF !lEmail
            Help("", 1, "AVG0000222")//"Não existem registros para consulta.
	        Loop
	     ELSE
	        EXIT
	     ENDIF
	  EndIf
	  IF !lEmail
         mBrowse( 6, 1,22,75,"SY5")
      ELSE
         CA150Cons("SY5", SY5->(recno()),2)
         EXIT
      ENDIF      
   Else 
      Exit
   EndIf
ENDDO               

SWD->(DBSETORDER(1))

If Select("Work") <> 0
   Work->(E_EraseArq(cNomArq))
EndIf

Return 


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 26/01/07 - 17:38
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina := { { STR0001,"AxPesqui" , 0 , 1},; //"Pesquisar"
                   { STR0002,"CA150Cons", 0 , 2},; //"Atual"
                   { STR0003,"CA150Cons", 0 , 2} } //"Todos"
                   
// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("ICA150MNU")
	aRotAdic := ExecBlock("ICA150MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina                   
*-----------------------------------------------------------------*
Function CA150Cons(cAlias,nReg,nOpcx,aPar4,lCadDesp)
*-----------------------------------------------------------------*
LOCAL TDesp:=iif(nOpcx==2,SY5->Y5_COD,""),aHawb:={},i,cNomCpo
LOCAL b_GrvTab := {|| IF(ASCAN(aHAWB,{|hawb| Hawb[1]==SWD->WD_HAWB})==0,AADD(aHawb,{SWD->WD_HAWB,SWD->WD_DES_ADI}),)}
LOCAL b_For    := {|| SWD->WD_DES_ADI >= dDataIni .AND. SWD->WD_DES_ADI <= dDataFim .AND. CA150Desp(SWD->WD_HAWB,TDesp) .AND. CA150Hous(SWD->WD_HAWB,THouse) }
LOCAL b_While  := {|| SWD->WD_DES_ADI <= dDataFim .AND.;
                      SWD->WD_DESPESA == "901"    .AND.;
                      SWD->WD_FILIAL  == xFilial("SWD")  }
LOCAL aTitulos := { {STR0005 ,"@!" },{STR0006       ,"@!" },; //"Despachante"###"Nome"
					{STR0007 ,"@!" },{STR0008       ,"@!" },; //"Ref.Desp."###"Documento"
                    {STR0009 ,"@!" },{STR0010       ,"@D" },; //"Processo"###"Dt. Processo"
                    {STR0011 ,"@D" },{STR0012       ,"@!" },; //"D.I./Desemb."###"No.P.O."
                    {STR0013 ,"@E 999,999,999,999.99"     },; //"Adiantamentos"
                    {STR0014 ,"@!" },{STR0034       ,"@D" },; //"Fatura" ###"Dt.Adiant."
                    {STR0015 ,"@E 999,999,999,999.99"     },; //"Despesas"
                    {STR0016 ,"@E 999,999,999,999.99"     },; //"Acerto"
                    {STR0017 ,"@E 999,999,999,999.99"     },; //"Saldo"
                    {"","@!"} }

LOCAL aDados :={"Work",;
                STR0018,; //"Este relatório irá emitir a relação de Adiantamentos a"
                STR0019,; //"Despachante. "
                "",;
                "G",;
                220,;
                PADC(IF(nDespesa==2,"Acertos Efetuados",IF(nDespesa==1,"Pendentes","Ambos"))+IIF(nTipRel==1," ( Analitico )"," ( Sintetico )"),220),;
                "",;
                STR0020,; //"Adiantamento a Despachantes "
                { "Zebrado", 1,"Importa‡Æo", 2, 2, 1, "",1 },;
                "EICCA150",;
                { {|| CA150Total("D",nDespesa)},{|| CA150Total("F",nDespesa)} } }

LOCAL aRCampos:={}, oDlg, oGet 
Local aButtons := {} //LRS 
LOCAL oPanel //LRL 06/04/04 
Local indice
lEmailDespForn:= EasyGParam("MV_DESPFOR",,.F.)  //Envia email para o Fornecedor quando este parametro estiver ligado - RS 04/09/07
IF lCadDesp == NIL
   lCadDesp := .F.
ENDIF

Private lDespDA := .T. // LRS - 06/05/2016 

// Usado somente no relatorio a PRINCIPIO.
PRIVATE lExibButtons := .F. //LRS 
PRIVATE TB_Campos:=;
      { {"DESP+' '+NOME"                     , STR0005  } ,; //"Despachante"
        {"REF"                               , STR0007  } ,; //"Ref.Desp."
        {"DOCTO"                             , STR0008  } ,; //"Documento"
        {"HAWB"                              , STR0009  } ,; //"Processo"
        {"DTHAWB"                            , STR0010  } ,; //"Dt. Processo"
        {"DATA_DI"                           , STR0011  } ,; //"D.I./Desemb."
        {"TRANS(PO_NUM,'@!')"                , STR0021  } ,; //"No. P.O."
        {"TRANS(ADIANTA,'@E 999,999,999.99')", STR0013  } ,; //"Adiantamentos"
        {"FAT_D"                             , STR0014  } ,; //"Fatura"
        {"DT_ADI"                            , STR0022  } ,; //"Dt.Adiant."
        {"TRANS(DESPESA,'@E 999,999,999.99')", STR0015  } ,; //"Despesas"
        {"TRANS(ACERTO, '@E 999,999,999.99')", STR0016  } ,; //"Acerto"    
        {"TRANS(SALDO,'@E 999,999,999.99')"  , STR0017  } ,; //"Saldo"   
        {"OBS"                               , AVSX3("YB_DESCR",5)}}

dbSelectArea( cAlias )
dbSetOrder(1)
If EasyRecCount(cAlias) == 0
   Return .T.
Endif
      
IF(EasyEntryPoint("EICCA150"),Execblock("EICCA150",.F.,.F.,"ALTERA_TITULO"),) //AOM-22/01/2010

If xFilial("SY5") != Y5_FILIAL
   IF !lEmail
      Help(" ",1,"A000FI")
   ENDIF
   Return .T.
Endif

// Definicao dos Totalizadores
PRIVATE MTot_Adi:=MToG_Adi:=0
PRIVATE MTot_Des:=MToG_Des:=0
PRIVATE MTot_Sdo:=MToG_Sdo:=0
PRIVATE MTot_Ace:=MToG_Ace:=0

PRIVATE THouse:=SPACE(LEN(SW6->W6_HAWB))
				
PRIVATE aTB_Campos:=;
      { {{||Work->DESP+' '+Work->NOME}           ,"", STR0005                        } ,; //"Despachante"
        {"REF"                                   ,"", STR0007                        } ,; //"Ref.Desp."
        {"DOCTO"                                 ,"", STR0008                        } ,; //"Documento"
        {"HAWB"                                  ,"", STR0009                        } ,; //"Processo"
        {"DTHAWB"                                ,"", STR0010                        } ,; //"Dt. Processo"
        {"DATA_DI"                               ,"", STR0011                        } ,; //"D.I./Desemb."
        {"PO_NUM"                                ,"", STR0021,_PictPO                } ,; //"No. P.O."
        {"ADIANTA"                               ,"", STR0013,'@E 999,999,999,999.99'} ,; //"Adiantamentos"
        {"FAT_D"                                 ,"", STR0014                        } ,; //"Fatura"
        {"DT_ADI"                                ,"", STR0022                        } ,; //"Dt.Adiant."
        {"DESPESA"                               ,"", STR0015,'@E 999,999,999,999.99'} ,; //"Despesas"
        {"ACERTO"                                ,"", STR0016,'@E 999,999,999,999.99'} ,; //"Acerto"
        {"SALDO"                                 ,"", STR0017,'@E 999,999,999,999.99'} }  //"Saldo"

cNomCpo:="Y5_COD"

/*
    lMailDespForn -> Parâmetro utilizado para controlar a quebra por Fornecedor    
*/
IF lEmailDespForn                                        // RS 04/09/07              
   aTitulos[1][1]:=STR0037   // Fornecedor 		  	     // RS 04/09/07
   adados[3]:= STR0037 // Fornecedor. 			  	 	 // RS 04/09/07
   adados[9]:= STR0038 // Adiantamento a Fornecedores    // RS 04/09/07
   TB_CAMPOS[1][2]:= STR0037  // Fornecedor              // RS 04/09/07
   aTb_Campos[1][3]:= STR0037 // Fornecedor              // RS 04/09/07
   cNomCpo:="A2_COD"   
ENDIF     

aCampos:={ { "DESP"   , "C" , AVSX3(cNomCpo,3) , 0 } ,;
           { "NOME"   , "C" , 27 , 0 } ,;
           { "REF"    , "C" , 10 , 0 } ,;
           { "DOCTO"  , "C" , 10 , 0 } ,;
           { "HAWB"   , "C" , AvSx3("W6_HAWB", AV_TAMANHO), 0 } ,;
           { "DTHAWB" , "D" ,  8 , 0 } ,;
           { "DATA_DI", "D" ,  8 , 0 } ,;
           { "PO_NUM" , "C" , AvSx3("W2_PO_NUM", AV_TAMANHO) , 0 } ,;
           { "ADIANTA", "N" , 15 , 2 } ,;
           { "FAT_D"  , "C" , 06 , 0 } ,;
           { "DT_ADI" , "D" ,  8 , 0 } ,;
           { "DESPESA", "N" , 15 , 2 } ,;
           { "SALDO"  , "N" , 15 , 2 } ,;
           { "ACERTO" , "N" , 15 , 2 } ,;
           { "OBS"    , "C" , AvSX3("YB_DESCR", AV_TAMANHO) , 0 } ,;
           { "DBDELETE","L" , 01 , 0 } }



EICFI400("ALTERA_ESTRUTURA",nOpcx)

IF(EasyEntryPoint("EICCA150"),Execblock("EICCA150",.F.,.F.,"ALTERA_TABELAS"),)//BHF-22/05/09

IF lEmailDespForn .and. Select("WkForn")==0            
	Private aCampos2:={{ "FORN"     , "C" , 06 , 0 } ,;
		               { "NOME"     , "C" , 27 , 0 } ,;
		               { "REF"      , "C" , 03 , 0 } ,;
                     { "DOCTO"    , "C" , 10 , 0 } ,;
                     { "HAWB"   , "C" , AvSx3("W6_HAWB", AV_TAMANHO), 0 } ,;
                     { "DTHAWB" , "D" ,  8 , 0 } ,;
                     { "DATA_DI", "D" ,  8 , 0 } ,;
                     { "PO_NUM" , "C" , AvSx3("W2_PO_NUM", AV_TAMANHO) , 0 } ,;
		               { "ADIANTA"  , "N" , 15 , 2 } ,;
		               { "FAT_D"    , "C" , 06 , 0 } ,;
		               { "DT_ADI"   , "D" ,  8 , 0 } ,;
		               { "DESPESA"  , "N" , 15 , 2 } ,;
	                   { "SALDO"    , "N" , 15 , 2 } ,;
	                   { "ACERTO"   , "N" , 15 , 2 } ,;
	                   { "OBS"      , "C" , AvSX3("YB_DESCR", AV_TAMANHO) , 0 } ,;
		               { "DBDELETE" , "L" , 01 , 0 } }


   cNomArq2 := E_CriaTrab(,aCampos2,"WkForn") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

	IndRegua("WkForn",cNomArq2+TEOrdBagExt(),"FORN+REF",,,STR0024) //"Selecionando Registros..."
ENDIF

// Array usado no Relatorio.
FOR indice=1  TO  LEN(TB_Campos)
    IF indice == 8 .OR. indice == 11 .OR. indice == 12
       MPosicao := "D"          // direita
    ELSEIF indice = 1 
       MPosicao := "C*"         // centralizado (Nao repete)
    ELSE
       MPosicao := "C"          // centralizado
    ENDIF
    AADD(aRCampos,{TB_Campos[indice,1],TB_Campos[indice,2],MPosicao})
NEXT
aRCampos[7,2] := STR0023 //"Nr. P.O."

dbSelectArea(cAlias)

If nOpcx==2 .AND. !lEmail
   nOpca:=0                
   THouse:=SW6->W6_HAWB
   IF !lCadDesp
      DEFINE MSDIALOG oDlg TITLE STR0009 FROM 1,1 TO 12,50 Of oMainWnd//"Processo"
      
        oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 17/07/2015
        oPanel:Align:= CONTROL_ALIGN_ALLCLIENT  
        
        //*** GFP 22/07/2011 :: 15h22 - Alteração de posição dos campos exibidos.
        @ 1.4 ,01 SAY STR0026 OF oPanel //"Processo:"
        @ 1.4 ,07 MSGET THouse  SIZE 70,10 PICT '@!' F3 "SW6" OF oPanel
        
        //@ 0.7 , 01 SAY STR0026 OF oDlg //"Processo:"
        //@ 0.7 , 06 MSGET THouse  SIZE 70,10 PICT '@!' F3 "SW6" OF oDlg

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IF(CA150Val(@THouse,.F.),(nOpca:=1,oDlg:End()),)},;
                                                   {||nOpca:=0, oDlg:End()}) CENTERED
     IF nOpca == 0
        RETURN 0
     ENDIF
   ENDIF
ENDIF

// EOS - Como esta funcao tambem é chamada pelo EICFI400 faz-se necessario verificar
// se a Work existe, se nao deve-se cria-la                  
IF Select("Work")==0

   cNomArq := E_CriaTrab(,aCampos,"Work") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
   
   IndRegua("Work",cNomArq+TEOrdBagExt(),"DESP+HAWB+DTOS(DT_ADI)",,,STR0024) //"Selecionando Registros..."

   cNomInd := CriaTrab(,.F.)
   IndRegua("Work",cNomInd+TEOrdBagExt(),"HAWB",,,STR0024) //"Selecionando Registros..."

   SET INDEX TO (cNomArq+TEOrdBagExt()),(cNomInd+TEOrdBagExt())
ENDIF   

aRCampos[12,2]  := TB_Campos[12,2] := "Acerto"
aRCampos[13,2]  := TB_Campos[13,2] := "Saldo"

SW6->(DbSetOrder(1))  //W6_FILIAL+W6_HAWB              // GFP - 17/01/2014
SW6->(DbSeek(xFilial("SW6")+AvKey(THouse,"W6_HAWB")))  // GFP - 17/01/2014

//LRS - 01/09/2016
IF Empty(THouse)
	SWD->(DBSETORDER(2))
	SWD->(DBSEEK(xFilial("SWD")+"901"+DTOS(dDataIni),.T.))
Else
    SWD->(DBSETORDER(1))
	SWD->(DBSEEK(xFilial("SWD")+SW6->W6_HAWB+"901"))  // GFP - 12/11/2013
EndIF
SWD->(DBEVAL(b_GrvTab,b_For,b_While))

// Grava o WorkFile
IF LEN(aHAWB) > 0
   IF !lEmail
      PROCESSA({|| ProcRegua(LEN(aHAWB)),AEVAL(aHAWB,{|H| CA150GrvWk(H,nDespesa,nTipRel)}) })
      PROCESSA({|| CA150SALDO(lDeleta) })//ACERTA A COLUNA SALDO
   ELSE
      AEVAL(aHAWB,{|H| CA150GrvWk(H,nDespesa,nTipRel)})   
      CA150SALDO(lDeleta)     
      IF Work->(Easyreccount("work")) > 0
         E_Report(aDados,aRCampos,,.F.)
      ENDIF
      RETURN NIL
   ENDIF
ENDIF

nOpca := 0

If (EasyEntryPoint("EICCA150"),Execblock("EICCA150",.F.,.F.,"DEP_GRV_WORK"),) //Acb - 08/09/2010
   
If Work->(Bof()) .And. Work->(Eof())
   Help("", 1, "AVG0000222")//MsgStop("Não existem registros para consulta!!!")
Else
   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE STR0025 ; //"Adiantamento"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
            TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL
   @ 00,00 MsPanel oPanel  Prompt "" Size 60,50 of oDlg //LRL 06/04/04
   If nOpcx==2
      @ 01.4,.8 SAY OemTOAnsi(SY5->Y5_NOME)
   Else
      cTipo := IF(nDespesa==2,STR0027,IF(nDespesa==1,STR0028,STR0029))+IF(nTipRel=1," - Analitico"," - Sintetico") //"Acertos Efetuados"###"Pendentes"###"Ambos"
      @ 1.4, .8 SAY OemToAnsi(cTipo)
      If nDespesa==1 
         @ 1.4 ,25 SAY OemToAnsi(STR0026) OF oDlg //"Processo:"
         @ 1.3 ,29 MSGET THouse  SIZE 70,10 PICT '@!' F3 "SW6" VALID CA150Val(@THouse,.T.) OF oDlg
      Endif
   Endif

   dbSelectArea("Work")
   dbGoTop()
   
   //*** GFP 22/07/2011 :: 14h37 - Alteração do posicionamento do botão "Imprimir"
   //DEFINE SBUTTON FROM 15 /*5*/,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (E_Report(aDados,aRCampos)) ENABLE OF oDlg
	  
	  //LRS - 28/08/2015 - aButtons para o EnchoiceBar
	  aAdd(aButtons, {"IMPRIM", {|| (E_Report(aDados,aRCampos)) }  ,STR0053} )//"Imprimir"
	  
	  EICFI400("EICCA150",nOpcx)
	  IF lExibButtons
		 IF cPaisLoc # "BRA" 
			aAdd(aButtons, {"GERATIT", {|| FI400Gera() }    ,STR0054} )//"Gera Titulos"
				  
		 ELSE
			aAdd(aButtons, {"GERATITEF", {|| FI400BaixaPA() } ,STR0055 } )//"Gerar Títulos Efetivos da compensação" 
			aAdd(aButtons, {"ESTOTITEF", {|| FI400EstBxPA() } ,STR0056} )// "Estornar Títulos Efetivos da compensação"
		 EndIF
     EndIF	
	 //by GFP - 29/09/2010 :: 10:10 - Inclusão da função para carregar campos criados pelo usuario.//NOPADO POR AOM - 01/02/2011
     //aTB_Campos := AddCpoUser(aTB_Campos,"SW6","2","Work") 
					
     oMark:=MsSelect():New("Work",,,aTB_Campos,.F.,"X",{35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
     oMark:oBrowse:bWhen:={|| DBSELECTAREA("Work"),.T.}
//LRS - 28/08/2015 - Nopado 	 
//	 oPanel:Align:=CONTROL_ALIGN_TOP //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
//	 oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   //EJA - 15/05/2019 - A variável aBtnPreCon é utilizada para possibilitar a alteração do menu da rotina "Prestação de contas" no ponto de entrada CA150CONS_MENU
   Private aBtnPreCon := aButtons
   If(EasyEntryPoint("EICCA150"),Execblock("EICCA150",.F.,.F., "EICCA150_MENU"),) // EJA - 14/05/2019
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aButtons)) //LRL 06/04/04 - Alinhamento MDI. //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

EndIf			                   

Work->(E_EraseArq(cNomArq,cNomInd))

if lEmailDespForn 
   WkForn->(E_EraseArq(cNomArq2))
endif
dbSelectArea( cAlias )
Return 2

//Consiste o house                                            ³
*-----------------------------------------------------------------*
FUNCTION CA150Val(THouse,lWork)
*-----------------------------------------------------------------*
LOCAL lRet:=.T.
IF !EMPTY(THouse)
   IF lWork
      Work->(DBSETORDER(2))
      IF !Work->(DBSEEK(THouse))
         HELP(" ",1,"NOHOUSE")
         Work->(DBGOTOP())
         lRet:=.F.
      ENDIF
      Work->(DBSETORDER(1))
      oMark:oBrowse:ReFresh()
      THouse:=Space(Len(SWD->WD_HAWB))
   ELSE
      SWD->(DBSETORDER(1))
      IF !SWD->(DBSEEK(xFilial()+THouse))
         HELP(" ",1,"NOHOUSE")
         lRet:=.F.
      ENDIF
   ENDIF
ENDIF
RETURN lRet

//Consiste o Despesa                                          ³
*-----------------------------------------------------------------*
FUNCTION CA150Desp(PHawb,PDesp)
*-----------------------------------------------------------------*
Local lRet:=.T.
IF !Empty(PDesp) .and. !lEmailDespForn     // RS 04/09/07                 
	//SW6->(DbSetOrder(1))	// GCC - Trecho comentado para não alterar o indice de pesquisa
	SW6->(DbSeek(xFilial()+PHawb)) 
	lRet := IIf(SW6->W6_DESP==AvKey(PDesp,"W6_DESP"),.T.,.F.)  // GFP - 12/11/2013
EndIf
Return lRet


//Consiste o Conhecimento                                     ³
*-----------------------------------------------------------------*
FUNCTION CA150Hous(PHawb,THouse)
*-----------------------------------------------------------------*
LOCAL lRet:=.T.
IF !EMPTY(THouse)
   SW6->(DBSEEK(xFilial()+PHawb)) 
   lRet:=IIF(PHawb == THouse,.T.,.F.)
ENDIF
RETURN lRet

//Consiste o Data Desembaraco                                 ³
*-----------------------------------------------------------------*
FUNCTION CA150VldDt(dDataIni, dDataFim)
*-----------------------------------------------------------------*
Local lRet:=.T.
IF !EMPTY(dDataFim)
   IF dDataIni > dDataFim
      lRet := .F.
   ENDIF
ENDIF
Return lRet

*-----------------------------------------------------------------*
FUNCTION CA150GrvWk(PHawb,nTipo,nRel)
*-----------------------------------------------------------------*
LOCAL MDespesa:=0,MAdiant:=0,MSaldos:=0,MAcerto:=0,TDados:=' ',TDocto:=' '
LOCAL bDtI_Ven:= {|| IF(!EMPTY(dDataIni),(SWD->WD_DES_ADI>=dDataIni),.T.)}  ,;   
      bDtF_Ven:= {|| IF(!EMPTY(dDataFim),(SWD->WD_DES_ADI<=dDataFim),.T.)}  //TRP-01/07/08

lDespDA := IF(TYPE("lDespDA")<>"L",.T.,lDespDA) //LGS-25/05/2016 //LRS - 06/04/2016

IF !lEmail
   IncProc()
ENDIF   
SW6->(DBSEEK(xFilial()+PHawb[1]))
SW7->(DBSEEK(xFilial()+SW6->W6_HAWB))
SWD->(DBSETORDER(1)) 
Begin Sequence
	IF SWD->(DBSEEK(xFilial()+PHawb[1]))
	
	   if lEmailDespForn     // RS 04/09/07
	      CA150GrvForn(PHawb,nTipo,nRel)     // RS 04/09/07
	      break              // RS 04/09/07
	   endif                 // RS 04/09/07
   WHILE ! SWD->(EOF()) .AND. SWD->WD_FILIAL==xFilial("SWD") .and. SWD->WD_HAWB==PHawb[1]
      DO CASE
         CASE SWD->WD_DESPESA == "903"          
              MAcerto -= SWD->WD_VALOR_R 
              MSaldos -= SWD->WD_VALOR_R
         CASE SWD->WD_DESPESA == "902"     
              MAcerto += SWD->WD_VALOR_R 
              MSaldos += SWD->WD_VALOR_R
         CASE SWD->WD_DESPESA == "901"     
              TDocto := SWD->WD_DOCTO
              MAdiant+= SWD->WD_VALOR_R 
              MSaldos+= SWD->WD_VALOR_R
      ENDCASE
      
      IF SWD->WD_BASEADI $ cSim .AND. ! (SUBST(SWD->WD_DESPESA,1,1)== '9')
         If !lAvIntFinEIC 
            MSaldos  -= SWD->WD_VALOR_R
            MDespesa += SWD->WD_VALOR_R
         Else
            MSaldos  -= SWD->WD_VALOR_A
            MDespesa += SWD->WD_VALOR_A
         Endif
      ENDIF
      EICFI400("GRAVA_CAMPOS1",)
      SWD->(DBSKIP())
   ENDDO
   IF nTipo == 2 .AND. ROUND(MSaldos,2) # 0  //NTIPO = ACERTOS EFETUADOS
      RETURN .T.
   ENDIF

   // Posiciona no Despachante
   SY5->(DBSEEK(xFilial()+SW6->W6_DESP))
   IF nRel == 2 //SINTETICO
      IF nTipo == 2  //ACERTOS EFETUADOS
         MDespesa := MAdiant := MSaldos := MAcerto:= 0
         SWD->(DBSEEK(xFilial()+PHawb[1]))
         DO WHILE ! SWD->(EOF()) .AND. SWD->WD_FILIAL==xFilial("SWD") .and. SWD->WD_HAWB == PHawb[1]
            //TRP-01/07/08- Tratamento para respeitar os filtros de data informados nos parâmetros do relatório.
            IF ! EVAL(bDtI_Ven) .OR. ! EVAL(bDtF_Ven)
               SWD->(DBSKIP())
               LOOP
            ENDIF 
            If SWD->WD_DA == "1" .AND. (!lDespDA  .OR. ValPresCont(Alltrim(SW6->W6_TIPOFEC))) //LRS - 10/10/2018
               SWD->(DbSkip())
               LOOP
            EndIf
            // Posiciona na Despesa
            SYB->(DBSEEK(xFilial()+SWD->WD_DESPESA))
            DO CASE
               CASE SWD->WD_DESPESA == "903"
                    MAcerto  -= SWD->WD_VALOR_R
               CASE SWD->WD_DESPESA == "902"
                    MAcerto  += SWD->WD_VALOR_R 
               CASE SWD->WD_DESPESA == "901"    
                    MAdiant  += SWD->WD_VALOR_R
            ENDCASE
            IF SWD->WD_BASEADI $ cSim .AND. ! (SUBST(SWD->WD_DESPESA,1,1)== '9')
               If !lAvIntFinEIC
                  MDespesa += SWD->WD_VALOR_R
               Else
                  MDespesa += SWD->WD_VALOR_A
               Endif
            ENDIF
            SWD->(DBSKIP())
         ENDDO
      ENDIF            
      IF ROUND(MSaldos,2) < 0
         TDados := STR0035
      ELSEIF ROUND(MSaldos,2) > 0
         TDados := STR0036
      ELSEIF ROUND(MSaldos,2) = 0
         TDados := " "
      ENDIF
      Work->(DBAPPEND())
      Work->DESP    := SW6->W6_DESP
      Work->NOME    := SY5->Y5_NOME
      Work->HAWB    := PHawb[1]
      Work->DATA_DI := IIF(!EMPTY(SW6->W6_DT_DESE),SW6->W6_DT_DESE,SW6->W6_DT)
      Work->DTHAWB  := SW6->W6_DT_HAWB
      Work->REF     := SW6->W6_REF_DES
      Work->DT_ADI  := PHawb[2]
      Work->PO_NUM  := SW7->W7_PO_NUM
      Work->ADIANTA := MAdiant
      Work->DESPESA := MDespesa
      Work->SALDO   := MSaldos
      Work->ACERTO  := MAcerto
      Work->OBS     := TDados
      Work->DOCTO   := TDocto
      Work->FAT_D   := SW6->W6_FAT_DES
   ELSE
      SWD->(DBSEEK(xFilial()+PHawb[1]))
      DO WHILE ! SWD->(EOF()) .AND. SWD->WD_FILIAL==xFilial("SWD").AND. SWD->WD_HAWB == PHawb[1]
         //TRP-01/07/08- Tratamento para respeitar os filtros de data informados nos parâmetros do relatório.
         IF ! EVAL(bDtI_Ven) .OR. ! EVAL(bDtF_Ven)
            SWD->(DBSKIP())
            LOOP
         ENDIF 
         If SWD->WD_DA == "1" .AND. (!lDespDA  .OR. ValPresCont(Alltrim(SW6->W6_TIPOFEC))) //LRS - 10/10/2018
            SWD->(DbSkip())
            LOOP
         EndIf
         // Posiciona na Despesa
         SYB->(DBSEEK(xFilial()+SWD->WD_DESPESA))
         DO CASE
            CASE SWD->WD_DESPESA == "903"
                 Work->(DBAPPEND())
                 Work->DESP    := SW6->W6_DESP
                 Work->NOME    := SY5->Y5_NOME
                 Work->HAWB    := PHawb[1]
                 Work->DATA_DI := IF(!EMPTY(SW6->W6_DT_DESEM),SW6->W6_DT_DESEM,SW6->W6_DT)
                 Work->DTHAWB  := SW6->W6_DT_HAWB
                 Work->REF     := SW6->W6_REF_DES
                 Work->DT_ADI  := SWD->WD_DES_ADI
                 Work->PO_NUM  := SW7->W7_PO_NUM
                 Work->ADIANTA := 0
                 Work->DESPESA := 0
                 Work->ACERTO  := SWD->WD_VALOR_R * (-1)
                 Work->OBS     := SYB->YB_DESCR
                 Work->DOCTO   := SWD->WD_DOCTO
                 Work->FAT_D   := SW6->W6_FAT_DES

            CASE SWD->WD_DESPESA == "902"
                 Work->(DBAPPEND())
                 Work->DESP    := SW6->W6_DESP
                 Work->NOME    := SY5->Y5_NOME
                 Work->HAWB    := PHawb[1]
                 Work->DATA_DI := IIF(!EMPTY(SW6->W6_DT_DESE),SW6->W6_DT_DESE,SW6->W6_DT)
                 Work->DTHAWB  := SW6->W6_DT_HAWB
                 Work->REF     := SW6->W6_REF_DES
                 Work->DT_ADI  := SWD->WD_DES_ADI
                 Work->PO_NUM  := SW7->W7_PO_NUM
                 Work->ADIANTA := 0
                 Work->DESPESA := 0
                 Work->ACERTO  := SWD->WD_VALOR_R
                 Work->OBS     := SYB->YB_DESCR
                 Work->DOCTO   := SWD->WD_DOCTO
                 Work->FAT_D   := SW6->W6_FAT_DES

            CASE SWD->WD_DESPESA == "901"
                 Work->(DBAPPEND())
                 Work->DESP    := SW6->W6_DESP
                 Work->NOME    := SY5->Y5_NOME
                 Work->HAWB    := PHawb[1]
                 Work->DATA_DI := IIF(!EMPTY(SW6->W6_DT_DESE),SW6->W6_DT_DESE,SW6->W6_DT)
                 Work->DTHAWB  := SW6->W6_DT_HAWB
                 Work->REF     := SW6->W6_REF_DES
                 Work->DT_ADI  := SWD->WD_DES_ADI
                 Work->PO_NUM  := SW7->W7_PO_NUM
                 Work->ADIANTA := SWD->WD_VALOR_R
                 Work->DESPESA := 0
                 Work->ACERTO  := 0
                 Work->OBS     := SYB->YB_DESCR
                 Work->DOCTO   := SWD->WD_DOCTO
                 Work->FAT_D   := SW6->W6_FAT_DES
         ENDCASE                    
         IF SWD->WD_BASEADI $ cSim .AND. ! (SUBST(SWD->WD_DESPESA,1,1)== '9') 
            Work->(DBAPPEND())
            Work->DESP    := SW6->W6_DESP
            Work->NOME    := SY5->Y5_NOME
            Work->HAWB    := PHawb[1]
            Work->DATA_DI := IIF(!EMPTY(SW6->W6_DT_DESEM),SW6->W6_DT_DESEM,SW6->W6_DT)
            Work->DTHAWB  := SW6->W6_DT_HAWB
            Work->REF     := SW6->W6_REF_DESP
            Work->DT_ADI  := SWD->WD_DES_ADI
            Work->PO_NUM  := SW7->W7_PO_NUM
            Work->ADIANTA := 0
            If !lAvIntFinEIC
               Work->DESPESA := SWD->WD_VALOR_R
            Else
               Work->DESPESA := SWD->WD_VALOR_A
            Endif
            Work->ACERTO  := 0
            Work->OBS     := SYB->YB_DESCR
            Work->DOCTO   := SWD->WD_DOCTO
            Work->FAT_D   := SW6->W6_FAT_DES
         ENDIF
         EICFI400("GRAVA_CAMPOS2")
         SWD->(DBSKIP())
      ENDDO
   ENDIF
   IF(EasyEntryPoint("EICCA150"),Execblock("EICCA150",.F.,.F.,"GRV_WORK"),)//AOM-22/01/2010
   
ENDIF
End Sequence

RETURN .T.
*-----------------------------------------*
FUNCTION CA150GrvForn(PHawb,nTipo,nRel)    
*-----------------------------------------*
LOCAL MSaldos:=0,TDados:=' ',TDocto:=' '

WHILE ! SWD->(EOF()) .AND. SWD->WD_FILIAL==xFilial("SWD") .and. SWD->WD_HAWB==PHawb[1]
    
    // Posiciona no Fornecedor
    SA2->(dbseek(xFilial("SA2")+SWD->WD_FORN))        
    IF ! WKFORN->(DBSEEK(SWD->WD_FORN))
  	   WKFORN->(DBAPPEND())
	   WKFORN->FORN    := SWD->WD_FORN
	   WKFORN->NOME    := SA2->A2_NOME
       WKFORN->HAWB    := PHawb[1]
    ENDIF      	

	DO CASE	
	   CASE SWD->WD_DESPESA == "903"
  	   	    WKFORN->ACERTO  -= SWD->WD_VALOR_R
			WKFORN->SALDO   -= SWD->WD_VALOR_R 

		CASE SWD->WD_DESPESA == "902"
  	   	    WKFORN->ACERTO  += SWD->WD_VALOR_R		
	 		WKFORN->SALDO   += SWD->WD_VALOR_R 

		CASE SWD->WD_DESPESA == "901"
			WKFORN->DOCTO   := TDocto    
			WKFORN->ADIANTA += SWD->WD_VALOR_R 
			WKFORN->SALDO   += SWD->WD_VALOR_R 			
		ENDCASE
		
		IF SWD->WD_BASEADI $ cSim .AND. ! (SUBST(SWD->WD_DESPESA,1,1)== '9')
			If !lAvIntFinEIC
			   WKFORN->SALDO   -= SWD->WD_VALOR_R 		
			   WKFORN->DESPESA += SWD->WD_VALOR_R 		
		    Else
		       WKFORN->SALDO   -= SWD->WD_VALOR_A		
			   WKFORN->DESPESA += SWD->WD_VALOR_A   
		    Endif
		ENDIF
		MSaldos+=WKFORN->SALDO
		EICFI400("GRAVA_CAMPOS1",)
		
		SWD->(DBSKIP())
ENDDO
IF nTipo == 2 .AND. ROUND(MSaldos,2) # 0  //NTIPO = ACERTOS EFETUADOS
	RETURN .T.
ENDIF
	
IF nRel == 2 //SINTETICO
    IF nTipo == 2  //ACERTOS EFETUADOS
		SWD->(DBSEEK(xFilial()+PHawb[1]))
		DO WHILE ! SWD->(EOF()) .AND. SWD->WD_FILIAL==xFilial("SWD") .and. SWD->WD_HAWB == PHawb[1]
		
			// Posiciona no Fornecedor
			SA2->(dbseek(xFilial("SA2")+SWD->WD_FORN))
			
	        IF ! WKFORN->(DBSEEK(SWD->WD_FORN))
		  	   WKFORN->(DBAPPEND())
			   WKFORN->FORN    := SWD->WD_FORN
			   WKFORN->NOME    := SA2->A2_NOME
	   	       WKFORN->HAWB    := PHawb[1]
	   	    ENDIF   
		
			// Posiciona na Despesa			
			SYB->(DBSEEK(xFilial()+SWD->WD_DESPESA))
			DO CASE
				CASE SWD->WD_DESPESA == "903"
  			        WKFORN->ACERTO  -= SWD->WD_VALOR_R
  			        
				CASE SWD->WD_DESPESA == "902"
  			        WKFORN->ACERTO  += SWD->WD_VALOR_R				

				CASE SWD->WD_DESPESA == "901"
         	   	    WKFORN->ADIANTA += SWD->WD_VALOR_R

			ENDCASE
			IF SWD->WD_BASEADI $ cSim .AND. ! (SUBST(SWD->WD_DESPESA,1,1)== '9')
 		       If !lAvIntFinEIC
 		          WKFORN->DESPESA += SWD->WD_VALOR_R
			   Else
			      WKFORN->DESPESA += SWD->WD_VALOR_A
			   Endif
			ENDIF			
			SWD->(DBSKIP())
		ENDDO
	ENDIF

    WKFORN->(DBGOTOP())
    WHILE ! WKFORN->(EOF())      
    
    	IF ROUND(WKFORN->SALDO,2) < 0
		TDados := STR0035
		ELSEIF ROUND(WKFORN->SALDO,2) > 0
		TDados := STR0036
		ELSEIF ROUND(WKFORN->SALDO,2) = 0
		TDados := " "
		ENDIF

     	Work->(DBAPPEND())
		Work->DESP    := WKFORN->FORN
		Work->NOME    := WKFORN->NOME
		Work->HAWB    := PHawb[1]
		Work->DATA_DI := IIF(!EMPTY(SW6->W6_DT_DESE),SW6->W6_DT_DESE,SW6->W6_DT)
		Work->DTHAWB  := SW6->W6_DT_HAWB
		Work->REF     := SW6->W6_REF_DES
		Work->DT_ADI  := PHawb[2]
		Work->PO_NUM  := SW7->W7_PO_NUM
		Work->ADIANTA := WKFORN->ADIANTA
		Work->DESPESA := WKFORN->DESPESA
		Work->SALDO   := WKFORN->SALDO
		Work->ACERTO  := WKFORN->ACERTO
		Work->OBS     := TDados		
		Work->DOCTO   := WKFORN->DOCTO
		Work->FAT_D   := SW6->W6_FAT_DES
		WKFORN->(dbskip())
    END
ELSE
	SWD->(DBSEEK(xFilial()+PHawb[1]))
	DO WHILE ! SWD->(EOF()) .AND. SWD->WD_FILIAL==xFilial("SWD").AND. SWD->WD_HAWB == PHawb[1]
		// Posiciona na Despesa
		SYB->(DBSEEK(xFilial()+SWD->WD_DESPESA))
		// Posiciona no Fornecedor
		SA2->(dbseek(xFilial("SA2")+SWD->WD_FORN))
		
		DO CASE
			CASE SWD->WD_DESPESA == "903"
				Work->(DBAPPEND())
				Work->DESP    := SWD->WD_FORN
				Work->NOME    := SA2->A2_NOME
				Work->HAWB    := PHawb[1]
				Work->DATA_DI := IF(!EMPTY(SW6->W6_DT_DESEM),SW6->W6_DT_DESEM,SW6->W6_DT)
				Work->DTHAWB  := SW6->W6_DT_HAWB
				Work->REF     := SW6->W6_REF_DES
				Work->DT_ADI  := SWD->WD_DES_ADI
				Work->PO_NUM  := SW7->W7_PO_NUM
				Work->ADIANTA := 0
				Work->DESPESA := 0
				Work->ACERTO  := SWD->WD_VALOR_R * (-1)
				Work->OBS     := SYB->YB_DESCR
				Work->DOCTO   := SWD->WD_DOCTO
  			    Work->FAT_D   := SW6->W6_FAT_DES
					
			CASE SWD->WD_DESPESA == "902"
				Work->(DBAPPEND())
				Work->DESP    := SWD->WD_FORN
				Work->NOME    := SA2->A2_NOME				
				Work->HAWB    := PHawb[1]
				Work->DATA_DI := IIF(!EMPTY(SW6->W6_DT_DESE),SW6->W6_DT_DESE,SW6->W6_DT)
				Work->DTHAWB  := SW6->W6_DT_HAWB
				Work->REF     := SW6->W6_REF_DES
				Work->DT_ADI  := SWD->WD_DES_ADI
				Work->PO_NUM  := SW7->W7_PO_NUM
				Work->ADIANTA := 0
				Work->DESPESA := 0
				Work->ACERTO  := SWD->WD_VALOR_R
				Work->OBS     := SYB->YB_DESCR
				Work->DOCTO   := SWD->WD_DOCTO
				Work->FAT_D   := SW6->W6_FAT_DES
					
			CASE SWD->WD_DESPESA == "901"
				Work->(DBAPPEND())
				Work->DESP    := SWD->WD_FORN
				Work->NOME    := SA2->A2_NOME				
				Work->HAWB    := PHawb[1]
				Work->DATA_DI := IIF(!EMPTY(SW6->W6_DT_DESE),SW6->W6_DT_DESE,SW6->W6_DT)
				Work->DTHAWB  := SW6->W6_DT_HAWB
				Work->REF     := SW6->W6_REF_DES
				Work->DT_ADI  := SWD->WD_DES_ADI
				Work->PO_NUM  := SW7->W7_PO_NUM
				Work->ADIANTA := SWD->WD_VALOR_R
				Work->DESPESA := 0
				Work->ACERTO  := 0
				Work->OBS     := SYB->YB_DESCR
				Work->DOCTO   := SWD->WD_DOCTO
				Work->FAT_D   := SW6->W6_FAT_DES
		ENDCASE
		IF SWD->WD_BASEADI $ cSim .AND. ! (SUBST(SWD->WD_DESPESA,1,1)== '9')
			Work->(DBAPPEND())
			Work->DESP    := SWD->WD_FORN
			Work->NOME    := SA2->A2_NOME		
			Work->HAWB    := PHawb[1]
			Work->DATA_DI := IIF(!EMPTY(SW6->W6_DT_DESEM),SW6->W6_DT_DESEM,SW6->W6_DT)
			Work->DTHAWB  := SW6->W6_DT_HAWB
			Work->REF     := SW6->W6_REF_DESP
			Work->DT_ADI  := SWD->WD_DES_ADI
			Work->PO_NUM  := SW7->W7_PO_NUM
			Work->ADIANTA := 0
			If !lAvIntFinEIC
			   Work->DESPESA := SWD->WD_VALOR_R
			Else
			   Work->DESPESA := SWD->WD_VALOR_A
			Endif
			Work->ACERTO  := 0
			Work->OBS     := SYB->YB_DESCR
			Work->DOCTO   := SWD->WD_DOCTO
			Work->FAT_D   := SW6->W6_FAT_DES
	    ENDIF
  	    EICFI400("GRAVA_CAMPOS2")
	    SWD->(DBSKIP())
    ENDDO
ENDIF
RETURN .T.

*-----------------------------------------------------------------*
FUNCTION CA150Total(PLocal,nRel)
*-----------------------------------------------------------------*
LOCAL  MCod,nTam:=219
STATIC SavHawb, _Primeiro

MCod := DESP+HAWB

_Primeiro:=IF(_Primeiro=NIL,.T.,.F.)

IF MCod # SavHawb
   SavHawb:= MCod

   IF ! _Primeiro
      Linha++
      @ Linha,T_Len[8,2]  PSAY REPL("-",T_Len[8,1])
      @ Linha,T_Len[11,2] PSAY REPL("-",T_Len[11,1])
      @ Linha,T_Len[12,2] PSAY REPL("-",T_Len[12,1])
      @ Linha,T_Len[13,2] PSAY REPL("-",T_Len[13,1])
      Linha++
      @ Linha,T_Len[8,2]-2  PSAY TRANSFORM(MTot_Adi,'@E 9,999,999,999.99')
      @ Linha,T_Len[11,2]-2 PSAY TRANSFORM(MTot_Des,'@E 9,999,999,999.99')
      @ Linha,T_Len[12,2] PSAY TRANSFORM(MTot_Ace,'@E 9999999,999.99')
      IF nTipRel == 2
         @ Linha,T_Len[13,2] PSAY TRANSFORM(MTot_Sdo,'@E 9999999,999.99')
      ENDIF
      IF nRel == 2
         @ Linha,T_Len[14,2] PSAY ALLTRIM(STR(MConta,6,0))+" Referencias"
      ELSEIF nTipRel == 1
         @ Linha,T_Len[13,2] PSAY TRANS((MTot_Adi+MTot_Ace-MTot_Des),'@E 9999999,999.99')
      ENDIF
      Linha++
      @ Linha,01 PSAY REPL("-",nTam)
      Linha++
      MTot_Adi := 0 ; MTot_Des := 0 ; MTot_Sdo := 0 ; MTot_Ace := 0 ; MConta:=0
      MTot_Adi+= ADIANTA 
      MTot_Des+= DESPESA 
      MTot_Ace+= ACERTO
      MTot_Sdo+= SALDO 
      MConta++
      IF PLocal == "F"
         @ Linha,T_Len[8,2]-2  PSAY TRANSFORM(MToG_Adi,'@E 9,999,999,999.99')
         @ Linha,T_Len[11,2]-2 PSAY TRANSFORM(MToG_Des,'@E 9,999,999,999.99')
         @ Linha,T_Len[12,2]   PSAY TRANSFORM(MToG_Ace,'@E 9999999,999.99')
         IF nTipRel == 2
            @ Linha,T_Len[13,2] PSAY TRANSFORM(MToG_Sdo,'@E 9999999,999.99')
         ENDIF
         IF nRel == 2
            @ Linha,T_Len[14,2] PSAY ALLTRIM(STR(MContG,6,0))+" Referencias"
         ELSEIF nTipRel == 1
            @ Linha,T_Len[13,2] PSAY TRANS(MToG_Adi+MToG_Ace-MToG_Des,'@E 9999999,999.99')
         ENDIF
         Linha++
         @ Linha,01 PSAY REPL("-",nTam)
         Linha++
      ENDIF
      MToG_Adi+= ADIANTA 
      MToG_Des+= DESPESA 
      MToG_Ace+= ACERTO 
      MToG_Sdo+= SALDO 
      MContG++
   ELSE
      MTot_Adi+= ADIANTA 
      MTot_Des+= DESPESA 
      MTot_Ace+= ACERTO 
      MTot_Sdo+= SALDO 
      MConta++
      MToG_Adi+= ADIANTA 
      MToG_Des+= DESPESA 
      MToG_Ace+= ACERTO 
      MToG_Sdo+= SALDO 
      MContG++
   ENDIF
ELSE
   MTot_Adi+= ADIANTA 
   MTot_Des+= DESPESA 
   MTot_Ace+= ACERTO 
   MTot_Sdo+= SALDO 
   MConta++
   MToG_Adi+= ADIANTA 
   MToG_Des+= DESPESA 
   MToG_Ace+= ACERTO 
   MToG_Sdo+= SALDO 
   MContG++
ENDIF
IF PLocal=="F"
   SavHawb := NIL ; _Primeiro := NIL
   MTot_Adi:=MToG_Adi:=0
   MTot_Des:=MToG_Des:=0
   MTot_Sdo:=MToG_Sdo:=0
   MTot_Ace:=MToG_Ace:=0
   MConta:=MContG:=0
ENDIF
RETURN .T.

*-----------------------------------------------------------------*
STATIC FUNCTION CA150SALDO(lDeleta)
*-----------------------------------------------------------------*
LOCAL cDesp, cHAWB, nSomatoria := nSaldoOld := 0
IF !lEmail
   ProcRegua( Work->( Easyreccount("Work") ) )
ENDIF
Work->(DBGOTOP())
DO WHILE !Work->(EOF())                            
   IF !lEmail
      IncProc()
   ENDIF
   cHAWB      := Work->HAWB
   cDesp      := Work->DESP
   nSomatoria := 0
   nRecWork    := Work->(Recno())
   DO WHILE !Work->(EOF()) .AND. cDesp  == Work->DESP .AND. Work->HAWB == cHAWB

      IF nTipRel == 1  //PARA APURAR A COLUNA SALDO # ANALITICO 
         IF Work->ADIANTA > 0
            nSomatoria += Work->ADIANTA
		 ELSEIF Work->DESPESA > 0
			nSomatoria -= Work->DESPESA
		 ELSEIF Work->ACERTO # 0
		    nSomatoria += Work->ACERTO
		 ENDIF   
         Work->SALDO:= nSomatoria
      ENDIF
      nSaldoOld    := Work->SALDO
      EICFI400("GRAVA_CAMPOS3")
      Work->(DBSKIP())
   ENDDO
   IF lDeleta .AND. Empty(nSaldoOld) .AND. nDespesa == 1 //SOMENTE PENDENTES
	  Work->(DBGOTO(nRecWork))
      DO WHILE !Work->(EOF()) .AND. cDesp  == Work->DESP .AND. Work->HAWB == cHAWB
         Work->(DBDELETE())
         Work->(DBSKIP())
      ENDDO
   ENDIF
ENDDO
RETURN .T.

     
/*
FUNCAO   : CA150PCNT(nEscolha)
AUTOR    : igor chiba
OBJETIVO : chamada do eicdi500, responsável por fazer a compensação/cancelamento de compensação e desbloqueio da despesa
DATA     : 17/07/14
Revisão  : wfs mai/2017 - complementado tratamento para impedir a liberação das despesas de adiantamento enquanto houver despesas
           pendente de prestação de contas.
*/
*-----------------------------------------------------------------*
Function CA150PCNT(nEscolha)
*-----------------------------------------------------------------*
Local cMsg:= ""

IF nEscolha == 2
   IF /*EMPTY(TRB->WD_CODINT).OR.*/ TRB->WD_BASEADI <> '1' .OR. TRB->WD_PAGOPOR <> '1' .OR. TRB->WD_DESPESA $ '901/902/903'
      MSGALERT(STR0039+; //"Esta não é uma despesa base de adiantamento utilizada como referência para realização do pagamento antecipado ao despachante"
               STR0040) //" e não poderá ser utilizada nesta rotina."
      RETURN .F. 
   ENDIF

   IF !EMPTY(TRB->WD_CTRFIN1) .AND. TRB->WD_VL_COMP <> 0 .AND. !EMPTY(TRB->WD_CTRFIN2)
      MSGALERT(STR0041+ TRB->WD_DESPESA + '.') //"A Prestação de Contas já foi realizada para a despesa:"
      RETURN .F.
   ENDIF      

   If !Empty(TRB->WD_CTRFIN1) .And. !Empty(TRB->WD_DTENVF)              
      MsgAlert(STR0047, STR0044) //"Este título encontra-se desbloqueado no ERP."
      Return .F.
   EndIf

   AADD(aEnchoice,"WD_BANCO")
   AADD(aEnchoice,"WD_AGENCIA")
   AADD(aEnchoice,"WD_CONTA")
     
   DI500D_Edi(.F.,,.T.)

ELSEIF nEscolha == 4 //cancelamento
   IF /* EMPTY(TRB->WD_CODINT).OR.*/ TRB->WD_BASEADI <> '1' .OR. TRB->WD_PAGOPOR <> '1' .OR. TRB->WD_DESPESA == "901"
      MSGALERT(STR0039+; //"Esta não é uma despesa base de adiantamento utilizada como referência para realização do pagamento antecipado ao despachante"
               STR0040) //" e não poderá ser utilizada nesta rotina."
       RETURN .F. 
   ENDIF

   //WFS 28/08/2014
   //Para realizar o cancelamento da compensação, a despesa deve ter sido compensada.
   If Empty(TRB->WD_CTRFIN1) .Or. Empty(TRB->WD_CTRFIN2) .Or. TRB->WD_VL_COMP == 0 //título gerado, sequencia da baixa e valor compensado
      MsgInfo(STR0042, STR0044) //"A operação de cancelamento da prestação de contas não poderá prosseguir pois esta despesa não possui registro de compensação com um adiantamento."###"Atenção"
      Return .F.
   EndIf

   ADIANT->(avzap())
   CA150PQPRES('EW7') 
  
   IF ADIANT->(Easyreccount("ADIANT")) == 0 
      MSGALERT(STR0043) //"Não existe despesa de adiantamento com saldo para ser utilizada na compensação desta despesa."
      RETURN .F.
   ENDIF
  
   DI500D_Del(.T.)

ELSEIF nEscolha == 5 //desbloqueio
   
   IF TRB->WD_BASEADI <> '1' .OR. TRB->WD_BASEADI <> '1' .OR. EMPTY(TRB->WD_CODINT)
      MSGALERT(STR0045) //"Esta despesa não foi integrada ou não está bloqueada no Financeiro do ERP. Não será necessário executar esta operação."
      RETURN .F.
   ELSEIF EMPTY(TRB->WD_CTRFIN1)              
      MSGALERT(STR0046) //"Esta despesa não foi integrada."
      RETURN .F.
   ELSEIF ! EMPTY(TRB->WD_CTRFIN1)  .and. !EMPTY(TRB->WD_DTENVF)              
      MSGALERT(STR0047, STR0044) //"Este título encontra-se desbloqueado no ERP."
      RETURN .F.
   ENDIF

   If PrestacaoPendente()
      cMsg:= STR0057 + ENTER + STR0058 //"Atenção: existem despesas com prestação de contas pendentes!" + ENTER + "Certifique-se que todas as prestações de contas foram realizadas e realize a integração/ desbloqueio ou exclusão das despesas que não serão consideradas na prestação de contas."
      MsgAlert(cMsg, STR0059) //"Atenção - Desbloqueio de título"
      Return .F.
   EndIf

   IF MSGYESNO(STR0048 + ENTER + ENTER +; //"Esta operação desbloqueará o título desta despesa no Financeiro do ERP, possibilitando a sua alteração e movimentação (baixa e compensação). "
               STR0060 + ENTER + ENTER +; //"ESTA OPERAÇÃO É IRREVERSÍVEL!"
               STR0049, STR0059) //"Deseja prosseguir?" //"Atenção - Desbloqueio de título"

      SWD->(DBGOTO(TRB->RECNO))
      IF EICFI411('SWD',3,.T.)
         SWD->(DBGOTO(TRB->RECNO))
         SWD->(RECLOCK('SWD',.F.))   
         SWD->WD_DTENVF := dDataBase
         SWD->(MSUNLOCK())
         
         TRB->WD_DTENVF:=dDataBase
         TRB->WKSTATUS:= DI501AtuStatusDesp()
      ENDIF
   ENDIF
ENDIF


RETURN                                                                


/*
FUNCAO   : CA150PQPRES(cTab)
AUTOR    : igor chiba
OBJETIVO : chamada do eicdi500, responsável por montar o ADIANT com despesas 901(para compensação) ou com os títulos gerados de importação EW7(para cancelar compensacao)
DATA     : 17/07/14
*/
*----------------------------*
Function CA150PQPRES(cTab)
*----------------------------*  
Local aOrd:= SaveOrd({"EW7", "SWD", "SYB"})
Local aCampos:= {}
Local cCampo:= ""
Local lAdiantamento:= .F.
Local bCond
Local nCont
Local nVl903 := 0
DEFAULT cTab :='SWD'

SYB->(DBSetOrder(1))
IF cTab == 'SWD' //DESEPESAS DE ADIANTAMENTOS 901
   SWD->(DBSetOrder(1))
   SWD->(DBSeek(xFilial("SWD") + SW6->W6_HAWB + '901'))
   DO WHILE SWD->(!Eof()) .AND. xFilial("SWD") == SWD->WD_FILIAL .AND. SWD->WD_HAWB == SW6->W6_HAWB .And. SWD->WD_DESPESA == "901"    
      nVl903 := DI501DVDES(SWD->WD_HAWB,SWD->WD_CTRFIN1) //THTS - 24/08/2017 - Devolucao do Despachante
      IF !EMPTY(SWD->WD_CTRFIN1) .AND. (SWD->WD_VALOR_R - SWD->WD_VL_COMP - nVl903) > 0 .And. Empty(SWD->WD_DTENVF) //despesa não pode ter sido desbloqueada
         ADIANT->(DBAPPEND())
         AVREPLACE('SWD','ADIANT')                        
         ADIANT->WD_SALDO  := SWD->WD_VALOR_R - SWD->WD_VL_COMP - nVl903
         ADIANT->WD_VL_COMP:= 0  //O VL_COMP É QUANTO JÁ FOI COMPENSADO, MAS EM TELA É QUANTO O USUARIO PODE DIGITAR 
         ADIANT->WK_RECADNT:= SWD->(RECNO())//RECNO DA 901
         ADIANT->WK_RECSWD := TRB->RECNO    //RECNO DA DESPESA BASE ADIANTAMENTO
      ENDIF
      SWD->(DBSKIP())
   ENDDO         
ELSE //REGISTROS DA TABELA EW7
   
   If TRB->WD_DESPESA == "901"
      bCond:= {|| EW7->EW7_CTRERP == AVKEY(TRB->WD_CTRFIN1, "EW7_CTRERP")}
      lAdiantamento:= .T.
   Else
      bCond:= {|| EW7->EW7_TITERP == AVKEY(TRB->WD_CTRFIN1, "EW7_TITERP")}
   EndIf
   
   EW7->(DBSetOrder(2)) //EW7_FILIAL+EW7_TPTIT+EW7_HAWB
   EW7->(DBSeek(xFilial("EW7") + AVKEY('CP','EW7_TPTIT')+TRB->WD_HAWB ))

   If cTab == "VIS"

      While EW7->(!Eof()) .And. xFilial("EW7") == EW7->EW7_FILIAL .And. EW7->EW7_TPTIT == AvKey("CP", "EW7_TPTIT");
	        .And. EW7->EW7_HAWB == TRB->WD_HAWB   

         If Eval(bCond)

            ADIANT->(DBAppend())

            /* Se é visualização do adiantamento, exibe os dados das despesas que foram compensadas. */
            If lAdiantamento
               ADIANT->WD_DESPESA := EW7->EW7_DESPES
               ADIANT->WD_CTRFIN1 := EW7->EW7_TITERP
            Else
               ADIANT->WD_DESPESA := "901"
               ADIANT->WD_CTRFIN1 := EW7->EW7_CTRERP
            EndIf

            SYB->(DBSeek(xFilial() + ADIANT->WD_DESPESA))
            ADIANT->WD_DESCDES := SYB->YB_DESCR
            ADIANT->WD_DES_ADI := EW7->EW7_DT_EMI //data da compensação
            ADIANT->WD_VL_COMP := EW7->EW7_VALOR
         EndIf
         EW7->(DBSkip())
      EndDo      

      /* Monta aHeader com os campos que devem ser exibidos.
         O backup do array aHeader está na função DI501D_Vis(). */
      aHeader:= {}
      aCampos:= {"WD_DESPESA", "WD_DESCDES", "WD_DES_ADI", "WD_DOCTO", "WD_CTRFIN1", "WD_VL_COMP"}
      SX3->(DBSetOrder(2))
      For nCont:= 1 To Len(aCampos)
         
         If SX3->(DBSeek(aCampos[nCont]))

            AAdd(aHeader,{SX3->X3_TITULO,;
            	            SX3->X3_CAMPO,;
            	            SX3->X3_PICTURE,;
            	            SX3->X3_TAMANHO,;
            	            SX3->X3_DECIMAL,;
            	            ,;
            	            ,;
            	            SX3->X3_TIPO,;
            	            ,;
            	            ,;
            	            })
         EndIf

      Next
   Else

      DO WHILE EW7->(!Eof()) .AND. xFilial("EW7") == EW7->EW7_FILIAL .AND. EW7->EW7_TPTIT == AvKey("CP", "EW7_TPTIT") .And. EW7->EW7_HAWB == TRB->WD_HAWB   
         //IF EW7->EW7_TITERP == AVKEY(TRB->WD_CTRFIN1,'EW7_TITERP')
         If Eval(bCond)
            ADIANT->(DBAPPEND())
            ADIANT->WD_DESPESA := EW7->EW7_DESPES
            ADIANT->WD_DES_ADI := EW7->EW7_DT_EMI
            ADIANT->WD_VALOR_R := EW7->EW7_VALOR
            ADIANT->WD_CTRFIN1 := EW7->EW7_TITERP//EW7->EW7_CTRERP
            ADIANT->WD_SALDO   := 0
            ADIANT->WD_VL_COMP := EW7->EW7_VALOR
            ADIANT->WK_RECADNT := EW7->(RECNO())
            ADIANT->WK_RECSWD  := TRB->RECNO    //RECNO DA DESPESA BASE ADIANTAMENTO
            ADIANT->WK_SEQBX   := EW7->EW7_SEQBX
	      ENDIF
	      EW7->(DBSKIP())
      ENDDO         
   EndIf
ENDIF

RestOrd(aOrd, .T.)
Return .T.                   

/*
FUNCAO   : CA150ATUTOT(nREg)         
AUTOR    : igor chiba
OBJETIVO : atualizar a variável de tela nSaldAdnt com a somatória dos valores compensados do ADIANT
PARAMETRO: nreg, RECNO da linha atual que está sendo alterada, por isso para essa linha usar memória e para as demais utilizar o valor da work
DATA     : 17/07/14
*/
*--------------------------*
FUNCTION CA150ATUTOT(nREg)         
*--------------------------*
DEFAULT nReg:= ADIANT->(RECNO())
         
nSaldAdnt:=0                 
ADIANT->(DBGOTOP())
DO WHILE  ADIANT->(!EOF())       
   nSaldAdnt+= IF(nREg == ADIANT->(RECNO()),M->WD_VL_COMP,ADIANT->WD_VL_COMP)
   ADIANT->(DBSKIP())
ENDDO 
ADIANT->(DBGOTO(nReg))   
oSaldAdnt:Refresh()
RETURN .T.



/*
FUNCAO   : CA150CHANGE()
AUTOR    : igor chiba
OBJETIVO : chamada do eicdi500, verifica se a despesa ainda não tem retorno do ERP ou se foi alterado algo
DATA     : 17/07/14
*/

*--------------------------*
FUNCTION CA150CHANGE()
*--------------------------*
LOCAL lChange := EMPTY(TRB->WD_CTRFIN1)
LOCAL nI
Local aNaoCompara:= {"WD_BANCO", "WD_AGENCIA", "WD_CONTA"}
 
IF !lChange
   SWD->(DBGOTO(TRB->RECNO))
   For nI:=1 to len(aEncAltera)
      IF SWD->&(aEncAltera[nI]) <> M->&(aEncAltera[nI]) .And.;
         AScan(aNaoCompara, aEncAltera[nI]) == 0 //Complementado por WFS em 27/08/2014 - não comparar os dados do banco pois são carregados na rotina de prestação de contas
           
         lChange:=.T.
         EXIT
      ENDIF
   Next
ENDIF

Return lChange



/*
FUNCAO   : CA150ESTPREST()
AUTOR    : igor chiba
OBJETIVO : chamada do EICFI413, cancela compensação da despesa original, volta os valores utilizados para a 901 e apaga os lançamentos na EW7
DATA     : 17/07/14
*/
*--------------------------*
FUNCTION CA150ESTPREST()
*--------------------------*
Local aOrd:= SaveOrd({"SWD", "TRB"})
Local lAchou:= .F.
Local nRecNo

Begin Sequence
       
   EW7->(DBGOTO(ADIANT->WK_RECADNT))   
   
   //DESPESA ORIGINAL BASE ADIANTAMENTO
   IF ADIANT->WK_RECSWD <> 0
      SWD->(DBGOTO(ADIANT->WK_RECSWD))
      SWD->(RECLOCK('SWD',.F.))
      /* atualiza a sequencia de baixa, abatendo a 1 da última processada */
      If Val(ADIANT->WK_SEQBX) == 1      
         SWD->WD_CTRFIN2:=""
      Else
         SWD->WD_CTRFIN2:= StrZero(Val(ADIANT->WK_SEQBX) - 1, Len(AllTrim(ADIANT->WK_SEQBX)))
      EndIf
      SWD->WD_VL_COMP -= EW7->EW7_VALOR
      SWD->(MSUNLOCK())
   ENDIF    

   //Atualiza TRB da despesa base de adiantamento
   TRB->(RecLock("TRB", .F.))
   TRB->WD_CTRFIN2:= SWD->WD_CTRFIN2
   TRB->WD_VL_COMP:= SWD->WD_VL_COMP
   TRB->(MsUnlock())
   
   //LOCALIZANDO A DESPESA 901 ATUALIZAR E ESTORNANDO VALOR QUE FOI COMPENSADO
   SWD->(DBSetOrder(1))
   SWD->(DBSeek(xFilial("SWD") + SW6->W6_HAWB + '901'))
   DO WHILE SWD->(!Eof()) .AND. xFilial("SWD") == SWD->WD_FILIAL .AND.;
            SWD->WD_HAWB == SW6->W6_HAWB .And. SWD->WD_DESPESA == "901"

     IF SWD->WD_CTRFIN1 == AVKEY(EW7->EW7_CTRERP,'WD_CTRFIN1')
        SWD->(RECLOCK('SWD',.F.))
        SWD->WD_VL_COMP -= EW7->EW7_VALOR
        SWD->(MSUNLOCK())
        nRecNo:= SWD->(RecNo())
     ENDIF
     SWD->(DBSKIP())
   ENDDO

   /* Atualiza a TRB da despesa de adiantamento */
   /* Procura na TRB a despesa de adiantametno correspondente à usada na compensação
      da despesa efetiva (arquivo de trabalho ADIANT). */ 
   TRB->(DBGoTop())
   While TRB->(!Eof()) .And. !lAchou

      If TRB->RECNO == nRecNo
         lAchou:= .T.
      Else
         TRB->(DBSkip())
      EndIf
   EndDo

   /* Atualiza os dados da despesa de adiantamento da TRB. */
   If lAchou
      TRB->(RecLock("TRB", .F.))
      TRB->WD_VL_COMP -= EW7->EW7_VALOR
      TRB->(MsUnlock())
   EndIf
   
   //APAGAR EW7
   IF ADIANT->WK_RECADNT <> 0
      EW7->(DBGOTO(ADIANT->WK_RECADNT))
      EW7->(RECLOCK('EW7',.F.))   
      EW7->(DBDELETE())   
      EW7->(MSUNLOCK())
   ENDIF 

End Sequence

RestOrd(aOrd, .T.)
RETURN .T.


/*
Funcao     : PrestacaoPendente()
Parametros : 
Retorno    : Lógico
Objetivos  : Verificar se existe prestação de contas pendente antes de desbloquear
Autor      : wfs
Data/Hora  : mai/2017
*/
Static Function PrestacaoPendente()
Local nRecNo:= TRB->(RecNo())
Local lRet:= .F.

Begin Sequence


   TRB->(DBGoTop())

   While TRB->(!Eof())

      If TRB->WKSTATUS == "B" .Or. TRB->WKSTATUS == "E" //B=Despesa aguardando prestação de contas (não integrada)//E=Despesa aguardando prestação de contas
         lRet:= .T.
         Exit
      EndIf
      TRB->(DBSkip())
   EndDo

   TRB->(DBGoTo(nRecNo))
End Sequence

Return lRet
