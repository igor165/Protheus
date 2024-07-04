#INCLUDE "Eecin100.ch" 
//#include "FWIN100.ch"  
#INCLUDE "FILEIO.CH"
#include "EEC.CH"   
#INCLUDE 'AP5MAIL.CH'

#define PC_CF "8" //Processo de exportação de café
#define PC_CM "9" //Processo de exportação de commodites   
#DEFINE say_tit 1           
#DEFINE say_det 2
#DEFINE say_rep 3
STATIC aNF_NS := {}

/*
Funcao    ³ EECIN100
Autor     ³ VICTOR IOTTI
Data      ³ 30.11.99
Descricao ³ Importacao de Arquivos
Sintaxe   ³ IN100()
Uso       ³ SIGAEEC
*/
*----------------------*       
FUNCTION EECIN100Param()
*----------------------*
PRIVATE oDlg5, oGet, nVolta, oActive, cAlias:=ALIAS(),N_TAMTELAP := 391,N_TAMTDIRP := 135
PRIVATE TULT_SP, TULT_CI, TULT_FB, TULT_LI, TULT_NB, TULT_FP, TULT_TC, TARQ_H, TULT_DI,TULT_TP
PRIVATE TARQ_I,  TARQ_CI, TARQ_FB, TARQ_LI, TARQ_NB, TARQ_TC, TARQ_FP, TARQ_DI,TARQ_TP
PRIVATE TINC_CI, TINC_FA, TINC_FO, TINC_LI, TINC_CO, TINC_LE, TINC_CC
PRIVATE TINC_AG, TINC_FW, TINC_IMP,TINC_CON,TINC_NBM,TINC_FAM,TINC_BAN,TINC_UNI
PRIVATE TULT_DE, TARQ_DE, TARQ_TMP,TULT_NS, TARQ_NS, TULT_NC, TARQ_NC, TARQ_ND

//AAF 21/10/04 - Adicionado campos da Integração de Conversão de Unidade de Medida
PRIVATE TULT_UC
PRIVATE TARQ_UC
Private aTelaEEC:={STR0004,;
                STR0005,;
                STR0006,;
                STR0007,;
                STR0008,;
                STR0009,;
                STR0326,;
                STR0301,;
                STR0302,;     
                STR0232}
TULT_TC :=Int_Param->NPAULT_TC
TULT_CL :=Int_Param->NPAULT_CL
TULT_FF :=Int_Param->NPAULT_FF
TULT_LK :=Int_Param->NPAULT_LK
TULT_IT :=Int_Param->NPAULT_IT
TULT_PE :=Int_Param->NPAULT_PE
TULT_NS := INT_PARAM->NPAULT_NS
TARQ_TC :=Int_Param->NPAARQ_TC
TARQ_CL :=Int_Param->NPAARQ_CL
TARQ_FF :=Int_Param->NPAARQ_FF
TARQ_LK :=Int_Param->NPAARQ_LK
TARQ_IT :=Int_Param->NPAARQ_IT
TARQ_ID :=Int_Param->NPAARQ_ID
TARQ_PE :=Int_Param->NPAARQ_PE
TARQ_PD :=Int_Param->NPAARQ_PD
TARQ_TMP:=Int_Param->NPAARQ_TMP
TARQ_NS := INT_PARAM->nPAARQ_NS
TULT_NC := INT_PARAM->NPAULT_NC
TARQ_NC := INT_PARAM->NPAARQ_NC
TARQ_ND := INT_PARAM->NPAARQ_ND
TULT_FP :=Int_Param->NPAULT_FP
TARQ_FP :=Int_Param->NPAARQ_FP
TULT_TP :=Int_Param->NPAULT_TP
TARQ_TP :=Int_Param->NPAARQ_TP

//** AAF 21/10/04 - Adicionado campos para a Integração de Conversão de Unidade de Medida
TULT_UC :=Int_Param->NPAULT_UC
TARQ_UC :=Int_Param->NPAARQ_UC
//** 
lSair:=.F.
//** AAF 21/10/04 - Verifica se Existe os Campos Existem
lTabPreco := EX5->( FieldPos("EX5_DTINI") > 0 .AND. FieldPos("EX5_DTFIM") > 0 ) .AND.;
             EX6->( FieldPos("EX6_DTINI") > 0 .AND. FieldPos("EX6_DTFIM") > 0 )
//**

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"PARAMCARGA")
EndIf
IF lSair
   RETURN .F.
ENDIF 
DEFINE MSDIALOG oDlg5 FROM  40,   0 TO N_TAMTELAP,626 TITLE STR0001 PIXEL OF GetWndDefault() // Parâmetros da Integração
nLin:=3
@ nLin,  80 SAY STR0002       			   SIZE 66,  7 OF oDlg5 PIXEL // Ultimo Processamento
@ nLin, 151 SAY STR0003					   SIZE 84,  7 OF oDlg5 PIXEL // Arquivos de Entrada (.TXT)
If aScan(aTelaEEC,{ |x| x ==STR0004}) > 0
   nLin+=12
   @ nLin,   6 SAY STR0004					   SIZE 76,  7 OF oDlg5 PIXEL // Processo de Exportação
   @ nLin,  96 MSGET oGet VAR TULT_PE           SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin, 151 MSGET oGet VAR TARQ_PE           SIZE 47, 10 OF oDlg5 PIXEL
   @ nLin, 209 MSGET oGet VAR TARQ_PD           SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTelaEEC,{ |x| x == STR0005}) > 0
   nLin+=10
   @ nLin,   6 SAY STR0005                      SIZE 74,  7 OF oDlg5 PIXEL // Itens
   @ nLin, 96  MSGET oGet VAR TULT_IT           SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin, 151 MSGET oGet VAR TARQ_IT           SIZE 47, 10 OF oDlg5 PIXEL
   @ nLin, 209 MSGET oGet VAR TARQ_ID           SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTelaEEC,{ |x| x ==STR0005}) > 0
   nLin+=12
   @ nLin,   6 SAY STR0006                      SIZE 74,  7 OF oDlg5 PIXEL // Fabricante/Fornecedor
   @ nLin, 96  MSGET oGet VAR TULT_FF           SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin, 151 MSGET oGet VAR TARQ_FF           SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTelaEEC,{ |x| x == STR0007}) > 0
   nLin+=11
   @ nLin,   6 SAY STR0007                      SIZE 74,  7 OF oDlg5 PIXEL // Item/Fabr/Forn 
   @ nLin, 96  MSGET oGet VAR TULT_LK           SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin, 151 MSGET oGet VAR TARQ_LK           SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTelaEEC,{ |x| x == STR0008}) > 0
   nLin+=12
   @ nLin,   6 SAY STR0008                      SIZE 74,  7 OF oDlg5 PIXEL // Cliente
   @ nLin, 96  MSGET oGet VAR TULT_CL           SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin, 151 MSGET oGet VAR TARQ_CL           SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTelaEEC,{ |x| x == STR0009}) > 0
   nLin+=10
   @ nLin,   6 SAY STR0009                      SIZE 74,  7 OF oDlg5 PIXEL // Conversão de Moedas  
   @ nLin, 96  MSGET oGet VAR TULT_TC           SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin, 151 MSGET oGet VAR TARQ_TC           SIZE 47, 10 OF oDlg5 PIXEL
EndIf
If aScan(aTelaEEC,{ |x| x == STR0326}) > 0
   nLin+=12
   //** AAF 21/10/04 - Adicionado campos para a Integração de Conversão de Unidade de Medida
   @ nLin,   6 SAY STR0326                      SIZE 74,  7 OF oDlg5 PIXEL //"Conversão de Unid. Med." 
   @ nLin, 096 MSGET oGet VAR TULT_UC           SIZE 32, 10 OF oDlg5 PIXEL
   @ nLin, 151 MSGET oGet VAR TARQ_UC           SIZE 47, 10 OF oDlg5 PIXEL
   //**
EndIf
If aScan(aTelaEEC,{ |x| x ==STR0301}) > 0
   nLin+=11
   @nLin,   6 SAY STR0301                      SIZE 74,  7 OF oDlg5 PIXEL //"Família de Produtos" 
   @nLin, 096 MSGET oGet VAR TULT_FP           SIZE 32, 10 OF oDlg5 PIXEL
   @nLin, 151 MSGET oGet VAR TARQ_FP           SIZE 47, 10 OF oDlg5 PIXEL
EndIf

If lTabPreco // AAF 21/10/04
   If aScan(aTelaEEC,{ |x| x == STR0302}) > 0
      nLin+=11
      @ nLin,  6 SAY STR0302                   SIZE 74,  7 OF oDlg5 PIXEL //"Tabela de Precos"
      @ nLin, 096 MSGET oGet VAR TULT_TP           SIZE 32, 10 OF oDlg5 PIXEL
      @ nLin, 151 MSGET oGet VAR TARQ_TP           SIZE 47, 10 OF oDlg5 PIXEL
   EndIf
Endif
If aScan(aTelaEEC,{ |x| x == STR0232}) > 0
   nLin+=12
   @ nLin,   6 SAY STR0232                      SIZE 74,  7 OF oDlg5 PIXEL // NFs. de Saida
   IF lNFITENS
      @ nLin, 96  MSGET oGet VAR TULT_NC           SIZE 32, 10 OF oDlg5 PIXEL
      @ nLin, 151 MSGET oGet VAR TARQ_NC           SIZE 47, 10 OF oDlg5 PIXEL
      @ nLin, 209 MSGET oGet VAR TARQ_ND           SIZE 47, 10 OF oDlg5 PIXEL
   ELSE
      @ nLin, 96  MSGET oGet VAR TULT_NS           SIZE 32, 10 OF oDlg5 PIXEL
      @ nLin, 151 MSGET oGet VAR TARQ_NS           SIZE 47, 10 OF oDlg5 PIXEL
   ENDIF
EndIf
If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"PARAMGET")
EndIf

@ N_TAMTDIRP,06 TO N_TAMTDIRP+24,114 LABEL STR0011 OF oDlg5 PIXEL  // Diretório dos Arq. Temporários
@ N_TAMTDIRP+9,013 MSGET oGet VAR TARQ_TMP  VALID IN100PARVAL(TARQ_TMP)  SIZE 95, 10    OF oDlg5 PIXEL

DEFINE SBUTTON FROM N_TAMTDIRP+7,150 TYPE 1 ACTION (nVolta:=1,oDlg5:End()) ENABLE OF oDlg5
DEFINE SBUTTON FROM N_TAMTDIRP+7,200 TYPE 2 ACTION (oDlg5:End())           ENABLE OF oDlg5

oGet:bGotFocus = { || oGet:SetPos( 0 ), nil }
nVolta = 0

ACTIVATE MSDIALOG oDlg5 CENTERED

IF nVolta = 1
   Reclock("Int_Param",.F.)
   DBSELECTAREA(cAlias)
   Int_Param->NPAULT_PE   :=TULT_PE
   Int_Param->NPAULT_IT   :=TULT_IT
   Int_Param->NPAULT_FF   :=TULT_FF
   Int_Param->NPAULT_LK   :=TULT_LK
   Int_Param->NPAULT_CL   :=TULT_CL
   Int_Param->NPAULT_TC   :=TULT_TC
   INT_PARAM->NPAULT_NS   :=TULT_NS
   Int_Param->NPAARQ_PE   :=ALLTRIM(TARQ_PE)
   Int_Param->NPAARQ_PD   :=ALLTRIM(TARQ_PD)
   Int_Param->NPAARQ_IT   :=ALLTRIM(TARQ_IT)
   Int_Param->NPAARQ_ID   :=ALLTRIM(TARQ_ID)
   Int_Param->NPAARQ_FF   :=ALLTRIM(TARQ_FF)
   Int_Param->NPAARQ_LK   :=ALLTRIM(TARQ_LK)
   Int_Param->NPAARQ_TC   :=ALLTRIM(TARQ_TC)
   Int_Param->NPAARQ_CL   :=ALLTRIM(TARQ_CL)
   Int_Param->NPAARQ_TMP  :=UPPER(ALLTRIM(TARQ_TMP))
   INT_PARAM->NPAARQ_NS  := UPPER(ALLTRIM(TARQ_NS))
   INT_PARAM->NPAULT_NC  := TULT_NC
   INT_PARAM->NPAARQ_NC  := TARQ_NC
   INT_PARAM->NPAARQ_ND  := TARQ_ND
   Int_Param->NPAULT_FP  := TULT_FP
  	Int_Param->NPAARQ_FP  := TARQ_FP
   Int_Param->NPAULT_TP  := TULT_TP
  	Int_Param->NPAARQ_TP  := TARQ_TP
	
	//** AAF - 21/10/04 - Adcionado Campos da Conversão de Unid. Med.
   Int_Param->NPAULT_UC  := TULT_UC
  	Int_Param->NPAARQ_UC  := TARQ_UC	
   //**

   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"PARAMGRAVA")
   EndIf   
   DBCOMMIT()
   Int_Param->(MSUNLOCK())
ENDIF

RETURN .T.

*-----------------*
FUNCTION IN100FF(TB_Cols) //*** GFP 26/08/2011 - Inserido parametro TB_Cols
*-----------------*
AADD(TB_Cols,{{||NFFCOD}    ,"",STR0012}) // Código
AADD(TB_Cols,{{||NFFLOJA}   ,"",STR0013}) // Loja
AADD(TB_Cols,{{||NFFNOME}   ,"",STR0014}) // Razão Social
AADD(TB_Cols,{{||NFFNOME_R} ,"",STR0015}) // Nome Reduzido
AADD(TB_Cols,{{||NFFEND}    ,"",STR0016}) // Endereço
AADD(TB_Cols,{{||NFFNR_END} ,"",STR0017}) // Número do Endereço
AADD(TB_Cols,{{||NFFBAIRRO} ,"",STR0018}) // Bairro
AADD(TB_Cols,{{||NFFCIDADE} ,"",STR0019}) // Cidade
AADD(TB_Cols,{{||NFFESTADO} ,"",STR0020}) // Estado
AADD(TB_Cols,{{||NFFCOD_P}  ,"",STR0021}) // Código do País
AADD(TB_Cols,{{||NFFCEP}    ,"",STR0022}) // CEP
AADD(TB_Cols,{{||NFFCX_POST},"",STR0023}) // Caixa Postal
AADD(TB_Cols,{{||NFFFONES}  ,"",STR0024}) // Telefones
AADD(TB_Cols,{{||NFFTELEX}  ,"",STR0025}) // Telex
AADD(TB_Cols,{{||NFFFAX}    ,"",STR0026}) // Fax
AADD(TB_Cols,{{||If(!SX5->(DBSEEK(cFilSX5+'48'+Int_FF->NFF_ID_FBF)),Int_FF->NFF_ID_FBF,SX5->X5_DESCRI)} ,"",STR0027}) // Identificação
AADD(TB_Cols,{{||IF(NFFSTATUS='1',STR0028,IF(NFFSTATUS='2',STR0029,PADL(NFFSTATUS,3)))}  ,"",STR0030}) // Sim Não Status
AADD(TB_Cols,{{||NFFFORN_BA},"",STR0031}) // Código do Banco (no Brasil)
AADD(TB_Cols,{{||NFFFORN_AG},"",STR0032}) // Código da Agência Bancária
AADD(TB_Cols,{{||NFFFORN_CO},"",STR0033}) // Número da Conta Bancária
AADD(TB_Cols,{{||NFFINSCEST},"",STR0034}) // Inscrição Estadual
AADD(TB_Cols,{{||NFFINSCMUN},"",STR0035}) // Inscrição Municipal
AADD(TB_Cols,{{||NFFPROC_1} ,"",STR0036}) // 1o. País de Procedência
AADD(TB_Cols,{{||NFFPROC_2} ,"",STR0037}) // 2o. País de Procedência
AADD(TB_Cols,{{||NFFPROC_3} ,"",STR0038}) // 3o. País de Procedência
AADD(TB_Cols,{{||NFFSWIFT}  ,"",STR0039}) // Swift do Fornecedor
AADD(TB_Cols,{{||NFFEMAIL}  ,"",STR0040}) // E-Mail do Fornecedor
AADD(TB_Cols,{{||NFFHOMEPG} ,"",STR0041}) // Home Page
AADD(TB_Cols,{{||NFFGRUPO}  ,"",STR0042}) // Grupo
AADD(TB_Cols,{{||NFFCNPJCPF},"",STR0043}) // CNPJ/CPF

ASIZE(TBRCols,0)
AADD(TBRCols,{"IN100Status()"      ,STR0030}) // Status
AADD(TBRCols,{"IN100Tipo()"        ,STR0044}) // Tipo
AADD(TBRCols,{"IN100CTD(NFFINT_DT)",STR0045}) // Dt Integ
AADD(TBRCols,{{||NFFCOD}           ,STR0012}) // Código
AADD(TBRCols,{{||NFFLOJA}          ,STR0013}) // Loja
AADD(TBRCols,{{||NFFNOME}          ,STR0014}) // Razão Social
AADD(TBRCols,{{||NFFNOME_R}        ,STR0015}) // Nome Reduzido
AADD(TBRCols,{{||If(!SX5->(DBSEEK(cFilSX5+'48'+Int_FF->NFF_ID_FBF)),Int_FF->NFF_ID_FBF,SX5->X5_DESCRI)},STR0027}) // Identificação
AADD(TBRCols,{{||IF(NFFSTATUS='1',STR0028,IF(NFFSTATUS='2',STR0029,PADL(NFFSTATUS,3)))},STR0030})  // Sim Não Status
AADD(TBRCols,{{||NFFCNPJCPF}       ,STR0043}) // CNPJ/CPF

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLFF")
ENDIF
AADD(TB_Cols,{{||IN100E_Msg(.T.)}  ,"",STR0046})

RETURN .T.


*--------------------*
FUNCTION IN100LerFF()
*--------------------*

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERFF")
ENDIF

IF EMPTY(ALLTRIM(Int_FF->NFFCOD))
   EVAL(bmsg,STR0047+STR0230)  // Código do Fabr/Forn não informado
ENDIF

IF EMPTY(ALLTRIM(Int_FF->NFFLOJA))
   EVAL(bmsg,STR0013+STR0230)  // Loja não informada
ENDIF

IF ! SA2->(DBSEEK(cFilSA2+AVKey(Int_FF->NFFCOD,"A2_COD")+Int_FF->NFFLOJA))
   IF Int_FF->NFFTIPO = EXCLUSAO  //# INCLUSAO
      EVAL(bmsg,STR0047+STR0228) // Código do Fabr/Forn sem cadastro
   ENDIF

   IF Int_FF->NFFTIPO = ALTERACAO
      Int_FF->NFFTIPO := INCLUSAO
   ENDIF

ELSEIF Int_FF->NFFTIPO = INCLUSAO
       EVAL(bmsg,STR0047+STR0229) // Código do Fabr/Forn já cadastrado

ELSEIF Int_FF->NFFTIPO == EXCLUSAO
       IF LEFT(ALLTRIM(UPPER(SA2->A2_ID_FBFN)),1) = "1" //"1-FABR"
          SA5->(DBSETORDER(4))
          IF SA5->(DBSEEK(cFilSA5+SA2->A2_COD))
             EVAL(bmsg,STR0048) // Fabr/Forn Possui Ligação com Item
          ENDIF
       ELSEIF LEFT(ALLTRIM(UPPER(SA2->A2_ID_FBFN)),1) = "2" //"2-FORN"
          SA5->(DBSETORDER(1))
          IF SA5->(DBSEEK(cFilSA5+SA2->A2_COD+SA2->A2_LOJA))
             EVAL(bmsg,STR0048) // Fabr/Forn Possui Ligação com Item
          ENDIF
       ELSEIF LEFT(ALLTRIM(UPPER(SA2->A2_ID_FBFN)),1) = "3" // "3-AMBOS"
          SA5->(DBSETORDER(1))
          IF SA5->(DBSEEK(cFilSA5+SA2->A2_COD+SA2->A2_LOJA))
             EVAL(bmsg,STR0048)
          ENDIF
          SA5->(DBSETORDER(4))
          IF SA5->(DBSEEK(cFilSA5+SA2->A2_COD))
             EVAL(bmsg,STR0048) // Fabr/Forn Possui Ligação com Item
          ENDIF
       ENDIF
       SA5->(DBSETORDER(1))
ENDIF

IF Int_FF->NFFTIPO == EXCLUSAO

   IN100PE_FF(Int_FF->NFFCOD,Int_FF->NFFLOJA)
   
   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALFF")
   ENDIF
   IN100VerErro(cErro,cAviso)
   IF Int_FF->NFFINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF
   RETURN .T.
ENDIF

IF EMPTY(Int_FF->NFFNOME) .AND. SA2->(EOF())
   EVAL(bmsg,STR0014+STR0230) // Razão Social não informado
ENDIF

IF ! SX5->(DBSEEK(cFilSX5+'48'+Int_FF->NFF_ID_FBF)) .AND. SA2->(EOF())
   EVAL(bmsg,STR0054+STR0227) // Identificação Fabr/Forn Inválido"
ENDIF

IF EMPTY(Int_FF->NFFEND) .AND. SA2->(EOF())
   EVAL(bmsg,STR0016+STR0230) // Endereço não informado
ENDIF

Int_FF->(IN100PE_END(NFFBAIRRO,NFFCIDADE,NFFESTADO))                      //MJB-SAP-1100

IF AT(Int_FF->NFFSTATUS,'12') = 0 .AND. SA2->(EOF())
   EVAL(bmsg,STR0055+STR0227) // Status Homologado Invalido
ENDIF

IF ! EMPTY(Int_FF->NFFFORN_BA)       
   IF ! SA6->(DBSEEK(cFilSA6+AVKey(Int_FF->NFFFORN_BA,"A6_COD")+AVKey(Int_FF->NFFFORN_AG,"A6_AGENCIA"))) 
      EVAL(bmsg,STR0056+STR0228) // Banco/Agencia sem cadastro
   ENDIF
ENDIF

IF ! EMPTY(ALLTRIM(Int_FF->NFFCNPJCPF))
   IF ! E_CGC(Int_FF->NFFCNPJCPF,.F.) .AND. Int_FF->NFFCNPJCPF != "99999999999999"
      EVAL(bmsg,STR0057+STR0227) // CGC inválido
   ENDIF
ENDIF

IF !Empty( Int_FF->NFFCOD_P ) .AND. ! SYA->(DBSEEK(cFilSYA+Int_FF->NFFCOD_P))
   EVAL(bmsg,STR0021+STR0228) // Código do país sem cadastro
ENDIF

IF !Empty( Int_FF->NFFPROC_1 ) .AND. ! SYA->(DBSEEK(cFilSYA+Int_FF->NFFPROC_1))
   EVAL(bmsg,STR0036+STR0228) // 1o. País de Procedência sem cadastro
ENDIF

IF !Empty( Int_FF->NFFPROC_2 ) .AND. ! SYA->(DBSEEK(cFilSYA+Int_FF->NFFPROC_2))
   EVAL(bmsg,STR0037+STR0228) // 2o. País de Procedência sem cadastro
ENDIF

IF !Empty( Int_FF->NFFPROC_3 ) .AND. ! SYA->(DBSEEK(cFilSYA+Int_FF->NFFPROC_3))
   EVAL(bmsg,STR0038+STR0228) // 3o. País de Procedência sem cadastro
ENDIF

If ! Empty(Int_FF->NFFGRUPO) .AND. ! SX5->(DBSEEK(cFilSX5+'Y7'+Int_FF->NFFGRUPO))
   EVAL(bmsg,STR0042+STR0228) // Grupo sem cadastro
EndIf

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALFF")
ENDIF

IN100VerErro(cErro,cAviso)

IF Int_FF->NFFINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF

Return .T.
*-----------------------------------------------------------------------------------------*
FUNCTION IN100PE_FF(cFFCod,cFFLoja)                                       //MJB-SAP-1100
*-----------------------------------------------------------------------------------------*
If Select("EE7") = 0 .And. !ChkFile("EE7")                                //MJB-SAP-1100
   Return                                                                 //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100
If Select("EE8") = 0 .And. !ChkFile("EE8")                                //MJB-SAP-1100
   Return                                                                 //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100
EE7->(DBSETORDER(6))                                                      //MJB-SAP-1100
       
If EE7->(DBSEEK(cFilEE7+AVKey(cFFCod,"EE7_EXPORT")+cFFLoja))       //MJB-SAP-1100
   EVAL(bmsg,STR0049+ALLTRIM(EE7->EE7_PEDIDO)) // Export.Possui PE-       //MJB-SAP-1100
ElseIf EE7->(DBSETORDER(5)) == Nil .AND. EE7->(DBSEEK(cFilEE7+AVKey(cFFCod,"EE7_EXPORT")+cFFLoja))
   EVAL(bmsg,STR0050+ALLTRIM(EE7->EE7_PEDIDO)) // Fornec.Possui PE-       //MJB-SAP-1100
ElseIf EE7->(DBSETORDER(8)) == Nil .AND. EE7->(DBSEEK(cFilEE7+AVKey(cFFCod,"EE7_EXPORT")+cFFLoja))
   EVAL(bmsg,STR0051+ALLTRIM(EE7->EE7_PEDIDO)) // Benef.Possui PE-        //MJB-SAP-1100
ElseIf EE8->(DBSETORDER(3)) == Nil .AND. EE8->(DBSEEK(cFilEE8+AVKey(cFFCod,"EE7_EXPORT")+cFFLoja))
   EVAL(bmsg,STR0052+ALLTRIM(EE8->EE8_PEDIDO)) // Fabr.Possui Item PE-    //MJB-SAP-1100
ElseIf EE8->(DBSETORDER(2)) == Nil .AND. EE8->(DBSEEK(cFilEE8+AVKey(cFFCod,"EE7_EXPORT")+cFFLoja))
   EVAL(bmsg,STR0053+ALLTRIM(EE8->EE8_PEDIDO)) // Fornec.Possui Item PE-  //MJB-SAP-1100
EndIf                                                                     //MJB-SAP-1100
EE7->(DBSETORDER(1))                                                      //MJB-SAP-1100
EE8->(DBSETORDER(1))                                                      //MJB-SAP-1100
*-----------------------------------------------------------------------------------------*
FUNCTION IN100PE_END(cBairro,cCidade,cEstado)                             //MJB-SAP-1100
*-----------------------------------------------------------------------------------------*
IF EMPTY(cBairro) .AND. SA2->(EOF())
   EVAL(bmsg,STR0018+STR0230) // Bairro não informado
ENDIF

IF EMPTY(cCidade) .AND. SA2->(EOF())
   EVAL(bmsg,STR0019+STR0230) // Cidade não informada
ENDIF

IF EMPTY(cEstado) .AND. SA2->(EOF())
   EVAL(bmsg,STR0020+STR0230) // Estado não informado
ENDIF

IF ! EMPTY(cEstado) .AND. ! SX5->(DBSEEK(cFilSX5+'12'+cEstado))
   EVAL(bmsg,STR0020+STR0228) // Estado sem cadastro
ENDIF

*--------------------*
FUNCTION IN100GrvFF()
*--------------------*
LOCAL cAlias

IF Int_FF->NFFTIPO # INCLUSAO 
   SA2->(DBSEEK(cFilSA2+AVKey(Int_FF->NFFCOD,"A2_COD")+Int_FF->NFFLOJA))
   IF SA2->(EOF()) .AND. Int_FF->NFFTIPO = ALTERACAO
      EVAL(bmsg,STR0006+STR0228+STR0058) // Fabricante/Fornecedor sem cadastro p/ alteração
      RETURN .T.
   ENDIF
   cAlias:=ALIAS()
   Reclock("SA2",.F.)
   DBSELECTAREA(cAlias)

   IF Int_FF->NFFTIPO = EXCLUSAO
      
      Begin sequence
        //eliminar descricoes em outro idioma		
		If EE3->(DBSEEK(cFilEE3+CD_SA2+AVKey(SA2->A2_COD,"EE3_CONTAT")+AVKey(SA2->A2_LOJA,"EE3_COMPL"))) //BY JBJ Troca do campo EE3_LOJA
		   While !EE3->(EOF()) .AND. ; 
		         cFilEE3+CD_SA2+AVKey(SA2->A2_COD,"EE3_CONTAT")+AVKey(SA2->A2_LOJA,"EE3_COMPL") ==; // BY JBJ Troca do campo EE3_LOJA
                 EE3->EE3_FILIAL+EE3->EE3_CODCAD+EE3->EE3_CONTAT+EE3->EE3_COMPL      // BY JBJ Troca do campo EE3_LOJA
                    RECLOCK("EE3",.F.)
					EE3->(DBDELETE())
					EE3->(MsUnlock())
					EE3->(DBSKIP(1))
		   Enddo
		EndIf
        SA2->(DBDELETE())
        SA2->(DBCOMMIT())
        SA2->(MSUNLOCK())  
      End Sequence
      
      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"EXCFF")
      EndIf
      
      RETURN .T.

   ENDIF
ENDIF

IF Int_FF->NFFTIPO = INCLUSAO
   IN100RecLock('SA2')
   SA2->A2_FILIAL := cFilSA2
   SA2->A2_COD    :=Int_FF->NFFCOD
   SA2->A2_LOJA   :=Int_FF->NFFLOJA
ENDIF

IF(!EMPTY(Int_FF->NFFNOME)    ,SA2->A2_NOME    :=Int_FF->NFFNOME,)
IF(!EMPTY(Int_FF->NFFNOME_R)  ,SA2->A2_NREDUZ  :=Int_FF->NFFNOME_R,)
IF(!EMPTY(Int_FF->NFFEND)     ,SA2->A2_END     :=Int_FF->NFFEND,)
IF(!EMPTY(Int_FF->NFFNR_END)  ,SA2->A2_NR_END  :=Int_FF->NFFNR_END,)
IF(!EMPTY(Int_FF->NFFBAIRRO)  ,SA2->A2_BAIRRO  :=Int_FF->NFFBAIRRO,)
IF(!EMPTY(Int_FF->NFFCIDADE)  ,SA2->A2_MUN     :=Int_FF->NFFCIDADE,)
IF(!EMPTY(Int_FF->NFFESTADO)  ,SA2->A2_EST     :=Int_FF->NFFESTADO,)
IF(!EMPTY(Int_FF->NFFCOD_P)   ,SA2->A2_PAIS    :=Int_FF->NFFCOD_P,)
IF(!EMPTY(Int_FF->NFFCEP)     ,SA2->A2_CEP     :=Int_FF->NFFCEP,)
IF(!EMPTY(Int_FF->NFFCX_POST) ,SA2->A2_CX_POST :=Int_FF->NFFCX_POST,)
IF(!EMPTY(Int_FF->NFFFONES)   ,SA2->A2_TEL     :=Int_FF->NFFFONES,)
IF(!EMPTY(Int_FF->NFFTELEX)   ,SA2->A2_TELEX   :=Int_FF->NFFTELEX,)
IF(!EMPTY(Int_FF->NFFFAX)     ,SA2->A2_FAX     :=Int_FF->NFFFAX,)
//IF(!EMPTY(Int_FF->NFF_ID_FBF) ,SA2->A2_ID_FBFN :=IF(NFF_ID_FBFN='1','FABRIC.',IF(NFF_ID_FBFN='2','FORNEC.',IF(NFF_ID_FBFN='3','FAB/FOR',IF(NFF_ID_FBFN='4','Export.',IF(NFF_ID_FBFN='5','Benefic',PADL(NFF_ID_FBFN,7))))))} ,"",STR0027}),)
IF(!EMPTY(Int_FF->NFF_ID_FBF) ,SA2->A2_ID_FBFN :=If(!SX5->(DBSEEK(cFilSX5+'48'+Int_FF->NFF_ID_FBF)),Int_FF->NFF_ID_FBF,X5DESCRI()),)
IF(!EMPTY(Int_FF->NFFSTATUS)  ,SA2->A2_STATUS  :=Int_FF->NFFSTATUS,)
IF(!EMPTY(Int_FF->NFFFORN_BA) ,SA2->A2_BANCO   :=Int_FF->NFFFORN_BA,)
IF(!EMPTY(Int_FF->NFFFORN_AG) ,SA2->A2_AGENCIA :=Int_FF->NFFFORN_AG,)
IF(!EMPTY(Int_FF->NFFFORN_CO) ,SA2->A2_NUMCON  :=Int_FF->NFFFORN_CO,)
IF(!EMPTY(Int_FF->NFFINSCEST) ,SA2->A2_INSCR   :=Int_FF->NFFINSCEST,)
IF(!EMPTY(Int_FF->NFFINSCMUN) ,SA2->A2_INSCRM  :=Int_FF->NFFINSCMUN,)
IF(!EMPTY(Int_FF->NFFPROC_1)  ,SA2->A2_ORIG_1  :=Int_FF->NFFPROC_1,)
IF(!EMPTY(Int_FF->NFFPROC_2)  ,SA2->A2_ORIG_2  :=Int_FF->NFFPROC_2,)
IF(!EMPTY(Int_FF->NFFPROC_3)  ,SA2->A2_ORIG_3  :=Int_FF->NFFPROC_3,)
IF(!EMPTY(Int_FF->NFFSWIFT  ) ,SA2->A2_SWIFT   :=Int_FF->NFFSWIFT  ,)
IF(!EMPTY(Int_FF->NFFEMAIL)   ,SA2->A2_EMAIL   :=Int_FF->NFFEMAIL,)
IF(!EMPTY(Int_FF->NFFHOMEPG)  ,SA2->A2_HPAGE   :=Int_FF->NFFHOMEPG,)
IF(!EMPTY(Int_FF->NFFGRUPO)   ,SA2->A2_GRUPO   :=Int_FF->NFFGRUPO,)
IF(!EMPTY(Int_FF->NFFCNPJCPF) ,SA2->A2_CGC     :=Int_FF->NFFCNPJCPF,)                                                                    

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVFF")
ENDIF

SA2->(MSUNLOCK())

Return .T.

*-----------------*
FUNCTION IN100Cl()
*-----------------*
AADD(TB_Cols,{{|| NCLCOD}     ,"",STR0012}) // Código
AADD(TB_Cols,{{|| NCLLOJA}    ,"",STR0013}) // Loja
AADD(TB_Cols,{{|| NCLNOME}    ,"",STR0059}) // Nome
AADD(TB_Cols,{{|| NCLNREDUZ}  ,"",STR0015}) // Nome Reduzido
AADD(TB_Cols,{{|| NCLEND}     ,"",STR0016}) // Endereço
AADD(TB_Cols,{{|| NCLBAIRRO}  ,"",STR0018}) // Bairro
AADD(TB_Cols,{{|| NCLCIDADE}  ,"",STR0019}) // Cidade
AADD(TB_Cols,{{|| NCLESTADO}  ,"",STR0020}) // Estado
AADD(TB_Cols,{{|| NCLPAIS}    ,"",STR0021}) // Código do País
AADD(TB_Cols,{{|| NCLCEP}     ,"",STR0022}) // CEP
AADD(TB_Cols,{{|| NCLCP}      ,"",STR0023}) // Caixa Postal
AADD(TB_Cols,{{|| NCLTEL}     ,"",STR0024}) // Telefones
AADD(TB_Cols,{{|| NCLTELEX}   ,"",STR0025}) // Telex
AADD(TB_Cols,{{|| NCLFAX}     ,"",STR0026}) // Fax
AADD(TB_Cols,{{|| NCLBANCO1}  ,"",STR0060}) // Código Banco 1
AADD(TB_Cols,{{|| NCLBANCO2}  ,"",STR0061}) // Código Banco 2
AADD(TB_Cols,{{|| NCLBANCO3}  ,"",STR0062}) // Código Banco 3
AADD(TB_Cols,{{|| NCLBANCO4}  ,"",STR0063}) // Código Banco 4
AADD(TB_Cols,{{|| NCLBANCO5}  ,"",STR0064}) // Código Banco 5
AADD(TB_Cols,{{|| NCLEMAIL}   ,"",STR0065}) // E-Mail
AADD(TB_Cols,{{|| NCLHOMEPG}  ,"",STR0066}) // Home Page
AADD(TB_Cols,{{|| NCLMARCAC}  ,"",STR0067}) // Marcação
AADD(TB_Cols,{{|| NCLAGENTE}  ,"",STR0068}) // Código Agente Comissão
AADD(TB_Cols,{{|| NCLCOMISS}  ,"",STR0069}) // "% Comissão"
AADD(TB_Cols,{{|| NCLOBS}     ,"",STR0070}) // Observações
AADD(TB_Cols,{{|| IF(NCLTIPOCLI$"I1",STR0071,IF(NCLTIPOCLI$"C2",STR0072,IF(NCLTIPOCLI$"N3",STR0073,IF(NCLTIPOCLI$"T4",STR0074,SPACE(10)))))},"",STR0075}) // Importador Consignee Notify Todos   Tipo Cliente
AADD(TB_Cols,{{|| NCLDEST1}   ,"",STR0076}) // Destino 1
AADD(TB_Cols,{{|| NCLDEST2}   ,"",STR0077}) // Destino 2
AADD(TB_Cols,{{|| NCLDEST3}   ,"",STR0078}) // Destino 3 
AADD(TB_Cols,{{|| NCLCONDPG}  ,"",STR0079}) // Condições Pagamento
AADD(TB_Cols,{{|| NCLDIASPG}  ,"",STR0080}) // Dias Pagamento

ASIZE(TBRCols,0)
AADD(TBRCols,{"IN100Status()"      ,STR0030}) // Status
AADD(TBRCols,{"IN100Tipo()"        ,STR0044}) // Tipo
AADD(TBRCols,{"IN100CTD(NCLINT_DT)",STR0045}) // Dt Integ
AADD(TBRCols,{{|| NCLCOD}          ,STR0012}) // Código
AADD(TBRCols,{{|| NCLLOJA}         ,STR0013}) // Loja
AADD(TBRCols,{{|| NCLNOME}         ,STR0059}) // Nome
AADD(TBRCols,{{|| NCLNREDUZ}       ,STR0015}) // Nome Reduzido
AADD(TBRCols,{{|| NCLAGENTE}       ,STR0068}) // Código Agente Comissão
AADD(TBRCols,{{|| NCLCOMISS}       ,STR0069}) // % Comissão
AADD(TBRCols,{{|| IF(NCLTIPOCLI$"I1",STR0071,IF(NCLTIPOCLI$"C2",STR0072,IF(NCLTIPOCLI="N3",STR0073,IF(NCLTIPOCLI="T4",STR0074,SPACE(10)))))},"",STR0075}) // Importador Consignee Notify   Tipo Cliente //"Todos     "

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLCL")
ENDIF
AADD(TB_Cols,{{||IN100E_Msg(.T.)}  ,"",STR0046})
Return .T.

*--------------------*
FUNCTION IN100LerCl()
*--------------------*
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERCL")
ENDIF

IF EMPTY(ALLTRIM(Int_CL->NCLCOD))
   EVAL(bmsg,STR0081+STR0230) // Código do Cliente não informado
ENDIF

IF Empty(ALLTRIM(Int_CL->NCLLOJA))                                        //MJB-SAP-1100
   If Int_CL->NCLCOD <> SA1->A1_COD                                       //MJB-SAP-1100
      SA1->(DBSEEK(cFilSA1+AVKey(Int_CL->NCLCOD,"A1_COD")))        //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   If SA1->(Found())                                                      //MJB-SAP-1100
      Int_CL->NCLLOJA:=SA1->A1_LOJA                                       //MJB-SAP-1100
   Else                                                                   //MJB-SAP-1100
      Int_CL->NCLLOJA:="."                                                //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100

IF EMPTY(ALLTRIM(Int_CL->NCLLOJA))
   EVAL(bmsg,STR0013+STR0230) // Loja não informado
ENDIF

IF ! SA1->(DBSEEK(cFilSA1+AVKey(Int_CL->NCLCOD,"A1_COD")+AVKey(Int_CL->NCLLOJA,"A1_LOJA")))
   IF Int_CL->NCLTIPO = EXCLUSAO  //# INCLUSAO
      EVAL(bmsg,STR0081+STR0228) // Código do Cliente sem cadastro
   ENDIF

   IF Int_CL->NCLTIPO = ALTERACAO
      Int_CL->NCLTIPO := INCLUSAO
   ENDIF

ELSEIF Int_CL->NCLTIPO = INCLUSAO
       EVAL(bmsg,STR0081+STR0229) // Código do Cliente já cadastro

ELSEIF Int_CL->NCLTIPO == EXCLUSAO
       // Nenhuma validacao.
ENDIF

IF Int_CL->NCLTIPO == EXCLUSAO
   
   EE7->(DBSETORDER(4))
   If EE7->(DBSEEK(cFilEE7+AVKey(Int_CL->NCLCOD,"EE7_CLIENT")+AVKey(Int_CL->NCLLOJA,"EE7_CLLOJA")))
      EVAL(bmsg,STR0082+ALLTRIM(EE7->EE7_PEDIDO)) // Cliente Possui PE-
   ElseIf EE7->(DBSETORDER(3)) == Nil .AND. EE7->(DBSEEK(cFilEE7+AVKey(Int_CL->NCLCOD,"EE7_IMPORT")+AVKey(Int_CL->NCLLOJA,"EE7_IMLOJA")))
      EVAL(bmsg,STR0083+ALLTRIM(EE7->EE7_PEDIDO)) // Import.Possui PE-
   ElseIf EE7->(DBSETORDER(7)) == Nil .AND. EE7->(DBSEEK(cFilEE7+AVKey(Int_CL->NCLCOD,"EE7_CONSIG")+AVKey(Int_CL->NCLLOJA,"EE7_COLOJA")))
      EVAL(bmsg,STR0084+ALLTRIM(EE7->EE7_PEDIDO)) // Consig.Possui PE-
   EndIf
   EE7->(DBSETORDER(1))
   
   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALCL")
   ENDIF
   IN100VerErro(cErro,cAviso)
   IF Int_CL->NCLINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF
   RETURN .T.
ENDIF

IF EMPTY(Int_CL->NCLNOME) .AND. SA1->(EOF())
   EVAL(bmsg,STR0059+STR0230) // Nome não informado
ENDIF

IF EMPTY(Int_CL->NCLNREDUZ) .AND. SA1->(EOF())
   EVAL(bmsg,STR0015+STR0230) // Nome Reduzido não informado
ENDIF

IF EMPTY(Int_CL->NCLEND) .AND. SA1->(EOF())
   EVAL(bmsg,STR0016+STR0230) // Endereço não informado
ENDIF

IF !Empty(Int_CL->NCLPAIS) .AND. ! SYA->(DBSEEK(cFilSYA+AVKey(Int_CL->NCLPAIS,"YA_CODGI")))
   EVAL(bmsg,STR0021+STR0228) // Código do País sem cadastro
ENDIF

IF ! EMPTY(Int_CL->NCLBANCO1) .AND. ! SA6->(DBSEEK(cFilSA6+AVKey(Int_CL->NCLBANCO1,"A6_COD")))
   EVAL(bmsg,STR0060+STR0228) // Código Banco 1 sem cadastro
ENDIF

IF ! EMPTY(Int_CL->NCLBANCO2) .AND. ! SA6->(DBSEEK(cFilSA6+AVKey(Int_CL->NCLBANCO2,"A6_COD")))
   EVAL(bmsg,STR0061+STR0228) // Código Banco 2 sem cadastro  
ENDIF

IF ! EMPTY(Int_CL->NCLBANCO3) .AND. ! SA6->(DBSEEK(cFilSA6+AVKey(Int_CL->NCLBANCO3,"A6_COD")))
   EVAL(bmsg,STR0062+STR0228) // Código Banco 3 sem cadastro  
ENDIF

IF ! EMPTY(Int_CL->NCLBANCO4) .AND. ! SA6->(DBSEEK(cFilSA6+AVKey(Int_CL->NCLBANCO4,"A6_COD")))
   EVAL(bmsg,STR0063+STR0228) // Código Banco 4 sem cadastro  
ENDIF

IF ! EMPTY(Int_CL->NCLBANCO5) .AND. ! SA6->(DBSEEK(cFilSA6+AVKey(Int_CL->NCLBANCO5,"A6_COD")))
   EVAL(bmsg,STR0064+STR0228) // Código Banco 5 sem cadastro    
ENDIF

IF ! EMPTY(Int_CL->NCLAGENTE) .AND. ! SY5->(DBSEEK(cFilSY5+AVKey(Int_CL->NCLAGENTE,"Y5_COD")))
   EVAL(bmsg,STR0068+STR0228) // Código Agente Comissão
ENDIF

IF ! EMPTY(Int_CL->NCLDEST1) .AND. ! SY9->(DBSEEK(cFilSY9+AVKey(Int_CL->NCLDEST1,"Y9_COD")))
   EVAL(bmsg,STR0076+STR0228) // Destino 1
EndIf

IF ! EMPTY(Int_CL->NCLDEST2) .AND. ! SY9->(DBSEEK(cFilSY9+AVKey(Int_CL->NCLDEST2,"Y9_COD")))
   EVAL(bmsg,STR0077+STR0228) // Destino 2  
EndIf

IF ! EMPTY(Int_CL->NCLDEST3) .AND. ! SY9->(DBSEEK(cFilSY9+AVKey(Int_CL->NCLDEST3,"Y9_COD")))
   EVAL(bmsg,STR0078+STR0228) // Destino 3  
EndIf

IF AT(Int_CL->NCLTIPOCLI,'ICNT') = 0 .AND. SA1->(EOF())
   EVAL(bmsg,STR0075+STR0227) // Tipo Cliente Invalido
ENDIF

IF ! EMPTY(Int_CL->NCLCONDPG)

   /*
   AMS - 04/11/2004 às 16:56. Substituida pela condição abaixo.

   If ! SY6->(DBSEEK(cFilSY6+AVKey(Int_CL->NCLCONDPG,"Y6_COD")))
      EVAL(bMsg,STR0079+STR0228) // Condições Pagamento sem cadastro

   ElseIf IN100NaoNum(Int_CL->NCLDIASPG)
      EVAL(bMsg,STR0085+STR0227) // No.Dias inválido

   ElseIf ! SY6->(DBSEEK(cFilSY6+AVKey(Int_CL->NCLCONDPG,"Y6_COD")+STR(VAL(Int_CL->NCLDIASPG),3,0)))
      EVAL(bMsg,STR0079+'/'+STR0085+STR0228) // Condicao de Pagto/No.Dias sem cadastro
   EndIf
   */

   If ! SY6->(DBSEEK(cFilSY6+AVKey(Int_CL->NCLCONDPG,"Y6_COD")))

      EVAL(bMsg,STR0079+STR0228) // Condições Pagamento sem cadastro

   Else

      Do Case

         Case SY6->Y6_TIPO = "1" //Normal

            If !(Val(Int_CL->NCLDIASPG) > -1 .and. Val(Int_CL->NCLDIASPG) < 901) // Somente de 0 à 900.
               EVAL(bMsg,STR0085+STR0227) // No.Dias inválido
            EndIf

         Case SY6->Y6_TIPO = "2" //A Vista.

            If Val(Int_CL->NCLDIASPG) <> -1 // Somente -1.
               EVAL(bMsg,STR0085+STR0227) // No.Dias inválido
            EndIf

         Case SY6->Y6_TIPO = "3" //Parcelado.

            If Val(Int_CL->NCLDIASPG) < 900 // Somente > 899.
               EVAL(bMsg,STR0085+STR0227) // No.Dias inválido
            EndIf

      End Case

      If !SY6->(DBSEEK(cFilSY6+AVKey(Int_CL->NCLCONDPG,"Y6_COD")+STR(VAL(Int_CL->NCLDIASPG),3,0)))
         EVAL(bMsg,STR0079+'/'+STR0085+STR0228) // Condicao de Pagto/No.Dias sem cadastro
      EndIf

   EndIf

ENDIF

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALCL")
ENDIF

IN100VerErro(cErro,cAviso)

IF Int_CL->NCLINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF

Return .T.

*--------------------*
FUNCTION IN100GrvCL()
*--------------------*
LOCAL cAlias

IF Int_CL->NCLTIPO # INCLUSAO
   SA1->(DBSEEK(cFilSA1+AVKey(Int_CL->NCLCOD,"A1_COD")+AVKey(Int_CL->NCLLOJA,"A1_LOJA")))
   IF SA1->(EOF()) .AND. Int_CL->NCLTIPO = ALTERACAO
      EVAL(bmsg,STR0008+STR0228+STR0058) // Cliente sem cadastro p/ alteração
      RETURN .T.
   ENDIF
   cAlias:=ALIAS()
   Reclock("SA1",.F.)
   DBSELECTAREA(cAlias)

   IF Int_CL->NCLTIPO = EXCLUSAO
      
      Begin sequence
        //eliminar descricoes em outro idioma
        If EE3->(DBSEEK(cFilEE3+CD_SA1+AVKey(SA1->A1_COD,"EE3_CONTAT")+AVKey(SA1->A1_LOJA,"EE3_COMPL"))) // BY JBJ Troca do campo EE3_LOJA
           While !EE3->(EOF()) .AND. ; 
                 cFilEE3+CD_SA1+AVKey(SA1->A1_COD,"EE3_CONTAT")+AVKey(SA1->A1_LOJA,"EE3_COMPL") == ; // BY JBJ Troca do campo EE3_LOJA
                 EE3->EE3_FILIAL+EE3->EE3_CODCAD+EE3->EE3_CONTAT+EE3->EE3_COMPL // BY JBJ Troca do campo EE3_LOJA
                 RECLOCK("EE3",.F.)
                 EE3->(DBDELETE())
                 EE3->(MsUnlock())
                 EE3->(DBSKIP(1))
           End
        EndIf
        MSMM(SA1->A1_CODMARC,,,,2)
        MSMM(SA1->A1_OBS,,,,2)

        If EasyEntryPoint("IN100CLI")  // TLM 09/06/2008
           ExecBlock("IN100CLI",.F.,.F.,"ANT_DEL_SA1")
        Endif

        Reclock("SA1",.F.)
        DBSELECTAREA(cAlias)
        SA1->(DBDELETE())
        SA1->(DBCOMMIT())
        SA1->(MSUNLOCK())  
      End Sequence
      
      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"EXCCL")
      EndIf
      
      RETURN .T.
      
   ENDIF
ENDIF

IF Int_CL->NCLTIPO = INCLUSAO
   IN100RecLock('SA1')
   SA1->A1_FILIAL := cFilSA1
   SA1->A1_COD    :=Int_CL->NCLCOD
   SA1->A1_LOJA   :=Int_CL->NCLLOJA
ENDIF

IF(!EMPTY(Int_CL->NCLNOME)    ,SA1->A1_NOME    :=Int_CL->NCLNOME   ,)
IF(!EMPTY(Int_CL->NCLNREDUZ)  ,SA1->A1_NREDUZ  :=Int_CL->NCLNREDUZ ,)
IF(!EMPTY(Int_CL->NCLEND)     ,SA1->A1_END     :=Int_CL->NCLEND    ,)
IF(!EMPTY(Int_CL->NCLBAIRRO)  ,SA1->A1_BAIRRO  :=Int_CL->NCLBAIRRO ,)
IF(!EMPTY(Int_CL->NCLCIDADE)  ,SA1->A1_MUN     :=Int_CL->NCLCIDADE ,)
IF(!EMPTY(Int_CL->NCLESTADO)  ,SA1->A1_ESTADO  :=Int_CL->NCLESTADO ,)
IF(!EMPTY(Int_CL->NCLPAIS)    ,SA1->A1_PAIS    :=Int_CL->NCLPAIS   ,)
IF(!EMPTY(Int_CL->NCLCEP)     ,SA1->A1_CEP     :=Int_CL->NCLCEP    ,)
IF(!EMPTY(Int_CL->NCLCP)      ,SA1->A1_CXPOSTA :=Int_CL->NCLCP     ,)
IF(!EMPTY(Int_CL->NCLTEL)     ,SA1->A1_TEL     :=Int_CL->NCLTEL    ,)
IF(!EMPTY(Int_CL->NCLTELEX)   ,SA1->A1_TELEX   :=Int_CL->NCLTELEX  ,)
IF(!EMPTY(Int_CL->NCLFAX)     ,SA1->A1_FAX     :=Int_CL->NCLFAX    ,)
IF(!EMPTY(Int_CL->NCLBANCO1)  ,SA1->A1_BCO1    :=Int_CL->NCLBANCO1 ,)
IF(!EMPTY(Int_CL->NCLBANCO2)  ,SA1->A1_BCO2    :=Int_CL->NCLBANCO2 ,)
IF(!EMPTY(Int_CL->NCLBANCO3)  ,SA1->A1_BCO3    :=Int_CL->NCLBANCO3 ,)
IF(!EMPTY(Int_CL->NCLBANCO4)  ,SA1->A1_BCO4    :=Int_CL->NCLBANCO4 ,)
IF(!EMPTY(Int_CL->NCLBANCO5)  ,SA1->A1_BCO5    :=Int_CL->NCLBANCO5 ,)
IF(!EMPTY(Int_CL->NCLEMAIL)   ,SA1->A1_EMAIL   :=Int_CL->NCLEMAIL  ,)
IF(!EMPTY(Int_CL->NCLHOMEPG)  ,SA1->A1_HPAGE   :=Int_CL->NCLHOMEPG ,)
IF(!EMPTY(Int_CL->NCLAGENTE)  ,SA1->A1_CODAGE  :=Int_CL->NCLAGENTE ,)
IF(!EMPTY(Int_CL->NCLCOMISS)  ,SA1->A1_COMAGE  :=Val(Int_CL->NCLCOMISS) ,)
IF(!EMPTY(Int_CL->NCLTIPOCLI) ,SA1->A1_TIPCLI  :=Padl(AT(Int_CL->NCLTIPOCLI,"ICNT"),1),) //MJB-SAP-1100
IF(!EMPTY(Int_CL->NCLDEST1)   ,SA1->A1_DEST_1  :=Int_CL->NCLDEST1  ,)
IF(!EMPTY(Int_CL->NCLDEST2)   ,SA1->A1_DEST_2  :=Int_CL->NCLDEST2  ,)
IF(!EMPTY(Int_CL->NCLDEST3)   ,SA1->A1_DEST_3  :=Int_CL->NCLDEST3  ,)
IF(!EMPTY(Int_CL->NCLCONDPG)  ,SA1->A1_CONDPAG :=Int_CL->NCLCONDPG ,)
IF(!EMPTY(Int_CL->NCLDIASPG)  ,SA1->A1_DIASPAG :=Val(Int_CL->NCLDIASPG) ,)

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVCL")
ENDIF
     
IF ! EMPTY(Int_CL->NCLMARCAC)
   IF Int_CL->NCLTIPO=INCLUSAO
      nNumMsmm+=1
   ENDIF
   MSMM(IF(Int_CL->NCLTIPO=ALTERACAO,SA1->A1_CODMARC,IF(lMsmm,STRZERO(nNumMsmm,6),)),TAMSX3("A1_VM_MARC")[1],,ALLTRIM(Int_CL->NCLMARCAC),1,,,"SA1","A1_CODMARC")
ENDIF

IF ! EMPTY(Int_CL->NCLOBS)
   IF Int_CL->NCLTIPO=INCLUSAO
      nNumMsmm+=1
   ENDIF
   MSMM(IF(Int_CL->NCLTIPO=ALTERACAO,SA1->A1_OBS,IF(lMsmm,STRZERO(nNumMsmm,6),)),TAMSX3("A1_VM_OBS")[1],,ALLTRIM(Int_CL->NCLOBS),1,,,"SA1","A1_OBS")
ENDIF

SA1->(MSUNLOCK())

Return .T.

*-----------------*
FUNCTION IN100It()
*-----------------*
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL cPictPesoL:= ALLTRIM(X3PICTURE("B1_PESO"))
LOCAL cPictNCM  := ALLTRIM(X3PICTURE("B1_POSIPI"))
EE2->(DBSETORDER(2))
SYC->(DBSETORDER(1))
SJ1->(DBSETORDER(1))
SJ2->(DBSETORDER(1))

AADD(TB_Cols,{{||IN100StaIte()}                                                  ,"",STR0086}) // Tem Idioma Rejeitado
AADD(TB_Cols,{{||TRAN(LEFT(Int_IT->NITCOD_I,TAMSX3("A5_PRODUTO")[1]),_PictItem)} ,"",STR0087}) // Código do Item
AADD(TB_Cols,{{||Int_IT->NITDESC_G}                                              ,"",STR0088}) // Descrição genérica 
AADD(TB_Cols,{{||Int_IT->NITUNI}                                                 ,"",STR0089}) // Unidade de Medida
AADD(TB_Cols,{{||Int_IT->NITLOCAL}                                               ,"",STR0090}) // Local Padrão
AADD(TB_Cols,{{||TRAN(Int_IT->NITNCM,cPictNCM)}                                  ,"",STR0091}) // Classificação NCM
AADD(TB_Cols,{{||Int_IT->NITEXNCM}                                               ,"",STR0092}) // EX NCM
AADD(TB_Cols,{{||Int_IT->NITEXNBM}                                               ,"",STR0093}) // EX NBM
AADD(TB_Cols,{{||TRAN(VAL(RIGHT(Int_IT->NITPESO_L,11)),cPictPesoL)}              ,"",STR0094}) // Peso Líquido
AADD(TB_Cols,{{||Int_IT->NITFAMILIA}                                             ,"",STR0095}) // Código da Família
AADD(TB_Cols,{{||Int_IT->NITEMBAL}                                               ,"",STR0096}) // Embalagem
AADD(TB_Cols,{{||Int_IT->NITQTDEMB}                                              ,"",STR0097}) // Quantidade na Embalagem
AADD(TB_Cols,{{||Int_IT->NITNALNCCA}                                             ,"",STR0098}) // NALADI NCCA
AADD(TB_Cols,{{||Int_IT->NITNALSH}                                               ,"",STR0099}) // NALADI SH

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLIT")
ENDIF
AADD(TB_Cols,{{||IN100E_Msg(.T.)}                 								 ,"",STR0046})

IN100ItID()                                                               //MJB-SAP-0101
RETURN .T.
*---------------------------------------------------------------------------------------
FUNCTION IN100ItID()                                                      //MJB-SAP-0101
*---------------------------------------------------------------------------------------
TB_Col_D:={}
AADD(TB_Col_D,{{|| IN100Status()}      ,"",STR0030}) // Status
AADD(TB_Col_D,{{|| NIDTIPO}            ,"",STR0100}) // Descrição
AADD(TB_Col_D,{{|| NIDCAD}             ,"",STR0101}) // Cadastro
AADD(TB_Col_D,{{|| NIDIDIOMA}          ,"",STR0102}) // Idioma
AADD(TB_Col_D,{{|| NIDDESCID}          ,"",STR0103}) // Descrição no Idioma

IF EasyEntryPoint("IN100CLI")  
   ExecBlock("IN100CLI",.F.,.F.,"COLID")
ENDIF
AADD(TB_Col_D,{ {|| IN100E_Msg(.T.)}   ,"",STR0046}) // Mensagem

RETURN .T.

*---------------------------*
FUNCTION IN100LerIT()
*---------------------------*
//Local lDetMsg:=.F.

Int_IT->NITMSG := ""

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERIT")
ENDIF

IF EMPTY(LEFT(Int_IT->NITCOD_I,TAMSX3("B1_COD")[1]))
   EVAL(bmsg,STR0087+STR0230) // Código do Item não informado
ENDIF

IF ! SB1->(DBSEEK(cFilSB1+LEFT(Int_IT->NITCOD_I,TAMSX3("B1_COD")[1])))
   IF Int_IT->NITTIPO = EXCLUSAO   //# INCLUSAO
      EVAL(bmsg,STR0087+STR0228)   // Código do Item sem cadastro
   ENDIF

   IF Int_IT->NITTIPO = ALTERACAO
      Int_IT->NITTIPO := INCLUSAO
   ENDIF

ELSEIF Int_IT->NITTIPO = INCLUSAO
       EVAL(bmsg,STR0087+STR0229)  // Código do Item com cadastro

ELSEIF Int_IT->NITTIPO == EXCLUSAO
      // Validacao na esclusao
ENDIF

IF Int_IT->NITTIPO == EXCLUSAO
   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALIT")
   ENDIF
   IN100VerErro(cErro,cAviso)
   IF Int_IT->NITINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF
   
   // TRP - 19/07/2012
   if type("bUpDate")=="B"  
      Int_ID->(DBSEEK(Int_IT->NITCOD_I))
    
      DO WHILE ! Int_ID->(EOF()) .AND. Int_ID->NIDCOD_I == Int_IT->NITCOD_I   
         Int_ID->NIDINT_OK := "T"
         
         cFuncao:="ID"
         Eval(bUpDate, Int_ID->NIDMSG,Int_ID->NIDINT_OK)
         cFuncao:="IT"
         
         Int_ID->(dbSkip())
      EndDo
   endif
   
   RETURN .T.
ENDIF

IF EMPTY(Int_IT->NITDESC_G) .AND. SB1->(EOF())
   EVAL(bmsg,STR0088+STR0230) // Descrição Genérica não informada
ENDIF

IF EMPTY(Int_IT->NITUNI) .AND. SB1->(EOF())
   EVAL(bmsg,STR0089+STR0230) // Unidade de Medida nao informada
ENDIF

IF ! EMPTY(Int_IT->NITUNI) .AND. ! SAH->(DBSEEK(cFilSAH+AVKey(Int_IT->NITUNI,"AH_UNIMED"))) 
   EVAL(bmsg,STR0089+STR0228) // Unidade de Medida sem cadastro
ENDIF         

IF ! EMPTY(ALLTRIM(Int_IT->NITNCM)) .AND. IN100NaoNum(Int_IT->NITNCM)
   EVAL(bmsg,STR0091+STR0227) // Classificação NCM inválido
ENDIF

IF ! EMPTY(ALLTRIM(Int_IT->NITEXNCM)) .AND. IN100NaoNum(Int_IT->NITEXNCM)
   EVAL(bmsg,STR0092+STR0227) // EX NCM Inválido
ENDIF

IF ! EMPTY(ALLTRIM(Int_IT->NITEXNBM)) .AND. IN100NaoNum(Int_IT->NITEXNBM)
   EVAL(bmsg,STR0093+STR0227) // EX NBM Inválido
ENDIF

IF ! EMPTY(Int_IT->NITEXNCM) .OR. ! EMPTY(Int_IT->NITNCM) .OR. ! EMPTY(Int_IT->NITEXNBM)
   If ! SYD->(DBSEEK(cFilSYD+Int_IT->NITNCM+Int_IT->NITEXNCM+Int_IT->NITEXNBM)) 
      EVAL(bmsg,STR0104+STR0228) // NCM/EX-NCM/EX-NBM sem cadastro
   EndIf
ENDIF

//IF ! EMPTY(ALLTRIM(Int_IT->NITPESO_L)) .AND. IN100NaoNum(Int_IT->NITPESO_L)
//   EVAL(bmsg,STR0094+STR0227) // "Peso Liquido Inválido
//ENDIF

IF ! EMPTY(Int_IT->NITFAMILIA) .AND. ! SYC->(DBSEEK(cFilSYC+AVKey(Int_IT->NITFAMILIA,"YC_COD"))) 
   EVAL(bmsg,STR0095+STR0228)  // Família sem cadastro
ENDIF

Int_IT->(IN100PE_EMB(NITEMBAL,NITQTDEMB,Int_IT->NITTIPO))                                 //MJB-SAP-1100

If ! EMPTY(Int_IT->NITNALNCCA) .AND. IN100NaoNum(Int_IT->NITNALNCCA)
   EVAL(bmsg,STR0098+STR0227) // NALADI NCCA inválida
ElseIf ! EMPTY(Int_IT->NITNALNCCA) .AND. ! SJ2->(DBSEEK(cFilSJ2+AVKey(Int_IT->NITNALNCCA,"J2_CODIGO"))) 
   EVAL(bmsg,STR0098+STR0228) // NALADI NCCA sem cadastro
ENDIF

If ! EMPTY(Int_IT->NITNALSH) .AND. IN100NaoNum(Int_IT->NITNALSH)
   EVAL(bmsg,STR0099+STR0227) // NALADI SH inválido
ElseIf ! EMPTY(Int_IT->NITNALSH) .AND. ! SJ1->(DBSEEK(cFilSJ1+AVKey(Int_IT->NITNALSH,"J1_CODIGO"))) 
   EVAL(bmsg,STR0099+STR0228) // NALADI SH sem cadastro
ENDIF

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALIT")
ENDIF

IN100VerErro(cErro,cAviso)

Int_IT->NITITEM_OK:="T"

//MJB-SAP-1100 IF lDetMsg .AND. Int_IT->NITTIPO == INCLUSAO

If ! Int_IT->(IN100PE_ID(NITCOD_I,.T.))                                   //MJB-SAP-1100
   Int_IT->NITINT_OK := "F"
   IF EMPTY(ALLTRIM(Int_IT->NITMSG))
      Int_IT->NITMSG := STR0107  // Aviso: .....Vide Idiomas
   Endif
ENDIF

//MJB-SAP-1100 IF EMPTY(ALLTRIM(Int_IT->NITMSG)) .AND. lDetMsg
//MJB-SAP-1100    Int_IT->NITMSG := STR0107  // Aviso: .....Vide Idiomas
//MJB-SAP-1100 ENDIF                                                         

IF Int_IT->NITINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF

IF Int_IT->NITINT_OK = "T" .AND. ! Int_IT->NITITEM_OK = "T"
   nResumoAlt+=1
ENDIF

Return .T.
*---------------------------------------------------------------------------------------
Function IN100PE_EMB(ItEmbal,ItQtdEmb,cTipo)                            //MJB-SAP-1100
*---------------------------------------------------------------------------------------
IF EMPTY(ItEmbal) .AND. SB1->(EOF())
   EVAL(bmsg,STR0096+STR0230) // Embalagem não informada
ENDIF

IF ! EMPTY(ItEmbal) .AND. ! EE5->(DBSEEK(cFilEE5+AVKey(ItEmbal,"EE5_CODEMB"))) 
   EVAL(bmsg,STR0096+STR0228) // Embalagem sem cadastro
ENDIF

IF EMPTY(ItQtdEmb) .AND. cTipo = INCLUSAO
   EVAL(bmsg,STR0097+STR0230) // Qtde Embalagem não informado
ENDIF

IF ! EMPTY(ItQtdEmb) .AND. IN100NaoNum(ItQtdEmb)
   EVAL(bmsg,STR0097+STR0227) // Qtde Embalagem inválida
ENDIF
Return 
*---------------------------------------------------------------------------------------
Function IN100PE_ID(cItCod_I,lEEC)                                        //MJB-SAP-1100
*---------------------------------------------------------------------------------------
Local lSemErro:=.T., cSaveCod
Local lBUpDate:= .F.

If Type("bUpDate") == "B"
   lBUpDate:= .T.
EndIf

cErro:=NIL ; cAviso:=NIL

Int_ID->(DBSEEK(Left(cItCod_I,Len(NIDCOD_I))))

cSaveCod:=Int_ID->NIDCOD_I

WHILE ! Int_ID->(EOF()) .AND. Int_ID->NIDCOD_I == cSaveCod

      IF EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"LERID")
      ENDIF
      
      IF EMPTY(Int_ID->NIDTIPO)
         EVAL(bmsg,STR0105+STR0230) // Tipo de Descrição não informado
      ENDIF
      
      IF ! EMPTY(Int_ID->NIDTIPO) .AND. Int_ID->NIDTIPO # "3"
         EVAL(bmsg,STR0105+STR0227) // Tipo de Descrição inválido
      ENDIF
      
      IF EMPTY(Int_ID->NIDCAD)
         EVAL(bmsg,STR0106+STR0230) // Tipo de Cadastro não informado
      ENDIF
      
      IF ! EMPTY(Int_ID->NIDCAD) .AND. Int_ID->NIDCAD # "*"
         EVAL(bmsg,STR0106+STR0227) // Tipo de Cadastro inválido
      ENDIF
      
      IF EMPTY(Int_ID->NIDIDIOMA)
         EVAL(bmsg,STR0102+STR0230) // Idioma não informado
      ElseIf ! SX5->(DBSEEK(cFilSX5+'ID'+Int_ID->NIDIDIOMA))
         EVAL(bmsg,STR0102+STR0228) // Idioma sem cadastro
      ENDIF

      IF EMPTY(Int_ID->NIDDESCID)
         EVAL(bmsg,STR0103+STR0230) // Descrição no Idioma não informado
      ENDIF
      
      IF EasyEntryPoint("IN100CLI")
         //	O parâmetro de chamada da validação deste tipo de interface estava errado, chamando a validação de Itens da 
         // Solicitação de Importação "VALSI" no lugar da validação da interface que está sendo executada neste momento,
         // que é a de IDIOMAS dos PRODUTOS DA EXPORTAÇÃO...
         ExecBlock("IN100CLI",.F.,.F.,"VALID")	//--- ADC 09/02/2011 "VALIS"
      ENDIF
      
      IF cErro # NIL
         Int_ID->NIDMSG:=cErro
         Int_ID->NIDINT_OK := "F"
         cErro:= NIL
         lSemErro:=.F.
         If lEEC
            If Int_IT->NITITEM_OK = "T"
         Int_IT->NITITEM_OK:="F"
      EndIf
         Else
            If Int_CI->NCIITEM_OK = "T"
               Int_CI->NCIITEM_OK:= "F"
            Endif
         EndIf
      ELSE
         Int_ID->NIDINT_OK:= "T"
         IF cAviso # NIL
            If(lEEC,Int_IT->NITMSG:=cAviso,Int_CI->NCIMSG:=cAviso)
            cAviso:= NIL
         ENDIF
      ENDIF
      
      //TRP - 19/07/2012
      //chamar a funçao do avinteg para o idioma do item, esta funçao grava na base os campos que não tratados pelo EICIN100
      IF lBUpDate
         cfuncao   :="ID"
         Eval(bUpDate, Int_ID->NIDMSG,Int_ID->NIDINT_OK)
         cfuncao   :="IT"
      ENDIF
      
      Int_ID->(DBSKIP())
EndDo

Return lSemErro
*--------------------*
FUNCTION IN100GrvIT()
*--------------------*
LOCAL cAlias, lAchouEE2:=.F.
Local lBUpDate:= .F.
PRIVATE cedcMAIL:="" //Alcir Alves - 04-05-05 - corpo do e-mail somente com os itens modificados
PRIVATE cedcBDM:="" //Alcir Alves - 05-05-05 - corpo do e-mail geral
PRIVATE cedcSubjc:="" //Alcir Alves - 05-05-05 - assunto do e-mail

If Type("bUpDate") == "B"
   lBUpDate:= .T.
EndIf

IF Int_IT->NITTIPO # INCLUSAO

   SB1->(DBSEEK(cFilSB1+LEFT(Int_IT->NITCOD_I,TAMSX3("B1_COD")[1])))
   IF SB1->(EOF()) .AND. Int_IT->NITTIPO = ALTERACAO
      EVAL(bmsg,STR0087+STR0228+STR0058) // Código do Item sem cadastro para alteração
      RETURN .T.
   ELSEIF SB1->(EOF()) .AND. Int_IT->NITTIPO = EXCLUSAO
      EVAL(bmsg,STR0087+STR0228) // Código do Item sem cadastro para alteração
      RETURN .T.
   ELSE
      //Alcir Alves - 04-05-05
      if EasyGParam("MV_ENVMAIL",,.F.)==.T. //Caso parametro para enviar e-mail        
         IF EasyGParam("MV_EEC_EDC",,.F.)==.T. //CASO EXISTA INTEGRAÇÃO DRAWBACK
            IF ED1->(DBSEEK(cFilED1+AVKEY(SB1->B1_COD,"ED1_ITEM")))          
               cedcMAIL:=""
               IF SB1->B1_DESC#AVKEY(Int_IT->NITDESC_G,"B1_DESC") //DESCRICAO 
                   cedcMAIL+=STR0333+SB1->B1_DESC+STR0334+Int_IT->NITDESC_G+chr(13)+chr(10)
               ENDIF
               IF SB1->B1_POSIPI#AVKEY(Int_IT->NITNCM,"B1_POSIPI")  //modificaçao de NCM
                   cedcMAIL+=STR0335+SB1->B1_POSIPI+STR0334+Int_IT->NITNCM+chr(13)+chr(10)
               ENDIF
               IF SB1->B1_UM#AVKEY(Int_IT->NITUNI,"B1_UM")  //modificaçao de UNIDADE DE MEDIDA
                   cedcMAIL+=STR0336+SB1->B1_UM+STR0334+Int_IT->NITUNI+chr(13)+chr(10)
               ENDIF
               cedcSubjc:=""
               If EasyEntryPoint("IN100CLI")                       
                  ExecBlock("IN100CLI",.F.,.F.,"PRODUTO_MODIFICADO_EMAIL")
               EndIf
               cedcBDM:=""
               IF !empty(cedcMAIL) //caso não esteja vazio quer dizer que houve modificação em no minimo algum item
                   cedcSubjc:=STR0337+SB1->B1_COD+STR0338
                   cedcBDM:=STR0339+chr(13)+chr(10)+cedcMAIL
                   lenv:=EICINmail(NIL,NIL,cedcSubjc,cedcBDM,NIL,NIL,NIL)
               ENDIF
            ENDIF
         ENDIF      
     Endif    
   ENDIF
   cAlias:=ALIAS()
   Reclock("SB1",.F.)
   DBSELECTAREA(cAlias)
   IF Int_IT->NITTIPO = EXCLUSAO      

      Begin Transaction
            
            //eliminar descricoes em outro idioma            
            If EE2->(DBSEEK(cFilEE2+MC_CPRO+TM_GER+AVKey(Int_IT->NITCOD_I,"EE2_COD")))
                While !EE2->(EOF()) .AND. ; 
                    cFilEE2+MC_CPRO+TM_GER+AVKey(Int_IT->NITCOD_I,"EE2_COD")=EE2->EE2_FILIAL+EE2->EE2_CODCAD+EE2->EE2_TIPMEN+EE2->EE2_COD
                    RECLOCK("EE2",.F.)
                    EE2->(DBDELETE())
                    EE2->(MsUnlock())
                    MSMM(EE2->EE2_TEXTO,,,,2)
                    EE2->(DBSKIP(1))
                End
            EndIf
            
            Reclock("SB1",.F.)
            DBSELECTAREA(cAlias)
            
            SA5->(DBSETORDER(2))
            SA5->(DBSEEK(cFilSA5+LEFT(Int_IT->NITCOD_I,TAMSX3("B1_COD")[1])))
            Do while ! SA5->(EOF()) .AND. ALLTRIM(LEFT(SA5->A5_PRODUTO,TAMSX3("A5_PRODUTO")[1]))==ALLTRIM(LEFT(Int_IT->NITCOD_I,TAMSX3("B1_COD")[1])).AND.SA5->A5_FILIAL==cFilSA5
               Reclock("SA5",.F.)
               SA5->(DBDELETE())
               SA5->(DBSKIP())
            Enddo
            
            SA5->(DBSETORDER(1))
            
            If EasyEntryPoint("IN100CLI")  // TLM 09/06/2008
                ExecBlock("IN100CLI",.F.,.F.,"ANT_DEL_SB1")
            Endif
                        
            DBSELECTAREA(cAlias)
            SB1->(DBDELETE())
            SB1->(DBCOMMIT())
            SB1->(MsUnlock())
      End Transaction
      
      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"EXCIT")
      EndIf
      
      RETURN .T.

   ENDIF
ENDIF

Begin Transaction

IF Int_IT->NITTIPO = INCLUSAO
   IN100RecLock('SB1')
   SB1->B1_FILIAL := cFilSB1
   SB1->B1_COD    := LEFT(Int_IT->NITCOD_I,TAMSX3("B1_COD")[1])
   SB1->B1_LOCPAD := '.'
ENDIF

IF(!EMPTY(Int_IT->NITDESC_G) ,SB1->B1_DESC   :=Int_IT->NITDESC_G,)
IF(!EMPTY(Int_IT->NITUNI)    ,SB1->B1_UM     :=Int_IT->NITUNI,)
IF(!EMPTY(Int_IT->NITLOCAL)  ,SB1->B1_LOCPAD :=Int_IT->NITLOCAL,)
IF(!EMPTY(Int_IT->NITNCM)    ,SB1->B1_POSIPI :=Int_IT->NITNCM,)
IF(!EMPTY(Int_IT->NITEXNCM)  ,SB1->B1_EX_NCM :=Int_IT->NITEXNCM,)
IF(!EMPTY(Int_IT->NITEXNBM)  ,SB1->B1_EX_NBM :=Int_IT->NITEXNBM,)
IF(VAL(Int_IT->NITPESO_L)>0  ,SB1->B1_PESO   :=VAL(Int_IT->NITPESO_L),)
IF(!EMPTY(Int_IT->NITFAMILIA),SB1->B1_FPCOD  :=Int_IT->NITFAMILIA,)
IF(!EMPTY(Int_IT->NITEMBAL)  ,SB1->B1_CODEMB :=Int_IT->NITEMBAL,)
IF(!EMPTY(Int_IT->NITQTDEMB) ,SB1->B1_QE     :=Val(Int_IT->NITQTDEMB),)
IF(!EMPTY(Int_IT->NITNALNCCA),SB1->B1_NALNCCA:=Int_IT->NITNALNCCA,)
IF(!EMPTY(Int_IT->NITNALSH)  ,SB1->B1_NALSH  :=Int_IT->NITNALSH,)

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVIT")
ENDIF

Int_ID->(DBSEEK(Int_IT->NITCOD_I))

WHILE ! Int_ID->(EOF()) .AND. Int_ID->NIDCOD_I == Int_IT->NITCOD_I 
      
      IF ! Int_ID->NIDINT_OK = "T"
         Int_ID->(DBSKIP())
         LOOP
      ENDIF
                                                                              
      If EE2->(DBSEEK(cFilEE2+MC_CPRO+TM_GER+AVKey(Int_IT->NITCOD_I,"EE2_COD")+AVKey(INIDIOMA(Int_ID->NIDIDIOMA),"EE2_IDIOMA")))
         RECLOCK("EE2",.F.)         
         If EMPTY(ALLTRIM(EE2->EE2_TEXTO))
            lAchouEE2:=.F. 
         Else
            lAchouEE2:=.T. 
         EndIf
         
      Else   
         RECLOCK("EE2",.T.)
         lAchouEE2:=.F.
      EndIf
      EE2->EE2_CODCAD  := Int_ID->NIDTIPO
      EE2->EE2_TIPMEN  := Int_ID->NIDCAD
      EE2->EE2_COD     := Int_ID->NIDCOD_I
      EE2->EE2_IDIOMA  := INIDIOMA(Int_ID->NIDIDIOMA)
      
      IF ! lAchouEE2
         nNumMsmm+=1
      ENDIF
      
      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"GRVID")
      ENDIF
      
      MSMM(IF(lAchouEE2,EE2->EE2_TEXTO,IF(lMsmm,STRZERO(nNumMsmm,6),)),TAMSX3("EE2_VM_TEX")[1],,ALLTRIM(Int_ID->NIDDESCID),1,,,"EE2","EE2_TEXTO")
      
      //igor chiba 23/12/2010
      //chamar a funçao do avinteg para o idioma do item, esta funçao grava na base os campos que não tratados pelo EICIN100
      If lBUpDate
         oldcfuncao:=cfuncao
         cfuncao   :="ID"
          EasyExRdm("AvIntExtra")
         cfuncao   :=oldcfuncao
      ENDIF

      EE2->(MsUnlock())
      Int_ID->(DBSKIP())
EndDo

SB1->(MSUNLOCK())    

End Transaction

Return .T.

*-----------------*
FUNCTION IN100LK()
*-----------------*
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL _PictPrUn := ALLTRIM(X3PICTURE("A5_VLCOTUS"))

AADD(TB_Cols,{ {||TRAN(LEFT(NLKCOD_I,TAMSX3("A5_PRODUTO")[1]),_PictItem)},"",STR0087}) // Código do Item
AADD(TB_Cols,{ {||NLKFABR}                                               ,"",STR0108}) // Código do Fabricante
AADD(TB_Cols,{ {||NLKLOJAFA}                                             ,"",STR0109}) // Loja do Fabricante
AADD(TB_Cols,{ {||NLKFORN}                                               ,"",STR0110}) // Código do Fornecedor
AADD(TB_Cols,{ {||NLKLOJAFO}                                             ,"",STR0111}) // Loja do Fornecedor
AADD(TB_Cols,{ {||NLKPART_N}                                             ,"",STR0112}) // Código Item no Fornededor
AADD(TB_Cols,{ {||NLKMOEDA}                                              ,"",STR0113}) // Moeda da Cotação
AADD(TB_Cols,{ {||TRAN(VAL(NLKVLCOT_U),_PictPrUn) }                      ,"",STR0114}) // Valor da cotação
AADD(TB_Cols,{ {||NLKLEAD_T}                                             ,"",STR0115}) // Lead Time de entrega
AADD(TB_Cols,{ {||NLKQT_COT}                                             ,"",STR0116}) // Quantidade cotada
AADD(TB_Cols,{ {||IN100CTD(NLKULT_ENT,,'DDMMAAAA',LEN(NLKULT_ENT))}      ,"",STR0117}) // Data da última entrega //MJB-SAP-1100
AADD(TB_Cols,{ {||TRAN(VAL(NLKLOTE_MI),'@E 99,999.99')}                  ,"",STR0118}) // Lote mínimo
AADD(TB_Cols,{ {||TRAN(VAL(NLKLOTE_MU),'@E 99,999.99')}                  ,"",STR0119}) // Múltiplos do lote
AADD(TB_Cols,{ {||NLKPART_OP}                                            ,"",STR0120}) // Part-Number opcional
AADD(TB_Cols,{ {||NLKUNID}                                               ,"",STR0121}) // Unidade

ASIZE(TBRCols,0)
AADD(TBRCols,{ {||IN100Status()}                         ,STR0030}) // Status
AADD(TBRCols,{ {||IN100Tipo()}                           ,STR0044}) // CNPJ/CPF
AADD(TBRCols,{ {||IN100CTD(NLKINT_DT,,'DDMMAAAA',LEN(NLKINT_DT))},STR0045}) // Tipo //MJB-SAP-1100
AADD(TBRCols,{ {||TRAN(NLKCOD_I,_PictItem)}              ,STR0087}) // Código do Item
AADD(TBRCols,{ {||NLKFABR}                               ,STR0108}) // Código do Fabricante
AADD(TBRCols,{ {||NLKLOJAFA}                             ,STR0109}) // Loja do Fabricante
AADD(TBRCols,{ {||NLKFORN}                               ,STR0110}) // Código do Fornecedor
AADD(TBRCols,{ {||NLKLOJAFO}                             ,STR0111}) // Loja do Fornecedor
AADD(TBRCols,{ {||NLKPART_N}                             ,STR0112}) // Código Item no Fornededor
AADD(TBRCols,{ {||NLKUNID}                               ,STR0121}) // Unidade

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLLK")
ENDIF
AADD(TB_Cols,{ {|| IN100E_Msg(.T.) }                     , "", STR0046}) // Mensagem

RETURN .T.

*--------------------*
FUNCTION IN100LerLK()
*--------------------*
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERLK")
ENDIF

IF EMPTY(LEFT(Int_LK->NLKCOD_I,TAMSX3("A5_PRODUTO")[1]))
   EVAL(bmsg,STR0087+STR0230) // Código do Item não informado
ENDIF

IF ! SB1->(DBSEEK(cFilSB1+LEFT(Int_LK->NLKCOD_I,TAMSX3("A5_PRODUTO")[1]) ))
   EVAL(bMsg,STR0087+ALLTRIM(LEFT(Int_LK->NLKCOD_I,TAMSX3("A5_PRODUTO")[1])) + STR0228) // Item xxx sem cadastro
ENDIF

IF EMPTY(Int_LK->NLKFABR)
   EVAL(bmsg,STR0108+STR0230) // Código do Fabricante não informado
ENDIF

IF EMPTY(Int_LK->NLKLOJAFA)
   EVAL(bmsg,STR0109+STR0230) // Loja do Fabricante não informado
ENDIF

IF ! EMPTY(Int_LK->NLKFABR) .AND. ! EMPTY(Int_LK->NLKLOJAFA)
   If ! SA2->(DBSEEK(cFilSA2+AVKey(Int_LK->NLKFABR,"A2_COD")+AVKey(Int_LK->NLKLOJAFA,"A2_LOJA")))
      EVAL(bMsg,STR0122+STR0228) // Fabricante/Loja sem cadastro
   ElseIf AT(Left(SA2->A2_ID_FBFN,1),'13') = 0
      EVAL(bMsg,STR0123) // Fabricante cadastrado como fornecedor
   EndIf
ENDIF

IF EMPTY(Int_LK->NLKFORN)
   EVAL(bmsg,STR0110+STR0230) // Código do Fornecedor não informado
ENDIF

IF !Empty(Int_LK->NLKFORN) .And. EMPTY(Int_LK->NLKLOJAFO)
   EVAL(bmsg,STR0111+STR0230) // Loja do Fornecedor não informado
ENDIF

IF ! EMPTY(Int_LK->NLKFORN) .AND. ! EMPTY(Int_LK->NLKLOJAFO)                                     
   If ! SA2->(DBSEEK(cFilSA2+AVKey(Int_LK->NLKFORN,"A2_COD")+AVKey(Int_LK->NLKLOJAFO,"A2_LOJA")))
      EVAL(bMsg,STR0124+STR0228) // Fornecedor sem cadastro
   ElseIf AT(Left(SA2->A2_ID_FBFN,1),'23') = 0
      EVAL(bMsg,STR0125) // Fornecedor Cadastrado como Fabricante
   ENDIF

ENDIF                          

SA5->( DbSetOrder( 3 ) )
                                                                                                 
IF ! SA5->(DBSEEK(cFilSA5+LEFT(Int_LK->NLKCOD_I,TAMSX3("A5_PRODUTO")[1])+AVKey(Int_LK->NLKFABR,"A5_FABR")+AVKey(Int_LK->NLKFORN,"A5_FORNECE")+AVKey(Int_LK->NLKLOJAFO,"A5_LOJA")))

   IF Int_LK->NLKTIPO = EXCLUSAO  //# INCLUSAO
      EVAL(bMsg,+STR0228) // Ligacao Item/Fabr/Forn sem cadastro
   ENDIF

   IF Int_LK->NLKTIPO = ALTERACAO
      Int_LI->NLKTIPO := INCLUSAO
   ENDIF

ELSEIF Int_LK->NLKTIPO = INCLUSAO
   EVAL(bMsg,STR0126+STR0229) // Ligação Item/Fabr/Forn já cadastrado

ELSEIF Int_LK->NLKTIPO == EXCLUSAO
   // Validacao da Exclusao
ENDIF

SA5->( DbSetOrder( 1 ) )

IF Int_LK->NLKTIPO == EXCLUSAO
   IF EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"VALLK")
   ENDIF
   IN100VerErro(cErro,cAviso)
   IF Int_LK->NLKINT_OK = "T"
      nResumoCer+=1
   ELSE
      nResumoErr+=1
   ENDIF
   RETURN .T.
ENDIF

IF ! EMPTY(Int_LK->NLKMOEDA) .AND. ! SYF->(DBSEEK(cFilSYF+AVKey(Int_LK->NLKMOEDA,"YF_MOEDA")))
   EVAL(bMsg,STR0127+STR0228) // Moeda sem cadastro
ENDIF

IF ! EMPTY(Int_LK->NLKUNID) .AND.  ! SAH->(DBSEEK(cFilSAH+AVKey(Int_LK->NLKUNID,"AH_UNIMED")))
   EVAL(bmsg,STR0089+STR0228) // Unidade Medida sem cadastro
ENDIF

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALLK")
ENDIF
IN100VerErro(cErro,cAviso)

IF Int_LK->NLKINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF

Return .T.

*--------------------*
FUNCTION IN100GrvLK()
*--------------------*
LOCAL cAlias

IF Int_LK->NLKTIPO # INCLUSAO

   SA5->( DbSetOrder( 3 ) )

   SA5->(DBSEEK(cFilSA5+LEFT(Int_LK->NLKCOD_I,TAMSX3("A5_PRODUTO")[1])+AVKey(Int_LK->NLKFABR,"A5_FABR")+AVKey(Int_LK->NLKFORN,"A5_FORNECE")))

   SA5->( DbSetOrder( 1 ) )

   IF SA5->(EOF())  .AND.  Int_LK->NLKTIPO = ALTERACAO
      EVAL(bmsg,STR0126+STR0228+STR0058) // Ligação Item/Fabr/Forn p/ Alteração
      RETURN .T.
   ENDIF

   cAlias:=ALIAS()
   Reclock("SA5",.F.)
   DBSELECTAREA(cAlias)

   IF Int_LK->NLKTIPO = EXCLUSAO
      SA5->(DBDELETE())
      SA5->(DBCOMMIT())
      SA5->(MSUNLOCK())
      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"EXCLK")
      EndIf
      
      RETURN .T.
   ENDIF
ENDIF


IF Int_LK->NLKTIPO = INCLUSAO
   IN100RecLock('SA5')
   SA5->A5_FILIAL   := cFilSA5
   SA5->A5_PRODUTO  := LEFT(Int_LK->NLKCOD_I,TAMSX3("A5_PRODUTO")[1])
   SA5->A5_FABR     := Int_LK->NLKFABR
   SA5->A5_FORNECE  := Int_LK->NLKFORN
   SA5->A5_LOJA     := Int_LK->NLKLOJAFO
   SA5->A5_FALOJA   := Int_LK->NLKLOJAFA
ENDIF

IF(!EMPTY(Int_LK->NLKPART_N)           ,SA5->A5_CODPRF  := Int_LK->NLKPART_N,)
IF(!EMPTY(Int_LK->NLKMOEDA)            ,SA5->A5_MOE_US  := Int_LK->NLKMOEDA,)
IF(VAL(Int_LK->NLKVLCOT_U)#0           ,SA5->A5_VLCOTUS := VAL(Int_LK->NLKVLCOT_U),)
IF(VAL(Int_LK->NLKLEAD_T)#0            ,SA5->A5_LEAD_T  := VAL(Int_LK->NLKLEAD_T),)
IF(VAL(Int_LK->NLKQT_COT)#0            ,SA5->A5_QT_COT  := VAL(Int_LK->NLKQT_COT),)
IF(!EMPTY(IN100CTD(Int_LK->NLKULT_ENT)),SA5->A5_ULT_ENT := IN100CTD(Int_LK->NLKULT_ENT),)
IF(VAL(Int_LK->NLKLOTE_MIN)#0          ,SA5->A5_LOTEMIN := VAL(Int_LK->NLKLOTE_MIN),)
IF(VAL(Int_LK->NLKLOTE_MUL)#0          ,SA5->A5_LOTEMUL := VAL(Int_LK->NLKLOTE_MUL),)
IF(!EMPTY(Int_LK->NLKPART_OPC)         ,SA5->A5_PARTOPC := Int_LK->NLKPART_OPC,)
IF(!EMPTY(Int_LK->NLKUNID)             ,SA5->A5_UNID    := Int_LK->NLKUNID,)

// LCS - 26/11/2001
SA5->A5_NOMEFOR := POSICIONE("SA2",1,cFilSA2+SA5->(A5_FORNECE+A5_LOJA),"A2_NOME")
SA5->A5_NOMPROD := POSICIONE("SB1",1,cFilSB1+SA5->A5_PRODUTO,"B1_DESC")

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVLK")
EndIf

SA5->(MSUNLOCK())

Return .T.

*-----------------*
FUNCTION IN100PE()
*-----------------*
SYC->(DBSETORDER(4))
EE9->(DBSETORDER(1))
EEF->(DBSETORDER(1))
SJ1->(DBSETORDER(1))
SJ2->(DBSETORDER(1))
SYJ->(DBSETORDER(1))
SYQ->(DBSETORDER(1))
SYR->(DBSETORDER(1))

/** By JBJ - 06/03/03 - (Inclusão de Campos)
AADD(TB_Cols,{{||IN100StaIte()}                 ,"",STR0128}) // Tem Item Rejeitado
AADD(TB_Cols,{{||Int_PE->NPEPEDIDO}             ,"",STR0129}) // Código do Processo
AADD(TB_Cols,{{||IN100CTD(Int_PE->NPEDTPROC)}   ,"",STR0130}) // Data do Processo
AADD(TB_Cols,{{||IN100CTD(Int_PE->NPEDTPEDI)}   ,"",STR0131}) // Data do Pedido
AADD(TB_Cols,{{||Int_PE->NPEIMPORT}             ,"",STR0132}) // Código Import.
AADD(TB_Cols,{{||Int_PE->NPEIMLOJA}             ,"",STR0133}) // Loja Import.
AADD(TB_Cols,{{||If(Int_PE->NPEEXLIMP$cSim,STR0028,If(Int_PE->NPEEXLIMP$cNao,STR0029,Int_PE->NPEEXLIMP))},"",STR0134+" ?"}) // Exige LI ?
AADD(TB_Cols,{{||Int_PE->NPEFORN}               ,"",STR0110}) // Código Fornec.
AADD(TB_Cols,{{||Int_PE->NPEFOLOJA}             ,"",STR0111}) // Loja Fornec.
AADD(TB_Cols,{{||Int_PE->NPERESPON}             ,"",STR0135}) // Analista Resp.
AADD(TB_Cols,{{||Int_PE->NPEEXPORT}             ,"",STR0136}) // Código Export.
AADD(TB_Cols,{{||Int_PE->NPEEXLOJA}             ,"",STR0137}) // Loja Export.
AADD(TB_Cols,{{||Int_PE->NPECONDPA}             ,"",STR0079}) // Cond. Pag.
AADD(TB_Cols,{{||Int_PE->NPEDIASPA}             ,"",STR0080}) // Dias Pag.
AADD(TB_Cols,{{||Int_PE->NPEINCOTE}             ,"",STR0138}) // Incoterm
AADD(TB_Cols,{{||Int_PE->NPEVIA}                ,"",STR0139}) // Via Transp.
AADD(TB_Cols,{{||Int_PE->NPEORIGEM}             ,"",STR0140}) // Porto saída
AADD(TB_Cols,{{||Int_PE->NPEDEST}               ,"",STR0141}) // Porto chegada
AADD(TB_Cols,{{||Int_PE->NPEMOEDA}              ,"",STR0127}) // Moeda
AADD(TB_Cols,{{||Int_PE->NPEIDIOMA}             ,"",STR0142}) // Idioma Documentos
AADD(TB_Cols,{{||If(Int_PE->NPEPGTANT$cSim,STR0028,If(Int_PE->NPECALCEM$cNao,STR0029,Int_PE->NPECALCEM))},"",STR0143}) // Pag.Antec.
AADD(TB_Cols,{{||If(Int_PE->NPETIPCOM="1",STR0144,If(Int_PE->NPETIPCOM="2",STR0145,If(Int_PE->NPETIPCOM="3",STR0146,Int_PE->NPETIPCOM)))},"",STR0147}) // A Remeter    Conta Gráfica    Deduzir da Fatura    Tipo Comis.
AADD(TB_Cols,{{||If(Int_PE->NPETIPCVL="1",STR0148,If(Int_PE->NPETIPCVL="2",STR0149,If(Int_PE->NPETIPCVL="3",STR0150,If(Int_PE->NPETIPCVL="4",STR0151,Int_PE->NPETIPCVL))))},"",STR0152}) // Percentual   Valor Fixo   Valor s/Unidade    Outros    Tipo Valor Comiss.
AADD(TB_Cols,{{||Int_PE->NPEVALCOM}             ,"",STR0153}) // Comissão
*/

AADD(TB_Cols,{{|| IN100StaIte()}                           ,"",STR0128}) // Tem Item Rejeitado
AADD(TB_Cols,{{|| Int_PE->NPEPEDIDO}                       ,"",STR0129}) // Código do Processo
AADD(TB_Cols,{{|| IN100CTD(Int_PE->NPEDTPROC)}             ,"",STR0130}) // Data do Processo
AADD(TB_Cols,{{|| IN100CTD(Int_PE->NPEDTPEDI)}             ,"",STR0131}) // Data do Pedido
AADD(TB_Cols,{{|| If(Int_PE->NPEAMOSTR == "1",STR0028,STR0029)},"",STR0201   }) //"Sim"###"Não"###"Amostra"
AADD(TB_Cols,{{|| IN100CTD(Int_PE->NPEFIM_PE)}             ,"",STR0257}) //"Finalizado"
AADD(TB_Cols,{{|| IN100CTD(Int_PE->NPEDTSLCR)}             ,"",STR0258}) //"Dt.Sol.Credito"
AADD(TB_Cols,{{|| Int_PE->NPEIMPORT}                       ,"",STR0132}) // Código Import.
AADD(TB_Cols,{{|| Int_PE->NPEIMLOJA}                       ,"",STR0133}) // Loja Import.
AADD(TB_Cols,{{|| Int_PE->NPEIMPODE}                       ,"",STR0259}) //"Desc.Import."
AADD(TB_Cols,{{|| Int_PE->NPEENDIMP}                       ,"",STR0260}) //"End. Import."
AADD(TB_Cols,{{|| Int_PE->NPEREFIMP}                       ,"",STR0261}) //"Ref. Import."
AADD(TB_Cols,{{|| If(Int_PE->NPEEXLIMP$cSim,STR0028,If(Int_PE->NPEEXLIMP$cNao,STR0029,Int_PE->NPEEXLIMP))},"",STR0134+" ?"}) // Exige LI ?
AADD(TB_Cols,{{|| Int_PE->NPELICIMP}                      ,"",STR0262}) //"LI"
AADD(TB_Cols,{{|| IN100CTD(Int_PE->NPEDTLIMP)}            ,"",STR0263}) //"Dt.LI"
AADD(TB_Cols,{{|| Int_PE->NPECLIENT}                      ,"",STR0264}) //"Código Cliente"
AADD(TB_Cols,{{|| Int_PE->NPECLLOJA}                      ,"",STR0265}) //"Loja Cliente"
AADD(TB_Cols,{{|| Int_PE->NPEFORN}                        ,"",STR0110}) // Código Fornec.
AADD(TB_Cols,{{|| Int_PE->NPEFOLOJA}                      ,"",STR0111}) // Loja Fornec.
AADD(TB_Cols,{{|| Int_PE->NPERESPON}                      ,"",STR0135}) // Analista Resp.
AADD(TB_Cols,{{|| Int_PE->NPEEXPORT}                      ,"",STR0136}) // Código Export.
AADD(TB_Cols,{{|| Int_PE->NPEEXLOJA}                      ,"",STR0137}) // Loja Export.
AADD(TB_Cols,{{|| Int_PE->NPECONSIG}                      ,"",STR0266}) //"Código Consig."
AADD(TB_Cols,{{|| Int_PE->NPECOLOJA}                      ,"",STR0267}) //"Loja Consig."
AADD(TB_Cols,{{|| Int_PE->NPEBENEF}                       ,"",STR0268}) //"Código Benef."
AADD(TB_Cols,{{|| Int_PE->NPEBELOJA}                      ,"",STR0269}) //"Loja Benef."
AADD(TB_Cols,{{|| Int_PE->NPEBENEDE}                      ,"",STR0270}) //"Desc.Benef."
AADD(TB_Cols,{{|| Int_PE->NPEENDBEN}                      ,"",STR0271}) //"End. Benef."
AADD(TB_Cols,{{|| Int_PE->NPECONDPA}                      ,"",STR0079}) // Cond. Pag.
AADD(TB_Cols,{{|| Int_PE->NPEDIASPA}                      ,"",STR0080}) // Dias Pag.
AADD(TB_Cols,{{|| Int_PE->NPEMPGEXP}                      ,"",STR0272}) //"Modal.Pag.Ext"
AADD(TB_Cols,{{|| Int_PE->NPEINCOTE}                      ,"",STR0138}) // Incoterm
AADD(TB_Cols,{{|| Int_PE->NPEVIA}                         ,"",STR0139}) // Via Transp.
AADD(TB_Cols,{{|| Int_PE->NPEORIGEM}                      ,"",STR0140}) // Porto saída
AADD(TB_Cols,{{|| Int_PE->NPEDEST}                        ,"",STR0141}) // Porto chegada
AADD(TB_Cols,{{|| If(Int_PE->NPETIPTRA="1",STR0273,If(Int_PE->NPETIPTRA="2",STR0274,STR0275))},"",STR0276}) //"Cheio"###"Picados"###"Carga Solta"###"Tipo Transporte"
AADD(TB_Cols,{{|| Int_PE->NPEMOEDA}                       ,"",STR0127}) // Moeda

// ** By JBJ - 15/10/2003.
AADD(TB_Cols,{{|| If(Int_PE->NPEFRPPCC="CC",STR0277,If(Int_PE->NPEFRPPCC="PP",STR0278,""))},"",STR0198}) //"Collect"###"Prepaid"###"Tipo Frete"
//AADD(TB_Cols,{{|| If(Int_PE->NPEFRPPCC="CC",STR0277,STR0278 )},"",STR0198}) //"Collect"###"Prepaid"###"Tipo Frete"

AADD(TB_Cols,{{|| Int_PE->NPEFRPREV}                       ,"",STR0279}) //"Frete"
AADD(TB_Cols,{{|| Int_PE->NPEFRPCOM}                       ,"",STR0153}) //"Comissão"
AADD(TB_Cols,{{|| Int_PE->NPESEGPRE}                       ,"",STR0280}) //"Seguro"
AADD(TB_Cols,{{|| Int_PE->NPEDESPIN}                       ,"",STR0281}) //"Desp.Int."
AADD(TB_Cols,{{|| Int_PE->NPEDESCON}                       ,"",STR0282}) //"Desconto"
AADD(TB_Cols,{{|| If(Int_PE->NPEPRECOA $ cSim, STR0028, STR0029)},"",STR0283}) //"Sim"###"Não"###"Preco Aberto"
AADD(TB_Cols,{{|| Int_PE->NPEEMBAFI}                       ,"",STR0178}) //"Volume"
AADD(TB_Cols,{{|| If(Int_PE->NPECALCEM $ cSim, STR0028, STR0029)},"",STR0284}) //"Sim"###"Não"###"Calc.Embal."
AADD(TB_Cols,{{|| If(Int_PE->NPECALCEM $ cSim, STR0028, STR0029)},"",STR0285}) //"Sim"###"Não"###"Cubagem"
AADD(TB_Cols,{{|| If(Int_PE->NPECALCEM $ cSim, STR0028, STR0029)},"",STR0285}) //"Sim"###"Não"###"Cubagem"
AADD(TB_Cols,{{|| Int_PE->NPEIDIOMA}               ,"",STR0142}) // Idioma Documentos
AADD(TB_Cols,{{|| IN100CTD(Int_PE->NPESL_LC)}      ,"",STR0286}) //"Dt.Sol.L/C"
AADD(TB_Cols,{{|| Int_PE->NPELC_NUM}               ,"",STR0287}) //"No. L/C"
AADD(TB_Cols,{{|| IN100CTD(Int_PE->NPESL_EME)}     ,"",STR0288}) //"Dt.Sl.Emenda"
AADD(TB_Cols,{{|| If(Int_PE->NPEPGTANT$cSim,STR0028,If(Int_PE->NPECALCEM$cNao,STR0029,Int_PE->NPECALCEM))},"",STR0143}) // Pag.Antec.
AADD(TB_Cols,{{|| If(Int_PE->NPETIPCOM="1",STR0144,If(Int_PE->NPETIPCOM="2",STR0145,If(Int_PE->NPETIPCOM="3",STR0146,Int_PE->NPETIPCOM)))},"",STR0147}) // A Remeter    Conta Gráfica    Deduzir da Fatura    Tipo Comis.
AADD(TB_Cols,{{|| If(Int_PE->NPETIPCVL="1",STR0148,If(Int_PE->NPETIPCVL="2",STR0149,If(Int_PE->NPETIPCVL="3",STR0150,If(Int_PE->NPETIPCVL="4",STR0151,Int_PE->NPETIPCVL))))},"",STR0152}) // Percentual   Valor Fixo   Valor s/Unidade    Outros    Tipo Valor Comiss.
AADD(TB_Cols,{{|| Int_PE->NPEVALCOM}               ,"",STR0153}) // Comissão

If Int_PE->(FieldPos("NPENOTIFY")) > 0
   AADD(TB_Cols,{{|| Int_PE->NPENOTIFY}            ,"",STR0289}) //"Código Notify"
EndIf

If Int_PE->(FieldPos("NPENOLOJA")) > 0
   AADD(TB_Cols,{{|| Int_PE->NPENOLOJA}            ,"",STR0290}) //"Loja Notify"
EndIf

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLPE")
ENDIF
AADD(TB_Cols,{{||IN100E_Msg(.T.)}               ,"",STR0046}) // Mensagem

TB_Col_D:={}

/** By JBJ - 06/03/03 - (Inclusão de Campos)
AADD(TB_Col_D,{{|| IN100Status()},"",STR0030}) // Status.
AADD(TB_Col_D,{{|| IN100TIPO() } ,"",STR0044}) // Tipo.
AADD(TB_Col_D,{{|| NPDCOD_I}     ,"",STR0087}) // Código do Item.
AADD(TB_Col_D,{{|| NPDDECIT}     ,"",STR0154}) // Desc.item.
AADD(TB_Col_D,{{|| NPDFORN}      ,"",STR0110}) // Código Fornec.
AADD(TB_Col_D,{{|| NPDFOLOJA}    ,"",STR0111}) // Loja do Fornec.
AADD(TB_Col_D,{{|| NPDFABR}      ,"",STR0108}) // Código Fabr.
AADD(TB_Col_D,{{|| NPDFALOJA}    ,"",STR0109}) // Loja do Fabr.
AADD(TB_Col_D,{{|| NPDUNIDAD}    ,"",STR0089}) // Unidade Medida.
AADD(TB_Col_D,{{|| TRAN(VAL(NPDSLDINI),AVSX3("EE8_SLDINI",6))} ,"",STR0155}) // Quantidade
AADD(TB_Col_D,{{|| TRAN(VAL(NPDPRECO),AVSX3("EE8_PRECO",6))}   ,"",STR0156}) // Preço Unit.
AADD(TB_Col_D,{{|| TRAN(VAL(NPDPSLQUN),AVSX3("EE8_PSLQUN",6))} ,"",STR0157}) // Peso Líquido Unit.
AADD(TB_Col_D,{{|| TRAN(VAL(NPDPSLQTO),AVSX3("EE8_PSLQTO",6))} ,"",STR0158}) // Peso Bruto Unit.
AADD(TB_Col_D,{{|| TRAN(NPDPOSIPI,AVSX3("EE8_POSIPI",6))}      ,"",STR0091}) // NCM
AADD(TB_Col_D,{{|| NPDNLNCCA}                                  ,"",STR0098}) // NALADI NCCA
AADD(TB_Col_D,{{|| NPDNALSH}                                   ,"",STR0099}) // NALADI SH
*/

AADD(TB_Col_D,{{|| IN100Status()}       ,"", STR0030})        // Status
AADD(TB_Col_D,{{|| IN100TIPO() }        ,"", STR0044})        // Tipo
AADD(TB_Col_D,{{|| NPDCOD_I}            ,"", STR0087})        // Código do Item
AADD(TB_Col_D,{{|| NPDDECIT}            ,"", STR0154})        // Desc.item
AADD(TB_Col_D,{{|| NPDFORN}             ,"", STR0110})        // Código Fornec
AADD(TB_Col_D,{{|| NPDFOLOJA}           ,"", STR0111})        // Loja do Fornec
AADD(TB_Col_D,{{|| NPDPART_N}           ,"", STR0291}) //"Part-Number"
AADD(TB_Col_D,{{|| IN100CTD(NPDDTPREM)} ,"", STR0292}) //"Dt.Prev.Emb."
AADD(TB_Col_D,{{|| IN100CTD(NPDDTENTR)} ,"", STR0293}) //"Dt.Entrega"
AADD(TB_Col_D,{{|| NPDFABR}             ,"",STR0108})         // Código Fabr.
AADD(TB_Col_D,{{|| NPDFALOJA}           ,"",STR0109})         // Loja do Fabr.
AADD(TB_Col_D,{{|| NPDUNIDAD}           ,"",STR0089})         // Unidade Medida
AADD(TB_Col_D,{{|| TRAN(VAL(NPDSLDINI)  ,AVSX3("EE8_SLDINI",6))} ,"",STR0155}) // Quantidade
AADD(TB_Col_D,{{|| NPDEMBAL1}           ,"",STR0096}) //"Embalagem"
AADD(TB_Col_D,{{|| Transf(Val(NPDQE)    ,AVSX3("EE8_QE",6))}     ,"",STR0294}) //"Qt.na Embal."
AADD(TB_Col_D,{{|| Transf(Val(NPDQTDEM1),AVSX3("EE8_QTDEM1",6))} ,"",STR0295}) //"Qt.de Embal."
//AADD(TB_Col_D,{{|| TRAN(VAL(NPDPRECO)   ,AVSX3("EE8_PRECO",6))}  ,"",STR0156}) // Preço Unit.
AADD(TB_Col_D,{{|| TRAN(VAL(NPDPRECO)   ,EECPreco("EE8_PRECO", AV_PICTURE))}  ,"",STR0156}) // Preço Unit.
AADD(TB_Col_D,{{|| TRAN(VAL(NPDPSLQUN)  ,AVSX3("EE8_PSLQUN",6))} ,"",STR0157}) // Peso Líquido Unit.
AADD(TB_Col_D,{{|| TRAN(VAL(NPDPSLQTO)  ,AVSX3("EE8_PSLQTO",6))} ,"",STR0158}) // Peso Bruto Unit.
AADD(TB_Col_D,{{|| NPDFPCOD}                                     ,"",STR0296}) //"Cod.Familia"
AADD(TB_Col_D,{{|| NPDGPCOD}                                     ,"",STR0297}) //"Cod.Grupo"
AADD(TB_Col_D,{{|| NPDGPCOD}                                     ,"",STR0298}) //"Cod.Divisao"
AADD(TB_Col_D,{{|| TRAN(NPDPOSIPI,AVSX3("EE8_POSIPI",6))}        ,"",STR0091}) // NCM
AADD(TB_Col_D,{{|| NPDNLNCCA}                                    ,"",STR0098}) // NALADI NCCA
AADD(TB_Col_D,{{|| NPDNALSH}                                     ,"",STR0099}) // NALADI SH
AADD(TB_Col_D,{{|| NPDREFCLI}                                    ,"",STR0299}) //"Ref.Cliente"

IF EasyEntryPoint("IN100CLI")  
   ExecBlock("IN100CLI",.F.,.F.,"COLPD")
ENDIF

AADD(TB_Col_D,{{|| IN100E_Msg(.T.)} ,"" ,STR0046}) // Mensagem

Return .T.

*--------------------*
FUNCTION IN100LERPE()
*--------------------*
Local lDetMsg:=.F., lAchouSaldo:=.F. //lAchouAnalist:=.F.,
Local nRegNPD, cChavePE, cPosPD  
Local cOldFuncao:=cFuncao
Local lBUpDate:= .F.

If Type("bUpDate") == "B"
   lBUpDate:= .T.
EndIf

Int_PE->NPEMSG := ""

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERPE")
ENDIF

EE7->(DbSetOrder(1))

IF EMPTY(Int_PE->NPEPEDIDO)
   EVAL(bmsg,STR0129+STR0230) // Codigo Processo não informado
Else   
   IF ! EE7->(DBSEEK(cFilEE7+AVKey(Int_PE->NPEPEDIDO,"EE7_PEDIDO")))
      If Int_PE->NPETIPO # INCLUSAO
         If Int_PE->NPETIPO = ALTERACAO .AND. lIncAltPE
            Int_PE->NPETIPO:='I'
         Else
            EVAL(bMsg,STR0129+STR0228) // Codigo Processo sem cadastro
         Endif
      EndIf

   ELSEIF Int_PE->NPETIPO = INCLUSAO
          EVAL(bmsg,STR0129+STR0229) // Codigo Processo com cadastro

   ELSEIF Int_PE->NPETIPO == EXCLUSAO
          If EE9->(DBSEEK(cFilEE9+AVKey(Int_PE->NPEPEDIDO,"EE9_PEDIDO")))
             EVAL(bmsg,STR0159) // Processo em Andamento
          EndIf
          IF EasyEntryPoint("IN100CLI")
             ExecBlock("IN100CLI",.F.,.F.,"VALPE")
          ENDIF
          IN100VerErro(cErro,cAviso)
          IF Int_PE->NPEINT_OK = "T"
             nResumoCer+=1
          ELSE
             nResumoErr+=1
          ENDIF
          // TRP - 19/07/2012
          if lBUpDate
             
             Int_PD->(DBSEEK(Int_PE->NPEPEDIDO+Int_PE->NPESEQ)) 
             
             DO WHILE ! Int_PD->(EOF()) .AND. Int_PD->NPDPEDIDO+Int_PD->NPDSEQ == Int_PE->NPEPEDIDO+Int_PE->NPESEQ 
                Int_PD->NPDINT_OK := "T"
         
                cFuncao:="PD"
                Eval(bUpDate, Int_PD->NPDMSG,Int_PD->NPDINT_OK)
                cFuncao:="PE"
         
                Int_PD->(dbSkip())
             EndDo
          endif
   
          RETURN .T.

   ELSEIF Int_PE->NPETIPO == ALTERACAO
          
          EECIN100IPE()
         
   ENDIF
   EECIN100VALPE()  // Para validacao de toda a capa

ENDIF

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALPE")
ENDIF

IF ! Int_PD->(DBSEEK(Int_PE->NPEPEDIDO+Int_PE->NPESEQ)) .AND. Int_PE->NPETIPO # 'A'
   EVAL(bMsg,STR0161) // Processo não possui itens
ENDIF
                       
IN100VerErro(cErro,cAviso)
 
Int_PE->NPEITEM_OK:="T"

cErro:=NIL ; cAviso:=NIL

Do WHILE ! Int_PD->(EOF()) .AND. Int_PD->NPDPEDIDO+Int_PD->NPDSEQ == Int_PE->NPEPEDIDO+Int_PE->NPESEQ
      lAchouSaldo := .F. // By JPP - 28/11/2006 - 14:30 - Esta variável deve ser inicializada com falso, caso o primeiro item tenha saldo e o segundo item não tenha saldo.     

      IF EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"LERPD")
      ENDIF
      
      IF EMPTY(Int_PD->NPDPOSICAO) .OR. Val(Int_PD->NPDPOSICAO) = 0
         EVAL(bMsg,STR0162+STR0230) // Posicao do Item não informado
      ELSE
         //MJB-SAP-1100 NAO FUNCIONAVA -> Int_PD->NPDPOSICAO:=Str(VAL(Int_PD->NPDPOSICAO))
         Int_PD->NPDPOSICAO:=PadL(VAL(Int_PD->NPDPOSICAO),Len(Int_PD->NPDPOSICAO)) //MJB-SAP-1100
      ENDIF

      Int_PD->NPDTIPO := UPPER(Int_PD->NPDTIPO)
      
      IF EMPTY(Int_PD->NPDTIPO)
         EVAL(bMsg,STR0163+STR0230) // Tipo do Item não informado
      ELSEIF ! Int_PD->NPDTIPO $ STR0164
         EVAL(bmsg,STR0165+STR0227) // Tipo de integração invalida
      ENDIF
            
      IF !EE8->(DBSEEK(cFilEE8+AVKey(Int_PE->NPEPEDIDO,"EE8_PEDIDO")+PadL(VAL(Int_PD->NPDPOSICAO),Len(EE8->EE8_SEQUEN))))
       EE8->(DBSEEK(cFilEE8+AVKey(Int_PE->NPEPEDIDO,"EE8_PEDIDO")+AVKey(Int_PD->NPDPOSICAO,"EE8_SEQUEN")))       
      ENDIF 
      /*
         ER - 15/08/2006
         Verificação do Saldo do Item
      */
      If EE8->(!EOF()) .and. Int_PD->NPDTIPO <> INCLUSAO
         lAchouSaldo:=.F.
         If Val(Int_PD->NPDSLDINI) <> EE8->EE8_SLDINI
            If EE8->EE8_SLDINI <> EE8->EE8_SLDATU 
               If Val(Int_PD->NPDSLDINI) > EE8->EE8_SLDINI
                  lAchouSaldo:=.T.
               Else
                  If (Val(Int_PD->NPDSLDINI) >= (EE8->EE8_SLDINI - EE8->EE8_SLDATU)) .and. EE8->EE8_SLDATU > 0
                     lAchouSaldo:=.T.
                  EndIf
               EndIf
            Else
               lAchouSaldo:=.T.
            EndIf
         Else
            If Int_PD->NPDTIPO == EXCLUSAO
               If EE8->EE8_SLDINI <> EE8->EE8_SLDATU 
                  If Val(Int_PD->NPDSLDINI) > EE8->EE8_SLDINI
                     lAchouSaldo:=.T.
                  Else
                     If (Val(Int_PD->NPDSLDINI) >= (EE8->EE8_SLDINI - EE8->EE8_SLDATU)) .and. EE8->EE8_SLDATU > 0
                        lAchouSaldo:=.T.
                     EndIf
                  EndIf
               Else
                  lAchouSaldo:=.T.
               EndIf     
            Else
               lAchouSaldo:=.T.
            EndIf
         EndIf
         
         If !lAchouSaldo
            EVAL(bmsg,"O Item não pode ser alterado/excluído porque já foi Embarcado.") 
         EndIf
         
      EndIf
      
      IF EE8->(EOF()) .AND. Int_PD->NPDTIPO#INCLUSAO
         If Int_PD->NPDTIPO = ALTERACAO .AND. lIncAltPE
            If !EE8->(DBSEEK(cFilEE8+AVKey(Int_PE->NPEPEDIDO,"EE8_PEDIDO")+AVKey(Int_PD->NPDPOSICAO,"EE8_SEQUEN"))) //SVG - 12/05/09 -
               Int_PD->NPDTIPO:= STR0166 // Inclusão
            EndIf
         Else
            EVAL(bMsg,STR0167+STR0228) // Item do Pedido não cadastrado
         Endif
      ELSEIF ! EE8->(EOF()) .AND. Int_PD->NPDTIPO = INCLUSAO
         EVAL(bMsg,STR0168) // Item repetiu a posicao
      ElseIf Int_PD->NPDTIPO=INCLUSAO  
         nRegNPD  :=Int_PD->(RECNO())
         cChavePE :=Int_PD->NPDPEDIDO+Int_PD->NPDSEQ
         cPosPD   :=Int_PD->NPDPOSICAO
         Int_PD->(DBSEEK(cChavePE))
         DO WHILE ! Int_PD->(EOF()) .AND. cChavePE = Int_PD->NPDPEDIDO+Int_PD->NPDSEQ
            IF Int_PD->NPDPOSICAO = cPosPD .AND. nRegNPD>Int_PD->(RECNO())
               EVAL(bMsg,STR0168) // Item Repetiu a Posição
               EXIT
            ENDIF
            Int_PD->(DBSKIP())
         ENDDO

         Int_PD->(DBGOTO(nRegNPD))
      EndIf

      IF ! EE8->(EOF()) .AND. Int_PD->NPDTIPO = ALTERACAO
         IF(EMPTY(Int_PD->NPDSLDINI) ,Int_PD->NPDSLDINI := STRZERO(EE8->EE8_SLDINI,AVSX3("EE8_SLDINI",3),AVSX3("EE8_SLDINI",4)),) 
         IF(EMPTY(Int_PD->NPDFORN)   ,Int_PD->NPDFORN   := EE8->EE8_FORN,) 
         IF(EMPTY(Int_PD->NPDFOLOJA) ,Int_PD->NPDFOLOJA := EE8->EE8_FOLOJA,)
         IF(EMPTY(Int_PD->NPDFABR)   ,Int_PD->NPDFABR   := EE8->EE8_FABR,) 
         IF(EMPTY(Int_PD->NPDFALOJA) ,Int_PD->NPDFALOJA := EE8->EE8_FALOJA,)
         IF(EMPTY(Int_PD->NPDPRECO)  ,Int_PD->NPDPRECO  := STRZERO(EE8->EE8_PRECO,AVSX3("EE8_PRECO",3),AVSX3("EE8_PRECO",4)),) 
         IF(EMPTY(Int_PD->NPDPSLQUN) ,Int_PD->NPDPSLQUN := STRZERO(EE8->EE8_PSLQUN,AVSX3("EE8_PSLQUN",3),AVSX3("EE8_PSLQUN",4)),) 
         IF(EMPTY(Int_PD->NPDPOSIPI) ,Int_PD->NPDPOSIPI := EE8->EE8_POSIPI,) 
         IF(EMPTY(Int_PD->NPDNLNCCA) ,Int_PD->NPDNLNCCA := EE8->EE8_NLNCCA,) 
         IF(EMPTY(Int_PD->NPDNALSH)  ,Int_PD->NPDNALSH  := EE8->EE8_NALSH,) 
      EndIf

      IF ! SB1->(DBSEEK(cFilSB1+LEFT(Int_PD->NPDCOD_I,nLenItem)))     //MJB-SAP-1100
         EVAL(bMsg,STR0087+STR0228) // Código do Item sem cadastro
      EndIf
      
      
      If EMPTY(Int_PD->NPDDECIT) .AND. EMPTY(EE8->EE8_DESC) .and. !sb1->(eof()) //.AND. EE8->(EOF())    // GFP - 31/10/2012
         Int_PD->NPDDECIT:=SB1->B1_DESC         
         //EVAL(bmsg,STR0100+STR0230) // Descrição não informada
      EndIf
      
      IF EMPTY(Int_PD->NPDFORN) .AND. EE8->(EOF())
         EVAL(bmsg,STR0110+STR0230) // Código do Fornecedor não informado
      EndIf

      If !Empty(Int_PD->NPDFORN) .And. Empty(Int_PD->NPDFOLOJA)           //MJB-SAP-1100
         If Int_PD->NPDFORN <> SA2->A2_COD                                //MJB-SAP-1100
            SA2->(DBSEEK(cFilSA2+AVKey(Int_PD->NPDFORN,"A2_COD")))      //MJB-SAP-1100
         Endif                                                            //MJB-SAP-1100
         Int_PD->NPDFOLOJA:=SA2->A2_LOJA                                  //MJB-SAP-1100
      Endif                                                               //MJB-SAP-1100

      IF EMPTY(Int_PD->NPDFOLOJA) .AND. EE8->(EOF())
         EVAL(bmsg,STR0111+STR0230) // Loja do Fornecedor não informado
      EndIf
                                                                                             
      IF ! EMPTY(Int_PD->NPDFORN) .AND. ! EMPTY(Int_PD->NPDFOLOJA) .AND. ! SA2->(DBSEEK(cFilSA2+AVKey(Int_PD->NPDFORN,"A2_COD")+AVKey(Int_PD->NPDFOLOJA,"A2_LOJA")))
         EVAL(bmsg,STR0124+STR0228) // Fornecedor/Loja sem cadastro
      EndIf

      If !Empty(Int_PD->NPDFABR) .And. Empty(Int_PD->NPDFALOJA)           //MJB-SAP-1100
         If Int_PD->NPDFABR <> SA2->A2_COD                                //MJB-SAP-1100
            SA2->(DBSEEK(cFilSA2+AVKey(Int_PD->NPDFABR,"A2_COD"))) //MJB-SAP-1100
         Endif                                                            //MJB-SAP-1100
         Int_PD->NPDFALOJA:=SA2->A2_LOJA                                  //MJB-SAP-1100
      Endif                                                               //MJB-SAP-1100

      IF EMPTY(Int_PD->NPDFABR) .AND. ! EMPTY(Int_PD->NPDFALOJA)
         EVAL(bmsg,STR0108+STR0230) // Código do Fabricante não informado
      ElseIf ! EMPTY(Int_PD->NPDFABR) .AND. EMPTY(Int_PD->NPDFOLOJA)
         EVAL(bmsg,STR0109+STR0230) // Loja do Fabricante não informado
      ElseIF ! EMPTY(Int_PD->NPDFABR) .AND. ! EMPTY(Int_PD->NPDFALOJA) .AND. ! SA2->(DBSEEK(cFilSA2+AVKey(Int_PD->NPDFABR,"A2_COD")+AVKey(Int_PD->NPDFALOJA,"A2_LOJA")))
         EVAL(bmsg,STR0122+STR0228) // Fabricante/Loja sem cadastro
      EndIf                 
      
      IF !EMPTY(Int_PD->NPDDTPREM) .AND. ! IN100CTD(Int_PD->NPDDTPREM,.T.,'DDMMAAAA',LEN(Int_PD->NPDDTPREM)) //MJB-SAP-1100
         EVAL(bmsg,STR0170+STR0227) // Data Prev. Emb. Invalida
      ENDIF
      
      IF !EMPTY(Int_PD->NPDDTENTR) .AND.! IN100CTD(Int_PD->NPDDTENTR,.T.,'DDMMAAAA',LEN(Int_PD->NPDDTENTR)) //MJB-SAP-1100
         EVAL(bmsg,STR0171+STR0227) // Data Entrega Invalida
      ENDIF
      
      IF ! EMPTY(Int_PD->NPDUNIDAD) .AND. ! SAH->(DBSEEK(cFilSAH+AVKey(Int_PD->NPDUNIDAD,"AH_UNIMED"))) 
         EVAL(bmsg,STR0089+STR0228) // Unidade de Medida sem cadastro
      ENDIF         
      
      IF EMPTY(Int_PD->NPDSLDINI) .AND. EE8->(EOF())
         EVAL(bmsg,STR0155+STR0230) // Quantidade não informada
      ElseIf IN100NaoNum(Int_PD->NPDSLDINI)
         EVAL(bmsg,STR0155+STR0227) // Quantidade invalida
      ENDIF         

      IF ! EMPTY(Int_PD->NPDEMBAL1) .AND. ! EE5->(DBSEEK(cFilEE5+AVKey(Int_PD->NPDEMBAL1,"EE5_CODEMB"))) 
         EVAL(bmsg,STR0096+STR0228) // Embalagem sem cadastro
      ENDIF              
      
      //////////////////////////////////////////////////////////////////////////////////////      
      //Se o Tipo do Pedido for Café (PC_CF), poderá ser incluído item sem preço unitário.// 
      //////////////////////////////////////////////////////////////////////////////////////      
      If EECFLAGS("CAFE_OPCIONAL")
         If Int_PE->NPETP <> PC_CF 
            IF EMPTY(Int_PD->NPDPRECO) .AND. EE8->(EOF())
               EVAL(bmsg,STR0156+STR0230) // Preco Unitario nao informado
            ElseIf IN100NaoNum(Int_PD->NPDPRECO)
               EVAL(bmsg,STR0156+STR0227) // Preco Unitario invalido
            ENDIF
         EndIf
      Else
         IF EMPTY(Int_PD->NPDPRECO) .AND. EE8->(EOF())
            EVAL(bmsg,STR0156+STR0230) // Preco Unitario nao informado
         ElseIf IN100NaoNum(Int_PD->NPDPRECO)
            EVAL(bmsg,STR0156+STR0227) // Preco Unitario invalido
         ENDIF
      EndIf
                   
      IF EMPTY(Int_PD->NPDPSLQUN) .AND. EE8->(EOF())
         EVAL(bmsg,STR0172+STR0230) // Peso Liq. não informado
      ElseIf ! EMPTY(Int_PD->NPDPSLQUN) .AND. IN100NaoNum(Int_PD->NPDPSLQUN)
         EVAL(bmsg,STR0172+STR0227) // Peso Liq. invalido
      ENDIF
      
      If SX5->(DBSEEK(cFilSX5+'ID'+AVKey(Int_PE->NPEIDIOMA,"X5_CHAVE")))
         If ! EMPTY(Int_PD->NPDFPCOD) .AND.;
            ! EMPTY(Int_PE->NPEIDIOMA) .AND. ! SYC->(DBSEEK(cFilSYC+AVKey(AVKey(Int_PE->NPEIDIOMA,"X5_CHAVE")+"-"+SX5->X5_DESCRI,"YC_IDIOMA")+AVKey(Int_PD->NPDFPCOD,"YC_COD")))
              EVAL(bmsg,STR0095+STR0228) // Código da Família sem cadastro
         EndIf                        
                                                                                                                
         If ! Empty(Int_PD->NPDGPCOD) .AND.;
            ! EMPTY(Int_PE->NPEIDIOMA) .AND. ! EEH->(DBSEEK(cFilEEH+AVKey(AVKey(Int_PE->NPEIDIOMA,"X5_CHAVE")+"-"+SX5->X5_DESCRI,"EEH_IDIOMA")+AVKey(Int_PD->NPDGPCOD,"EEH_COD")))
            EVAL(bmsg,STR0042+STR0228) // Grupo sem cadastro
         EndIf
                                                                          
         If ! Empty(Int_PD->NPDDPCOD) .AND.;
            ! EMPTY(Int_PE->NPEIDIOMA) .AND. ! EEG->(DBSEEK(cFilEEG+AVKey(AVKey(Int_PE->NPEIDIOMA,"X5_CHAVE")+"-"+SX5->X5_DESCRI,"EEG_IDIOMA")+AVKey(Int_PD->NPDDPCOD,"EEG_COD")))
               EVAL(bmsg,STR0173+STR0228) // Codigo Divisão sem cadastro
         EndIf
      EndIf
      
      If Empty(Int_PD->NPDPOSIPI) .AND. EE8->(EOF())
         EVAL(bmsg,STR0091+STR0230) // Classificação NCM não informado
      ElseIf ! Empty(Int_PD->NPDPOSIPI) .AND. ! SYD->(DBSEEK(cFilSYD+Int_PD->NPDPOSIPI))
         EVAL(bmsg,STR0091+STR0228)  // Classificação NCM sem cadastro
      EndIf
      
      If ! Empty(Int_PD->NPDNLNCCA) .AND. ! SJ2->(DBSEEK(cFilSJ2+Int_PD->NPDNLNCCA)) 
         EVAL(bmsg,STR0098+STR0228) // NALADI NCCA sem cadastro
      EndIf

      If ! Empty(Int_PD->NPDNALSH) .AND. ! SJ1->(DBSEEK(cFilSJ1+Int_PD->NPDNALSH)) 
         EVAL(bmsg,STR0099+STR0228) // NALADI SH sem cadastro
      EndIf
                              
      IF EasyEntryPoint("IN100CLI")  
         ExecBlock("IN100CLI",.F.,.F.,"VALPD")
      ENDIF
      
      IF cErro # NIL
         Int_PD->NPDMSG:=cErro
         Int_PD->NPDINT_OK := "F"
         cErro:= NIL
         lDetMsg:=.T.
      ELSE
         Int_PD->NPDINT_OK:= "T"
         IF cAviso # NIL
            Int_PE->NPEMSG:=cAviso ; cAviso:= NIL
         ENDIF
      ENDIF
 
      if lBUpDate//--- ADC 09/02/2011 Para tratamento da integração EICIN100 x AvInteg
         cOldFuncao:=cFuncao
         cFuncao   :="PD"
         Eval(bUpDate, Int_PD->NPDMSG,Int_PD->NPDINT_OK)
         cFuncao   :=cOldFuncao
         If Int_PD->NPDINT_OK == "F"
            lDetMsg:=.T.
         EndIf
      endif
 
      If Int_PE->NPEITEM_OK = "T" .AND. ! Int_PD->NPDINT_OK = "T"
         Int_PE->NPEITEM_OK:="F"
      EndIf
   
      Int_PD->(DBSKIP())
EndDo

IF lDetMsg //.AND. Int_PE->NPETIPO == INCLUSAO Nopado por ER - 15/09/2006
   Int_PE->NPEINT_OK := "F"
ENDIF

IF EMPTY(ALLTRIM(Int_PE->NPEMSG)) .AND. lDetMsg
   Int_PE->NPEMSG := STR0174  // Aviso: .....Vide Itens
ENDIF

IF EasyEntryPoint("IN100CLI") // By JPP - 28/11/2006 - 14:30 - Inclusão do ponto de entrada
   ExecBlock("IN100CLI",.F.,.F.,"FINAL_LERPE")
ENDIF

IF Int_PE->NPEINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF

IF Int_PE->NPEINT_OK = "T" .AND. ! Int_PE->NPEITEM_OK = "T"
   nResumoAlt+=1                     
ENDIF

Return .T.

*------------------------------*
Function EECIN100VALPE()
*------------------------------*
Local nTotItens, nDescAux:=0
Local nPos := 0

If !Empty(Int_PE->NPEIMPORT) .And. Empty(Int_PE->NPEIMLOJA)               //MJB-SAP-1100
   If Int_PE->NPEIMPORT <> SA1->A1_COD                                    //MJB-SAP-1100
      SA1->(DbSeek(cFilSA1+AVKey(Int_PE->NPEIMPORT,"A1_COD")))          //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   Int_PE->NPEIMLOJA:=SA1->A1_LOJA                                        //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100

If Empty(Int_PE->NPEIMPODE) .AND. EE7->(EOF())                            //MJB-SAP-1100
   If Int_PE->(NPEIMPORT+NPEIMLOJA) <> SA1->(A1_COD+A1_LOJA)              //MJB-SAP-1100
      SA1->(DbSeek(cFilSA1+AVKey(Int_PE->NPEIMPORT,"A1_COD")+AVKey(Int_PE->NPEIMLOJA,"A1_LOJA"))) //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   Int_PE->NPEIMPODE:=SA1->A1_NOME                                        //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100

If Empty(Int_PE->NPEENDIMP) .AND. EE7->(EOF())                            //MJB-SAP-1100
   If Int_PE->(NPEIMPORT+NPEIMLOJA) <> SA1->(A1_COD+A1_LOJA)              //MJB-SAP-1100
      SA1->(DbSeek(cFilSA1+AVKey(Int_PE->NPEIMPORT,"A1_COD")+AVKey(Int_PE->NPEIMLOJA,"A1_LOJA"))) //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   Int_PE->NPEENDIMP:=SA1->A1_END                                         //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100

/* Nopado por ER - 29/06/2006
If Empty(Int_PE->NPEEND2IM) .AND. EE7->(EOF())                            //MJB-SAP-1100
   If Int_PE->(NPEIMPORT+NPEIMLOJA) <> SA1->(A1_COD+A1_LOJA)              //MJB-SAP-1100
      SA1->(DbSeek(cFilSA1+AVKey(Int_PE->NPEIMPORT,"A1_COD")+AVKey(Int_PE->NPEIMLOJA))) //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   Int_PE->NPEEND2IM:=SA1->A1_BAIRRO                                      //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100
*/

//ER - 29/06/2006 - Alteração para Retornar os mesmos campos do Gatilho.
If Empty(Int_PE->NPEEND2IM) .AND. EE7->(EOF())
   Int_PE->NPEEND2IM:=EECMEND("SA1",1,AVKey(Int_PE->NPEIMPORT,"A1_COD")+AVKey(Int_PE->NPEIMLOJA,"A1_LOJA"),.T.,LEN(INT_PE->NPEEND2IM),2)//FDR - 17/05/13
Endif

IF !Empty(Int_PE->NPEFORN) .And. Empty(Int_PE->NPEFOLOJA)                 //MJB-SAP-1100
   If Int_PE->NPEFORN <> SA2->A2_COD                                      //MJB-SAP-1100
      SA2->(DBSEEK(cFilSA2+AVKey(Int_PE->NPEFORN,"A2_COD")))            //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   Int_PE->NPEFOLOJA:=SA2->A2_LOJA                                        //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100

If ! Empty(Int_PE->NPEEXPORT) .AND. Empty(Int_PE->NPEEXLOJA)              //MJB-SAP-1100
   If Int_PE->NPEEXPORT <> SA2->A2_COD                                    //MJB-SAP-1100
      SA2->(DBSEEK(cFilSA2+AVKey(Int_PE->NPEEXPORT,"A2_COD")))          //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   Int_PE->NPEEXLOJA:=SA2->A2_LOJA                                        //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100

If ! Empty(Int_PE->NPECONSIG) .And. Empty(Int_PE->NPECOLOJA)              //MJB-SAP-1100
   If Int_PE->NPECONSIG <> SA1->A1_COD                                    //MJB-SAP-1100
      SA1->(DBSEEK(cFilSA1+AVKey(Int_PE->NPECONSIG,"A1_COD")))          //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   Int_PE->NPECOLOJA:=SA1->A1_LOJA                                        //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100

If ! Empty(Int_PE->NPEBENEF) .AND. Empty(Int_PE->NPEBELOJA)               //MJB-SAP-1100
   If Int_PE->NPEBENEF <> SA2->A2_COD                                     //MJB-SAP-1100
      SA2->(DBSEEK(cFilSA2+AVKey(Int_PE->NPEBENEF,"A2_COD")))           //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   Int_PE->NPEBELOJA:=SA2->A2_LOJA                                        //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100

If Empty(Int_PE->NPEEXLIMP)                                               //MJB-SAP-1100
   Int_PE->NPEEXLIMP:="N"                                                 //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100

If Empty(Int_PE->NPEVIA)    .AND. EE7->(EOF())                            //MJB-SAP-1200
   SYR->(DbSeek(cFilSYR))                                                 //MJB-SAP-0501
   Int_PE->NPEVIA:=SYR->YR_VIA                                            //MJB-SAP-1200

   // by CAF 12/07/2002 - Puxar como default uma via com o tiptran preenchido
   IF Empty(SYR->YR_TIPTRAN)
      While SYR->(!Eof() .And. YR_FILIAL == cFilSYR)
         IF Empty(SYR->YR_TIPTRAN)
            SYR->(dbSkip())
            Loop
         Endif
     
         Int_PE->NPEVIA:=SYR->YR_VIA         
         Exit
      Enddo  
   Endif
EndIf

If Empty(Int_PE->NPEORIGEM) .AND. EE7->(EOF())                            //MJB-SAP-1100
   If Int_PE->NPEVIA <> SYR->YR_VIA                                       //MJB-SAP-1100
      SYR->(DbSeek(cFilSYR+AVKey(Int_PE->NPEVIA,"YR_VIA")))             //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   Int_PE->NPEORIGEM:=SYR->YR_ORIGEM                                      //MJB-SAP-1100 

   // by CAF 12/07/2002 - Puxar como default uma via com o tiptran preenchido
   IF Empty(SYR->YR_TIPTRAN)
      While SYR->(!Eof() .And. YR_FILIAL == cFilSYR) .And. SYR->YR_VIA == AVKey(Int_PE->NPEVIA,"YR_VIA")
         IF Empty(SYR->YR_TIPTRAN)
            SYR->(dbSkip())
            Loop
         Endif
     
         Int_PE->NPEORIGEM:=SYR->YR_ORIGEM 
         Exit
      Enddo  
   Endif
EndIf

IF Empty(Int_PE->NPEDEST) .AND. EE7->(EOF())                              //MJB-SAP-1100
   If Int_PE->NPEVIA <> SYR->YR_VIA                                       //MJB-SAP-1100
      SYR->(DbSeek(cFilSYR+AVKey(Int_PE->NPEVIA,"YR_VIA")))             //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   Int_PE->NPEDEST:=SYR->YR_DESTINO                                       //MJB-SAP-1100
     
   // by CAF 12/07/2002 - Puxar como default uma via com o tiptran preenchido
   IF Empty(SYR->YR_TIPTRAN)
      While SYR->(!Eof() .And. YR_FILIAL == cFilSYR) .And. SYR->YR_VIA == AVKey(Int_PE->NPEVIA,"YR_VIA")
         IF Empty(SYR->YR_TIPTRAN)
            SYR->(dbSkip())
            Loop
         Endif
     
         Int_PE->NPEDEST:=SYR->YR_DESTINO
         Exit
      Enddo  
   Endif
EndIf

IF Empty(Int_PE->NPETIPTRA) .AND. EE7->(EOF())
   If Int_PE->NPEVIA <> SYR->YR_VIA                                       //MJB-SAP-1100
      SYR->(DbSeek(cFilSYR+AVKey(Int_PE->NPEVIA,"YR_VIA")))             //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   Int_PE->NPETIPTRA:=SYR->YR_TIPTRAN                                     //MJB-SAP-1100
   
   While SYR->(!Eof() .And. YR_FILIAL == cFilSYR) .And. SYR->YR_VIA == AVKey(Int_PE->NPEVIA,"YR_VIA")
      IF Empty(SYR->YR_TIPTRAN)
         SYR->(dbSkip())
         Loop
      Endif
     
      Int_PE->NPETIPTRA:=SYR->YR_TIPTRAN
      Exit
   Enddo    
EndIf                                                                     //MJB-SAP-1100

If lNPENOTIFY .AND. ! Empty(Int_PE->NPENOTIFY) .And. Empty(Int_PE->NPENOLOJA)              //MJB-SAP-1100
   If Int_PE->NPENOTIFY <> SA1->A1_COD                                    //MJB-SAP-1100
      SA1->(DBSEEK(cFilSA1+AVKey(Int_PE->NPENOTIFY,"A1_COD")))          //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   Int_PE->NPENOLOJA:=SA1->A1_LOJA                                        //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100

IF EMPTY(Int_PE->NPEMPGEXP) .AND. EE7->(EOF())                            //MJB-SAP-1100
   EEF->(DbGoTop())                                                       //MJB-SAP-1100
   Int_PE->NPEMPGEXP:=EEF->EEF_COD                                        //MJB-SAP-1100
EndIf

If EMPTY(Int_PE->NPEIMPORT) .AND. EE7->(EOF())
   EVAL(bmsg,STR0071+STR0230) // Importador não informado
ElseIf ! EMPTY(Int_PE->NPEIMPORT) .AND. ! EMPTY(Int_PE->NPEIMLOJA) .AND. ! SA1->(DBSEEK(cFilSA1+AVKey(Int_PE->NPEIMPORT,"A1_COD")+AVKey(Int_PE->NPEIMLOJA,"A1_LOJA")))
   EVAL(bmsg,STR0132+STR0228)  // Código Importador sem cadastro
EndIf

IF EMPTY(Int_PE->NPEIMLOJA) .AND. EE7->(EOF())
   EVAL(bmsg,STR0133+STR0230) // Loja Importortador não informada
EndIf

IF EMPTY(Int_PE->NPEIMPODE) .AND. EE7->(EOF())
   EVAL(bmsg,STR0175+STR0230) // Descrição do Importador não informada
EndIf

IF EMPTY(Int_PE->NPEFORN) .AND. EE7->(EOF())
   EVAL(bmsg,STR0110+STR0230) // Código do Fornecedor não informado
EndIf

IF EMPTY(Int_PE->NPEFOLOJA) .AND. EE7->(EOF())
   EVAL(bmsg,STR0111+STR0230) // Loja do Fornecedor não informado
EndIf

IF ! EMPTY(Int_PE->NPEFORN) .AND. ! EMPTY(Int_PE->NPEFOLOJA)
   lAchouAnalist:=.F.  
   If ! SA2->(DBSEEK(cFilSA2+AVKey(Int_PE->NPEFORN,"A2_COD")+AVKey(Int_PE->NPEFOLOJA,"A2_LOJA")))
      EVAL(bmsg,STR0110+STR0228) // Código do Fornecedor
   ElseIf ! EMPTY(Int_PE->NPERESPON)
      If EE3->(DBSEEK(cFilEE3+CD_SA2+AVKey(Int_PE->NPEFORN,"EE3_CONTAT")+AVKey(Int_PE->NPEFOLOJA,"EE3_COMPL"))) //BY  JBJ Troca do campo EE3_LOJA
         While !EE3->(EOF()) .AND. ; 
               cFilEE3+CD_SA2+AVKey(Int_PE->NPEFORN,"EE3_CONTAT")+AVKey(Int_PE->NPEFOLOJA,"EE3_COMPL") == ;// BY JBJ Troca do campo EE3_LOJA
               EE3->EE3_FILIAL+EE3->EE3_CODCAD+EE3->EE3_CONTAT+EE3->EE3_COMPL // BY JBJ Troca do campo EE3_LOJA
              
               If EE3->EE3_NOME == Int_PE->NPERESPON
                  lAchouAnalist:=.T.  
               EndIf
               
               EE3->(DBSKIP(1))
         End
      EndIf
   EndIf
   If ! lAchouAnalist .AND. ! EMPTY(Int_PE->NPERESPON)
      EVAL(bmsg,STR0135+STR0228) // Analista Responsável sem cadastro
   EndIf
EndIf

IF (EMPTY(Int_PE->NPEFORN) .OR. EMPTY(Int_PE->NPEFOLOJA)) .AND. ! EMPTY(Int_PE->NPERESPON)
   EVAL(bmsg,STR0176) // Analista Resp. sem Fornec./Loja
EndIf

If ! EMPTY(Int_PE->NPEEXPORT) .AND. EMPTY(Int_PE->NPEEXLOJA)
   EVAL(bmsg,STR0137+STR0230) // Loja do Exportador não informado
EndIf

If EMPTY(Int_PE->NPEEXPORT) .AND. ! EMPTY(Int_PE->NPEEXLOJA)
   EVAL(bmsg,STR0136+STR0230) // Código do Exportador não informado                                     
ElseIf ! EMPTY(Int_PE->NPEEXPORT) .AND. ! EMPTY(Int_PE->NPEEXLOJA) .AND. ! SA2->(DBSEEK(cFilSA2+AVKey(Int_PE->NPEEXPORT,"A2_COD")+AVKey(Int_PE->NPEEXLOJA,"A2_LOJA")))
   EVAL(bmsg,STR0136+STR0228)  // Código do Exportador sem cadastro
EndIf

If ! EMPTY(Int_PE->NPECONSIG) .AND. EMPTY(Int_PE->NPECOLOJA)
   EVAL(bmsg,STR0179+STR0230) // Loja do Consignatário não informado
EndIf

If EMPTY(Int_PE->NPECONSIG) .AND. ! EMPTY(Int_PE->NPECOLOJA)
   EVAL(bmsg,STR0180+STR0230) // Código do Consignatário não informado                                 
ElseIf ! EMPTY(Int_PE->NPECONSIG) .AND. ! EMPTY(Int_PE->NPECOLOJA) .AND. ! SA1->(DBSEEK(cFilSA1+AVKey(Int_PE->NPECONSIG,"A1_COD")+AVKey(Int_PE->NPECOLOJA,"A1_LOJA")))
   EVAL(bmsg,STR0180+STR0228)  // Código do Consignatário sem cadastro
EndIf

If ! EMPTY(Int_PE->NPEBENEF) .AND. EMPTY(Int_PE->NPEBELOJA)
   EVAL(bmsg,STR0181+STR0230) // Loja do Beneficiário não informado
EndIf

If EMPTY(Int_PE->NPEBENEF) .AND. ! EMPTY(Int_PE->NPEBELOJA)
   EVAL(bmsg,STR0182+STR0230) // Código do Beneficiário não informado                                 
ElseIf ! EMPTY(Int_PE->NPEBENEF) .AND. ! EMPTY(Int_PE->NPEBELOJA) .AND. ! SA2->(DBSEEK(cFilSA2+AVKey(Int_PE->NPEBENEF,"A2_COD")+AVKey(Int_PE->NPEBELOJA,"A2_LOJA")))   
   EVAL(bmsg,STR0182+STR0228)  // Código do Beneficiário sem cadastro
EndIf
    
If lNPENOTIFY .AND. Empty(Int_PE->NPENOTIFY) .AND. ! Empty(Int_PE->NPENOLOJA)              //MJB-SAP-1100
   EVAL(bmsg,STR0073+STR0230)                                             //MJB-SAP-1100
Elseif lNPENOTIFY .AND. ! Empty(Int_PE->NPENOTIFY) .And. ! Empty(Int_PE->NPENOLOJA)  .AND. ! SA1->(DBSEEK(cFilSA1+AVKey(Int_PE->NPENOTIFY,"A1_COD")+AVKey(Int_PE->NPENOLOJA,"A1_LOJA")))
   EVAL(bmsg,STR0073+STR0228)                                             //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100

/* JPM - 04/05/06 - Correção nas validações de condição de pagamento.
IF EMPTY(Int_PE->NPECONDPA) .AND. EE7->(EOF())
   EVAL(bmsg,STR0079+STR0230) // Condições de Pagamento não informado
EndIf

IF EMPTY(Int_PE->NPEDIASPA) .AND. EE7->(EOF())
   EVAL(bmsg,STR0080+STR0230) // Dias de Pagamento não informado
ElseIF ! EMPTY(Int_PE->NPEDIASPA)                                                                     
   If ! EMPTY(Int_PE->NPECONDPA) .AND. ! EMPTY(Int_PE->NPEDIASPA) .AND. ! SY6->(DBSEEK(cFilSY6+AVKey(Int_PE->NPECONDPA,"Y6_COD")+STR(VAL(Int_PE->NPEDIASPA),3,0)))
      EVAL(bmsg,STR0184+STR0228) // Cond.Pag./Dias sem cadastro
   EndIf
EndIf   
*/

If EE7->(EoF())
   If Empty(Int_PE->NPECONDPA)
      Eval(bMsg,STR0079+STR0230) // Condições de Pagamento não informado
   ElseIf ! SY6->(DBSEEK(cFilSY6+AVKey(Int_PE->NPECONDPA,"Y6_COD")+STR(VAL(Int_PE->NPEDIASPA),3,0)))
      EVAL(bmsg,STR0184+STR0228) // Cond.Pag./Dias sem cadastro
   EndIf
         
   SY6->(DbSetOrder(1))
   If SY6->(DbSeek(cFilSY6+AVKey(Int_PE->NPECONDPA,"Y6_COD")))
      If SY6->Y6_TIPO == "3"
         For nPos := 1 To 10
            If SY6->&("Y6_DIAS_" + StrZero(nPos, 2)) < 0 
               EVAL(bmsg,STR0079 + STR0359 )//Condições de Pagamento com parcelas de adiantamento"
            EndIf
         Next
      EndIf
   EndIf
   
EndIf

IF EMPTY(Int_PE->NPEMPGEXP) .AND. EE7->(EOF())
   EVAL(bmsg,STR0185+STR0230) // Modal.Pag.Ext. não informado
ElseIf ! EMPTY(Int_PE->NPEMPGEXP) .AND. ! EEF->(DBSEEK(cFilEEF+AVKey(Int_PE->NPEMPGEXP,"EE7_MPGEXP")))   
   EVAL(bmsg,STR0185+STR0228) // Modal.Pag.Ext. sem cadastro
EndIf

IF EMPTY(Int_PE->NPEINCOTE) .AND. EE7->(EOF())
   EVAL(bmsg,STR0138+STR0230)   // Incoterm não informado
ElseIF ! EMPTY(Int_PE->NPEINCOTE) .AND. ! SYJ->(DBSEEK(cFilSYJ+AVKey(Int_PE->NPEINCOTE,"YJ_COD")))
   EVAL(bmsg,STR0138+STR0228) // Incoterm sem cadastro
EndIf

IF EMPTY(Int_PE->NPEVIA) .AND. EE7->(EOF())
   EVAL(bmsg,STR0139+STR0230) // Via de Transp. não informado
ElseIF ! EMPTY(Int_PE->NPEVIA) .AND. ! SYQ->(DBSEEK(cFilSYQ+AVKey(Int_PE->NPEVIA,"YQ_VIA")))
   EVAL(bmsg,STR0139+STR0228)  // Via de Transp. sem cadastro
EndIf

IF EMPTY(Int_PE->NPEORIGEM) .AND. EE7->(EOF())
   EVAL(bmsg,STR0186+STR0230) // Origem não informado
EndIf

IF EMPTY(Int_PE->NPEDEST) .AND. EE7->(EOF())
   EVAL(bmsg,STR0187+STR0230) // Destino não informado
EndIf

IF ! EMPTY(Int_PE->NPETIPTRA) .AND. ! EMPTY(Int_PE->NPEVIA) .AND. ! EMPTY(Int_PE->NPEORIGEM) .AND. ! EMPTY(Int_PE->NPEDEST)
   If ! SYR->(DBSEEK(cFilSYR+AVKey(Int_PE->NPEVIA,"YR_VIA")+AVKey(Int_PE->NPEORIGEM,"YR_ORIGEM")+AVKey(Int_PE->NPEDEST,"YR_DESTINO")))
      EVAL(bmsg,STR0188+STR0228) // Via/Origem/Dest. sem cadastro
   EndIf
EndIf

IF EMPTY(Int_PE->NPETIPTRA) .AND. EE7->(EOF())
   EVAL(bmsg,STR0189+STR0230)   // Tipo Transp. não informado
ElseIF ! EMPTY(Int_PE->NPETIPTRA) .AND. ! Int_PE->NPETIPTRA $ '123'
   EVAL(bmsg,STR0189+STR0227)       // Tipo Transp. invalido
ElseIF ! EMPTY(Int_PE->NPETIPTRA) .AND. ! EMPTY(Int_PE->NPEVIA) .AND. ! EMPTY(Int_PE->NPEORIGEM) .AND. ! EMPTY(Int_PE->NPEDEST)
   If ! SYR->(DBSEEK(cFilSYR+AVKey(Int_PE->NPEVIA,"YR_VIA")+AVKey(Int_PE->NPEORIGEM,"YR_ORIGEM")+AVKey(Int_PE->NPEDEST,"YR_DESTINO")+AVKey(Int_PE->NPETIPTRA,"YR_TIPTRAN")))
      EVAL(bmsg,STR0190+STR0228) // Via/Origem/Dest./Tipo Trans. sem cadastro
   EndIf
EndIf
                                 
IF ! EMPTY(Int_PE->NPEEXLIMP) 
   Int_PE->NPEEXLIMP:= if(UPPER(Int_PE->NPEEXLIMP) $ cSim,"S","N")
   If ! Int_PE->NPEEXLIMP $ STR0191 
      EVAL(bmsg,STR0134+STR0227) // Exige LI invalido
   ElseIf Int_PE->NPEEXLIMP = STR0192
      If EMPTY(Int_PE->NPELICIMP)
         EVAL(bmsg,STR0193+STR0230) // Licença Importação não informado
      EndIf
      
      If EMPTY(Int_PE->NPEDTLIMP)
         EVAL(bmsg,STR0194+STR0230) // Prazo LI
      EndIf
   Else
      If ! EMPTY(Int_PE->NPELICIMP) .OR. ! EMPTY(Int_PE->NPEDTLIMP)
         EVAL(bmsg,STR0195) // Existe LI deve ser igual a 'S'.
      EndIf
   EndIf
Elseif ! EMPTY(Int_PE->NPELICIMP) .OR. ! EMPTY(Int_PE->NPEDTLIMP)
   EVAL(bmsg,STR0134+STR0230) // Exige LI não informado
EndIf

If ! EMPTY(Int_PE->NPEDTLIMP) .AND. ! IN100CTD(Int_PE->NPEDTLIMP,.T.,'DDMMAAAA',LEN(Int_PE->NPEDTLIMP)) //MJB-SAP-1100
   EVAL(bmsg,STR0194+STR0227)     // Prazo LI Invalida
ENDIF

If ! EMPTY(Int_PE->NPESL_LC) .AND. ! IN100CTD(Int_PE->NPESL_LC,.T.,'DDMMAAAA',LEN(Int_PE->NPESL_LC)) //MJB-SAP-1100
   EVAL(bmsg,STR0196+STR0227) // Data Lic.Cred. Invalida
ENDIF

If ! EMPTY(Int_PE->NPESL_EME) .AND. ! IN100CTD(Int_PE->NPESL_EME,.T.,'DDMMAAAA',LEN(Int_PE->NPESL_EME)) //MJB-SAP-1100
   EVAL(bmsg,STR0197+STR0227) // Data Sol.Emenda Invalida
ENDIF

IF EMPTY(Int_PE->NPEMOEDA) .AND. EE7->(EOF())
   EVAL(bmsg,STR0127+STR0230) // Moeda não informado
ElseIF ! EMPTY(Int_PE->NPEMOEDA) .AND. ! SYF->(DBSEEK(cFilSYF+AVKey(Int_PE->NPEMOEDA,"YF_MOEDA")))
   EVAL(bmsg,STR0127+STR0228)  // Moeda sem cadastro
EndIf

IF EMPTY(Int_PE->NPEFRPPCC) .AND. EE7->(EOF())
   EVAL(bmsg,STR0198+STR0230) // Tipo Frete não informado
Elseif ! EMPTY(Int_PE->NPEFRPPCC)
   Int_PE->NPEFRPPCC := UPPER(Int_PE->NPEFRPPCC)
   IF Int_PE->NPEFRPPCC # 'CC' .AND. Int_PE->NPEFRPPCC # 'PP'
      EVAL(bmsg,STR0198+STR0227)  // Tipo Frete inválido
   EndIf
EndIf

IF EMPTY(Int_PE->NPEIDIOMA) .AND. EE7->(EOF())
   EVAL(bmsg,STR0102+STR0230) // Idioma não informado
ElseIf ! EMPTY(Int_PE->NPEIDIOMA) .AND. ! SX5->(DBSEEK(cFilSX5+'ID'+AVKey(Int_PE->NPEIDIOMA,"X5_CHAVE")))
   EVAL(bmsg,STR0102+STR0228) // Idioma sem cadastro
EndIf

IF EMPTY(Int_PE->NPEDTPROC) .AND. EE7->(EOF())
   EVAL(bmsg,STR0130+STR0230) // Data Processo não informado
ElseIf ! EMPTY(Int_PE->NPEDTPROC) .AND. ! IN100CTD(Int_PE->NPEDTPROC,.T.,'DDMMAAAA',LEN(Int_PE->NPEDTPROC)) //MJB-SAP-1100
   EVAL(bmsg,STR0130+STR0227) // Data do Processo invalido
ENDIF

IF EMPTY(Int_PE->NPEDTPEDI) .AND. EE7->(EOF())
   EVAL(bmsg,STR0131+STR0230) // Data Pedido não informado
ElseIf ! EMPTY(Int_PE->NPEDTPEDI) .AND. ! IN100CTD(Int_PE->NPEDTPEDI,.T.,'DDMMAAAA',LEN(Int_PE->NPEDTPEDI)) //MJB-SAP-1100
   EVAL(bmsg,STR0131+STR0227) // Data Pedido invalida
ENDIF

If ! EMPTY(Int_PE->NPEFIM_PE) .AND. ! IN100CTD(Int_PE->NPEFIM_PE,.T.,'DDMMAAAA',LEN(Int_PE->NPEFIM_PE)) //MJB-SAP-1100
   EVAL(bmsg,STR0199+STR0227) // Data da Finalização invalido
ENDIF

IF EMPTY(Int_PE->NPEDTSLCR) .AND. EE7->(EOF())
//MJB-SAP-1100 DT NAO OBRIGATORIA, EVAL(bmsg,STR0200+STR0230) // Data Solic.Cred. nao informado
ElseIf ! EMPTY(Int_PE->NPEDTSLCR) .AND. ! IN100CTD(Int_PE->NPEDTSLCR,.T.,'DDMMAAAA',LEN(Int_PE->NPEDTSLCR)) //MJB-SAP-1100
   EVAL(bmsg,STR0200+STR0227)     // Data Solic.Cred. invalido
ENDIF

IF EMPTY(Int_PE->NPEAMOSTR) .AND. EE7->(EOF())
   EVAL(bmsg,STR0201+STR0230) // Amostra não informada
ElseIf ! EMPTY(Int_PE->NPEAMOSTR)
   Int_PE->NPEAMOSTR:=UPPER(Int_PE->NPEAMOSTR)
   If ! Int_PE->NPEAMOSTR $ STR0191 // SN
      EVAL(bmsg,STR0201+STR0227) // Amostra invalida
   EndIf
EndIf

IF EMPTY(Int_PE->NPEPRECOA) .AND. EE7->(EOF())
   EVAL(bmsg,STR0202+STR0230) // Preço Aberto não informado
Else
   Int_PE->NPEPRECOA:=UPPER(Int_PE->NPEPRECOA)
   If ! Int_PE->NPEPRECOA $ STR0191 // SN
      EVAL(bmsg,STR0202+STR0227) // Preço Aberto inválido
   EndIf
EndIf

IF ! EMPTY(Int_PE->NPECLIENT) .AND. EMPTY(Int_PE->NPECLLOJA)
   EVAL(bmsg,STR0177+STR0230) // Loja do Cliente não informada
ElseIF EMPTY(Int_PE->NPECLIENT) .AND. ! EMPTY(Int_PE->NPECLLOJA)
   EVAL(bmsg,STR0008+STR0230) // Cliente não informado                                                  
ElseIF ! EMPTY(Int_PE->NPECLIENT) .AND. ! EMPTY(Int_PE->NPECLLOJA) .AND. ! SA1->(DBSEEK(cFilSA1+AVKey(Int_PE->NPECLIENT,"A1_COD")+AVKey(Int_PE->NPECLLOJA,"A1_LOJA")))
   EVAL(bmsg,STR0008+STR0228)  // Cliente sem cadastro
EndIf

IF ! EMPTY(Int_PE->NPEEMBAFI) .AND. ! EE5->(DBSEEK(cFilEE5+AVKey(Int_PE->NPEEMBAFI,"EE5_CODEMB")))
   EVAL(bmsg,STR0178+STR0228) // Volume sem cadastro
ENDIF

IF ! EMPTY(Int_PE->NPECALCEM) .AND. ! Int_PE->NPECALCEM $ '12'
   EVAL(bmsg,STR0203+STR0227) // Tipo Calc.Emb. Invalido
EndIf   

IF ! EMPTY(Int_PE->NPELC_NUM)
   If ! EEL->(DBSEEK(cFilEEL+AVKey(Int_PE->NPELC_NUM,"EEL_LC_NUM"))) 
      EVAL(bmsg,STR0204+STR0228) // Num.LC sem cadastro
   Elseif EEL->EEL_LCVL <= 0
      EVAL(bmsg,STR0205) // Num.LC sem Saldo
   Else
      nTotItens:=0
      nDescAux:=0
      
      If Int_PE->NPETIPO == INCLUSAO
         nDescAux:=If(!IN100NaoNum(Int_PE->NPEDESCON),Val(Int_PE->NPEDESCON),0)
         Int_PD->(DBSEEK(Int_PE->NPEPEDIDO+Int_PE->NPESEQ)) 
         WHILE ! Int_PD->(EOF()) .AND. Int_PD->NPDPEDIDO+Int_PD->NPDSEQ==Int_PE->NPEPEDIDO+Int_PE->NPESEQ
            If Int_PD->NPDTIPO='I' .AND. ! IN100NaoNum(Int_PD->NPDSLDINI) .AND. ! IN100NaoNum(Int_PD->NPDPRECO)
               nTotItens+=Val(Int_PD->NPDSLDINI)*Val(Int_PD->NPDPRECO)
            EndIf
            Int_PD->(DBSKIP())
         EndDo
      ElseiF Int_PE->NPETIPO == ALTERACAO
         If !IN100NaoNum(Int_PE->NPEDESCON) .AND. Val(Int_PE->NPEDESCON)#0
            nDescAux:=Val(Int_PE->NPEDESCON)
         Else
            If EE7->(DBSEEK(cFilEE7+AVKey(Int_PE->NPEPEDIDO,"EE7_PEDIDO")))
               nDescAux:=EE7->EE7_DESCON
            EndIf
         EndIf
         If EE8->(DBSEEK(cFilEE8+AVKey(Int_PE->NPEPEDIDO,"EE8_PEDIDO")+AVKey(Int_PD->NPDPOSICAO,"EE8_SEQUEN"))) .OR. ;
            EE8->(DBSEEK(cFilEE8+AVKey(Int_PE->NPEPEDIDO,"EE8_PEDIDO")+AVKey(str(val(Int_PD->NPDPOSICAO),LEN(EE8->EE8_SEQUEN) ),"EE8_SEQUEN")))
            Int_PD->(DBSETORDER(2))
            WHILE ! EE8->(EOF()) .AND. Int_PD->NPDPEDIDO==EE8->EE8_PEDIDO
               If Int_PD->(DBSEEK(Int_PE->NPEPEDIDO+Int_PE->NPESEQ+EE8->EE8_SEQUEN)) .OR. ;
                 Int_PD->(DBSEEK(Int_PE->NPEPEDIDO+Int_PE->NPESEQ+STRZERO(EE8->EE8_SEQUEN,LEN("EE8->EE8_SEQUEN"))))
                  If Int_PD->NPDTIPO $ STR0206 
                     If ! IN100NaoNum(Int_PD->NPDSLDINI) .AND. ! IN100NaoNum(Int_PD->NPDPRECO)
                        nTotItens+=Val(Int_PD->NPDSLDINI)*Val(Int_PD->NPDPRECO)
                     Else
                        nTotItens+=EE8->EE8_SLDINI*EE8->EE8_PRECO
                     EndIf
                  EndIf
               Else
                  nTotItens+=EE8->EE8_SLDINI*EE8->EE8_PRECO
               EndIf
               EE8->(DBSKIP())
            EndDo
            Int_PD->(DBSETORDER(1))
         EndIf         
      EndIf
      If (nTotItens-nDescAux) > EEL->EEL_LCVL
         EVAL(bmsg,STR0205)  
      EndIf
   EndIf
EndIf   

IF ! EMPTY(Int_PE->NPEPGTANT) 
   Int_PE->NPEPGTANT:=UPPER(Int_PE->NPEPGTANT)
   If ! Int_PE->NPEPGTANT $ STR0191
      EVAL(bmsg,STR0143+STR0227) // Pagto Antec. invalido
   EndIf   
EndIf

IF ! IN100NaoNum(Int_PE->NPEVALCOM)
  
   IF EMPTY(Int_PE->NPETIPCOM)  
      EVAL(bmsg,STR0147+STR0230) // Tipo Comis. não informado
   ElseIF ! Int_PE->NPETIPCOM $ '123'
      EVAL(bmsg,STR0147+STR0227)     // Tipo Comis. invalido
   EndIf
   
   IF EMPTY(Int_PE->NPETIPCVL)  
      EVAL(bmsg,STR0152+STR0230) // Tipo Val.Comis. não informado
   ElseIf ! Int_PE->NPETIPCVL $ '1234'
      EVAL(bmsg,STR0152+STR0227)     // Tipo Val.Comis. invalido
   EndIf
Elseif ! EMPTY(Int_PE->NPETIPCOM) .OR. ! EMPTY(Int_PE->NPETIPCVL)
   EVAL(bmsg,STR0207,.T.) // Comissao 0, zerado Tipo Comis/Tipo Val.
   Int_PE->NPETIPCOM := Int_PE->NPETIPCVL := " "
EndIf
// LCS - 13/09/2002 - DO IF ABAIXO ATE O ENDIF
IF INT_PE->(NPETIPO = "I" .OR. NPETIPO = "A")
   // VERIFICA SE O PRODUTO TEM DESCRICAO. CASO NAO TENHA, BUSCA DO CADASTRO DE
   // PRODUTOS NO IDIOMA DO PROCESSO
   Int_PD->(DBSEEK(Int_PE->(NPEPEDIDO+NPESEQ)))
   DO WHILE ! Int_PD->(EOF()) .AND.;
      INT_PD->(NPDPEDIDO+NPDSEQ) = Int_PE->(NPEPEDIDO+NPESEQ)
      *
      IF EMPTY(INT_PD->NPDDECIT) .AND. INT_PD->NPDTIPO == "I"   // GFP - 31/10/2012
         SX5->(DBSETORDER(1))
         SX5->(DBSEEK(cFILSX5+'ID'+AVKEY(INT_PE->NPEIDIOMA,"X5_CHAVE")))
         cIDIOMA := SX5->(X5_CHAVE+"-"+ALLTRIM(X5_DESCRI))
         EE2->(DBSETORDER(1))
         EE2->(DBSEEK(cFilEE2+"3*"+AVKEY(cIDIOMA,"EE2_IDIOMA")+AVKEY(INT_PD->NPDCOD_I,"EE2_COD")))
         INT_PD->NPDDECIT := MSMM(EE2->EE2_TEXTO,AVSX3("EE2_VM_TEX",AV_TAMANHO))
      ENDIF
      INT_PD->(DBSKIP())
   ENDDO
ENDIF

//TRP-06/06/2007
If EasyEntryPoint("EECIN100")
   ExecBlock("EECIN100", .F., .F., "FIM_IN100VALPE")
EndIf
Return .T.
*----------------------------*
Function EECIN100IPE()
*----------------------------*

IF(EMPTY(Int_PE->NPEIMPORT),Int_PE->NPEIMPORT := EE7->EE7_IMPORT,)
IF(EMPTY(Int_PE->NPEIMLOJA),Int_PE->NPEIMLOJA := EE7->EE7_IMLOJA,)
IF(EMPTY(Int_PE->NPEEXLIMP),Int_PE->NPEEXLIMP := If(EE7->EE7_EXLIMP=STR0192,"1","2"),)
IF(EMPTY(Int_PE->NPELICIMP),Int_PE->NPELICIMP := EE7->EE7_LICIMP,)
IF(EMPTY(Int_PE->NPEDTLIMP),Int_PE->NPEDTLIMP := IN100DTC(EE7->EE7_DTLIMP,If(LEN(Int_PE->NPEDTLIMP)=6,2,4)),) //MJB-SAP-1100
IF(EMPTY(Int_PE->NPECLIENT),Int_PE->NPECLIENT := EE7->EE7_CLIENT,)
IF(EMPTY(Int_PE->NPECLLOJA),Int_PE->NPECLLOJA := EE7->EE7_CLLOJA,)
IF(EMPTY(Int_PE->NPEFORN)  ,Int_PE->NPEFORN   := EE7->EE7_FORN  ,)
IF(EMPTY(Int_PE->NPEFOLOJA),Int_PE->NPEFOLOJA := EE7->EE7_FOLOJA,)
IF(EMPTY(Int_PE->NPERESPON),Int_PE->NPERESPON := EE7->EE7_RESPON,)
IF(EMPTY(Int_PE->NPEEXPORT),Int_PE->NPEEXPORT := EE7->EE7_EXPORT,)
IF(EMPTY(Int_PE->NPEEXLOJA),Int_PE->NPEEXLOJA := EE7->EE7_EXLOJA,)
IF(EMPTY(Int_PE->NPECONSIG),Int_PE->NPECONSIG := EE7->EE7_CONSIG,)
IF(EMPTY(Int_PE->NPECOLOJA),Int_PE->NPECOLOJA := EE7->EE7_COLOJA,)
IF(EMPTY(Int_PE->NPEBENEF) ,Int_PE->NPEBENEF  := EE7->EE7_BENEF ,)
IF(EMPTY(Int_PE->NPEBELOJA),Int_PE->NPEBELOJA := EE7->EE7_BELOJA,)
IF(EMPTY(Int_PE->NPECONDPA),Int_PE->NPECONDPA := EE7->EE7_CONDPA,)
IF(EMPTY(Int_PE->NPEDIASPA),Int_PE->NPEDIASPA := STR(EE7->EE7_DIASPA,3,0),)
IF(EMPTY(Int_PE->NPEVIA)   ,Int_PE->NPEVIA    := EE7->EE7_VIA   ,)
IF(EMPTY(Int_PE->NPEORIGEM),Int_PE->NPEORIGEM := EE7->EE7_ORIGEM,)
IF(EMPTY(Int_PE->NPEDEST)  ,Int_PE->NPEDEST   := EE7->EE7_DEST  ,)
IF(EMPTY(Int_PE->NPETIPTRA),Int_PE->NPETIPTRA := EE7->EE7_TIPTRA,)
IF(EMPTY(Int_PE->NPETIPCOM),Int_PE->NPETIPCOM := EE7->EE7_TIPCOM,)
IF(EMPTY(Int_PE->NPETIPCVL),Int_PE->NPETIPCVL := EE7->EE7_TIPCVL,)
IF(EMPTY(Int_PE->NPEVALCOM),Int_PE->NPEVALCOM := STR(EE7->EE7_VALCOM),)
IF(EMPTY(Int_PE->NPEPRECOA),Int_PE->NPEPRECOA := EE7->EE7_PRECOA,)

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"ALTPE")
ENDIF

Return .T.

*---------------------------*
FUNCTION IN100GrvPE()
*---------------------------*
LOCAL aTabEE7:={},bSave:=bMessage, lIncMSMM:=.F.,I,;
      nDECPRC := EECPreco("EE8_PRECO", AV_DECIMAL),; //AVSX3("EE8_PRECO",AV_DECIMAL),;
      nTOTITE,nTOTAL,nVLCOMIS,nPRECOTOT,nFATOR,nTOTRATEIO,nRECATUAL,lLASTREC,;
      nPRECOI,nAUXVAL,nVLDESPESA,nAUXDESP,nTOTLIQ,nTOTBRU,lPESOMANUAL,aEMBAL,;
      lCALCPESO := IF(!lNPDPSBRUN.OR.!lNPDPSBRTO,.T.,.F.)

Local aOrd:= SaveOrd("SB1")
Local cTxtMM

Local lIsFilBr := .f.,nInd, aArqs :={"EEB","EEJ","EEK","EET","EEN","EXB","EEY","EXK"} // By JPP - 25/07/2005 - 15:15
Local cSeek := "" //ER - 04/06/2006

Local nDiferenca := 0, nSldAtu := 0, nSldOld := 0
Local lRecTrue := .F.
Local lBUpDate:= .F.

Private lIntermed := .f.      // By JPP - 25/07/2005 - 15:15 - Flag para verificacao de intermediario na geracao do pedido...
Private cFilBr:="",cFilEx:="" // By JPP - 25/07/2005 - 15:15
Private aMemoItem :={{"EE8_DESC","EE8_VM_DES"}} // By JPP - 25/07/2005 - 15:15
//ASK 22/08/2007 - Tratamento do Crédito Automático para pedidos integrados MV_AVG0057
Private lLibCredAuto := EasyGParam("MV_AVG0057",,.F.) 

// ** jpm - ponto de entrada no inicio da gravação
If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"INICIO_GRVPE")
ENDIF

If Type("bUpDate") == "B"
   lBUpDate:= .T.
EndIf


IF Int_PE->NPETIPO = EXCLUSAO .OR. Int_PE->NPETIPO == ALTERACAO
   IF !EE7->(DBSEEK(cFilEE7+AVKey(Int_PE->NPEPEDIDO,"EE7_PEDIDO")))
      RETURN .F.
   ENDIF
   //EE7->(Reclock("EE7",.F.,,.T.))
   lRecTrue:=.F.
   DBSELECTAREA('Int_PE')
Else
   //Reclock("EE7",.T.)
   lRecTrue:=.T.
   DBSELECTAREA('Int_PE')
ENDIF

IF Int_PE->NPETIPO = EXCLUSAO
   // By JPP - 25/07/2005 - 15:15  - Parametros para a função AP100DelPed()
   cFilBr := EasyGParam("MV_AVG0023",,"")
   cFilBr := IF(ALLTRIM(cFilBr)=".","",cFilBr)
   cFilEx := EasyGParam("MV_AVG0024",,"")
   cFilEx := IF(ALLTRIM(cFilEx)=".","",cFilEx) 
   M->EE7_PEDIDO := Int_PE->NPEPEDIDO 
   SX2->(DbSetOrder(1))
   For nInd := 1 to Len(aArqs)
       If SX2->(DbSeek(aArqs[nInd]))
          DbSelectArea(aArqs[nInd]) // Abre as tabelas para exclusão dos registros.
       EndIf
   Next
   If !Empty(cFilBr) .And. !Empty(cFilEx) .And. IsFilial()
      If (EE7->(FieldPos("EE7_INTERM")) # 0) .And. (EE7->(FieldPos("EE7_COND2"))  # 0) .And.;
         (EE7->(FieldPos("EE7_DIAS2"))  # 0) .And. (EE7->(FieldPos("EE7_INCO2"))  # 0) .And.;
         (EE7->(FieldPos("EE7_PERC"))   # 0) .And. (EE8->(FieldPos("EE8_PRENEG")) # 0)
         lIntermed := .t.
      EndIf
   EndIf

   Begin Transaction


   EE7->(Reclock("EE7",.F.,,.T.))
   
   If EasyEntryPoint("IN100CLI")  
      ExecBlock("IN100CLI",.F.,.F.,"DELPE")
   ENDIF
   
   If lIntermed  // By JPP - 25/07/2005 - 15:15 - Chamada da função Ap100DelPed()
      /* Para os processos com tratamento de off-shore, a eliminação é realizada automaticamente
         na filial de intermediação, e vice-versa. */
      lIsFilBr := (AvGetM0Fil() <> cFilEx)
      AP100DelPed(lIsFilBr,nil,nil,.t.)
   Else
      AP100DelPed()
   EndIf
                
   EE7->(MSUNLOCK()) 
   DBSELECTAREA('Int_PE')
   EVAL(bMessage,STR0208) // Processo Excluido
   EE7->(DBCOMMIT())

   End Transaction

   DBSELECTAREA('Int_PE')

   RestOrd(aOrd)
   RETURN .T.
ENDIF

Begin Transaction

If lRecTrue
   EE7->(Reclock("EE7",.T.))
Else
   EE7->(Reclock("EE7",.F.,,.T.))
EndIf
EE7->EE7_FILIAL := cFilEE7
IF(!EMPTY(Int_PE->NPEPEDIDO),EE7->EE7_PEDIDO := Int_PE->NPEPEDIDO,)
IF(!EMPTY(Int_PE->NPEDTPROC),EE7->EE7_DTPROC := IN100CTD(Int_PE->NPEDTPROC,,'DDMMAAAA'),) //MJB-SAP-1100
IF(!EMPTY(Int_PE->NPEDTPEDI),EE7->EE7_DTPEDI := IN100CTD(Int_PE->NPEDTPEDI,,'DDMMAAAA'),) //MJB-SAP-1100
IF(!EMPTY(Int_PE->NPEAMOSTR),EE7->EE7_AMOSTR := Padl(At(Int_PE->NPEAMOSTR,STR0191),1),) //MJB-SAP-1100
IF(!EMPTY(Int_PE->NPEFIM_PE),EE7->EE7_FIM_PE := IN100CTD(Int_PE->NPEFIM_PE,,'DDMMAAAA'),) //MJB-SAP-1100
IF(!EMPTY(Int_PE->NPEDTSLCR),EE7->EE7_DTSLCR := IN100CTD(Int_PE->NPEDTSLCR,,'DDMMAAAA'),) //MJB-SAP-1100
IF(!EMPTY(Int_PE->NPEIMPORT),EE7->EE7_IMPORT := Int_PE->NPEIMPORT,)
IF(!EMPTY(Int_PE->NPEIMLOJA),EE7->EE7_IMLOJA := Int_PE->NPEIMLOJA,)
IF(!EMPTY(Int_PE->NPEIMPODE),EE7->EE7_IMPODE := Int_PE->NPEIMPODE,)
IF(!EMPTY(Int_PE->NPEENDIMP),EE7->EE7_ENDIMP := Int_PE->NPEENDIMP,)
IF(!EMPTY(Int_PE->NPEEND2IM),EE7->EE7_END2IM := Int_PE->NPEEND2IM,)
IF(!EMPTY(Int_PE->NPEREFIMP),EE7->EE7_REFIMP := Int_PE->NPEREFIMP,)
IF(!EMPTY(Int_PE->NPEEXLIMP),EE7->EE7_EXLIMP := Padl(At(Int_PE->NPEEXLIMP,STR0191),1),) //MJB-SAP-1100
IF(!EMPTY(Int_PE->NPELICIMP),EE7->EE7_LICIMP := Int_PE->NPELICIMP,)
IF(!EMPTY(Int_PE->NPEDTLIMP),EE7->EE7_DTLIMP := IN100CTD(Int_PE->NPEDTLIMP,,'DDMMAAAA'),) //MJB-SAP-1100
IF(!EMPTY(Int_PE->NPECLIENT),EE7->EE7_CLIENT := Int_PE->NPECLIENT,)
IF(!EMPTY(Int_PE->NPECLLOJA),EE7->EE7_CLLOJA := Int_PE->NPECLLOJA,)
IF(!EMPTY(Int_PE->NPEFORN  ),EE7->EE7_FORN   := Int_PE->NPEFORN  ,)
IF(!EMPTY(Int_PE->NPEFOLOJA),EE7->EE7_FOLOJA := Int_PE->NPEFOLOJA,)
IF(!EMPTY(Int_PE->NPERESPON),EE7->EE7_RESPON := Int_PE->NPERESPON,)
IF(!EMPTY(Int_PE->NPEEXPORT),EE7->EE7_EXPORT := Int_PE->NPEEXPORT,)
IF(!EMPTY(Int_PE->NPEEXLOJA),EE7->EE7_EXLOJA := Int_PE->NPEEXLOJA,)
IF(!EMPTY(Int_PE->NPECONSIG),EE7->EE7_CONSIG := Int_PE->NPECONSIG,)
IF(!EMPTY(Int_PE->NPECOLOJA),EE7->EE7_COLOJA := Int_PE->NPECOLOJA,)
IF(!EMPTY(Int_PE->NPEBENEF ),EE7->EE7_BENEF  := Int_PE->NPEBENEF ,)
IF(!EMPTY(Int_PE->NPEBELOJA),EE7->EE7_BELOJA := Int_PE->NPEBELOJA,)
IF(!EMPTY(Int_PE->NPEBENEDE),EE7->EE7_BENEDE := Int_PE->NPEBENEDE,)
IF(!EMPTY(Int_PE->NPEENDBEN),EE7->EE7_ENDBEN := Int_PE->NPEENDBEN,)
IF(!EMPTY(Int_PE->NPEEND2BE),EE7->EE7_END2BE := Int_PE->NPEEND2BE,)
IF(!EMPTY(Int_PE->NPECONDPA),EE7->EE7_CONDPA := Int_PE->NPECONDPA,)
IF(!EMPTY(Int_PE->NPEDIASPA),EE7->EE7_DIASPA := Val(Int_PE->NPEDIASPA),)
IF(!EMPTY(Int_PE->NPEMPGEXP),EE7->EE7_MPGEXP := Int_PE->NPEMPGEXP,)
IF(!EMPTY(Int_PE->NPEINCOTE),EE7->EE7_INCOTE := Int_PE->NPEINCOTE,)
IF(!EMPTY(Int_PE->NPEVIA   ),EE7->EE7_VIA    := Int_PE->NPEVIA   ,)
IF(!EMPTY(Int_PE->NPEORIGEM),EE7->EE7_ORIGEM := Int_PE->NPEORIGEM,)
IF(!EMPTY(Int_PE->NPEDEST  ),EE7->EE7_DEST   := Int_PE->NPEDEST  ,)
IF(!EMPTY(Int_PE->NPETIPTRA),EE7->EE7_TIPTRA := Int_PE->NPETIPTRA,)

/*
   ER - 04/09/2006
   Inicio do Procedimento para gravação do Campo EE7_PAISET(País de Entrega).
   Esse campo é gravado por Gatilho na Inclusão do Pedido.
*/
IF !EMPTY(Int_PE->NPEVIA)
   cSeek := AvKey(Int_PE->NPEVIA,"EE7_VIA") 
ENDIF

IF !EMPTY(Int_PE->NPEORIGEM)
   cSeek += AvKey(Int_PE->NPEORIGEM,"EE7_ORIGEM")
ENDIF

IF !EMPTY(Int_PE->NPEDEST)
   cSeek += AvKey(Int_PE->NPEDEST,"EE7_DEST")
ENDIF
 
IF !EMPTY(Int_PE->NPETIPTRA)
   cSeek += AvKey(Int_PE->NPETIPTRA,"EE7_TIPTRA")
ENDIF

IF !EMPTY(cSeek)
   IF EECVia(cSeek)
      EE7->EE7_PAISET := SYR->YR_PAIS_DE 
   ENDIF
ENDIF

IF(!EMPTY(Int_PE->NPEMOEDA ),EE7->EE7_MOEDA  := Int_PE->NPEMOEDA ,)
IF(!EMPTY(Int_PE->NPEFRPPCC),EE7->EE7_FRPPCC := Int_PE->NPEFRPPCC,)
IF(!EMPTY(Int_PE->NPEFRPREV),EE7->EE7_FRPREV := Val(Int_PE->NPEFRPREV),)
IF(!EMPTY(Int_PE->NPEFRPCOM),EE7->EE7_FRPCOM := Val(Int_PE->NPEFRPCOM),)
IF(!EMPTY(Int_PE->NPESEGPRE),EE7->EE7_SEGPRE := Val(Int_PE->NPESEGPRE),)
IF(!EMPTY(Int_PE->NPEDESPIN),EE7->EE7_DESPIN := Val(Int_PE->NPEDESPIN),)
IF(!EMPTY(Int_PE->NPEDESCON),EE7->EE7_DESCON := Val(Int_PE->NPEDESCON),)
IF INT_PE->NPEPRECOA = "S"
   EE7->EE7_PRECOA := "1"
//ELSEIF INT_PE->NPEPRECOA = "N"
Else
   EE7->EE7_PRECOA := "2"
ENDIF
IF(!EMPTY(Int_PE->NPEEMBAFI),EE7->EE7_EMBAFI := Int_PE->NPEEMBAFI,)
IF(!EMPTY(Int_PE->NPECALCEM),EE7->EE7_CALCEM := Int_PE->NPECALCEM,)
IF(!EMPTY(Int_PE->NPECUBAGE),EE7->EE7_CUBAGE := Val(Int_PE->NPECUBAGE),)
SX5->(DBSEEK(cFilSX5+'ID'+AVKey(Int_PE->NPEIDIOMA,"X5_CHAVE")))
IF(!EMPTY(Int_PE->NPEIDIOMA),EE7->EE7_IDIOMA := AVKey(AVKey(Int_PE->NPEIDIOMA,"X5_CHAVE")+"-"+SX5->X5_DESCRI,"EE7_IDIOMA"),)
IF(!EMPTY(Int_PE->NPESL_LC ),EE7->EE7_SL_LC  := IN100CTD(Int_PE->NPESL_LC,,'DDMMAAAA'),)   //MJB-SAP-1100
IF(!EMPTY(Int_PE->NPELC_NUM),EE7->EE7_LC_NUM := Int_PE->NPELC_NUM,)
IF(!EMPTY(Int_PE->NPESL_EME),EE7->EE7_SL_EME := IN100CTD(Int_PE->NPESL_EME,,'DDMMAAAA'),)  //MJB-SAP-1100
IF INT_PE->NPEPGTANT = "S"
   EE7->EE7_PGTANT := "1"
ELSE // IF INT_PE->NPEPGTANT = "N"
   EE7->EE7_PGTANT := "2"
ENDIF
IF(!EMPTY(Int_PE->NPETIPCOM),EE7->EE7_TIPCOM := Int_PE->NPETIPCOM,)
IF(!EMPTY(Int_PE->NPETIPCVL),EE7->EE7_TIPCVL := Int_PE->NPETIPCVL,)
IF(!EMPTY(Int_PE->NPEVALCOM),EE7->EE7_VALCOM := Val(Int_PE->NPEVALCOM),)
IF(!EMPTY(Int_PE->NPEREFAGE),EE7->EE7_REFAGE := Int_PE->NPEREFAGE,)

//ER - 14/09/2006. Zera a Data de Aprovação de Crédito.
If EE7->(FieldPos("EE7_DTAPCR")) > 0   
   EE7->EE7_DTAPCR := AVCTOD("  /  /  ")
EndIf
/*
IF EMPTY(EE7->EE7_DTSLCR)
   M->EE7_STTDES:=EE7->EE7_STATUS:=ST_SC
Else
   M->EE7_STTDES:=EE7->EE7_STATUS:=ST_LC
EndIf*/                                                                                   

//ASK 22/08/2007 - Tratamento do Crédito Automático para pedidos integrados MV_AVG0057
IF !lLibCredAuto
   If Empty(EE7->EE7_DTSLCR)                        
      M->EE7_STTDES:= EE7->EE7_STATUS:= ST_SC  //Aguardando Solicitação de Crétido ...     
   Else
      M->EE7_STTDES:= EE7->EE7_STATUS:= ST_LC  //Aguardando Liberação de Credito ...
   EndIf   
Else
   M->EE7_STTDES:= EE7->EE7_STATUS:= ST_CL     //Credito Liberado ...   
EndIf

/*
AMS - 24/06/2005. Gravação da letra "S" no campo "EE7_INTEGR" para identificar que a origem do
                  pedido é da integração.
*/
If EE7->(FieldPos("EE7_INTEGR")) > 0
   EE7->EE7_INTEGR := "S"
EndIf

//////////////////////////////////////////////////
//Gravação do Campo Tipo do Pedido de Exportação//
//////////////////////////////////////////////////
If EECFLAGS("CAFE_OPCIONAL")
   If !Empty(Int_PE->NPETP)
      EE7->EE7_TIPO := Int_PE->NPETP
   EndIf   
EndIf

// WFS 11/11/2008
/* Função que preencherá o conteúdo dos campos de acordo com o inializador padrão.
Aplicável aos campos não preenchidos pela integração (arquivo Int_PE).*/
EE7IniPad()

DSCSITEE7(.T.)

If lNPENOTIFY .AND. ! Empty(Int_PE->NPENOTIFY)                                             //MJB-SAP-1100
   SA1->(DBSEEK(cFilSA1+AVKey(Int_PE->NPENOTIFY,"A1_COD")+AVKey(Int_PE->NPENOLOJA,"A1_LOJA"))) //MJB-SAP-1100
   If ! EEN->(DbSeek(cFilEEN+AVKey(EE7->EE7_PEDIDO,"EEN_PROCES")+"P"+AVKey(Int_PE->NPENOTIFY,"EEN_IMPORT")+AVKey(Int_PE->NPENOLOJA,"EEN_IMLOJA")))
      RecLock("EEN",.T.)                                                  //MJB-SAP-1100
      EEN->EEN_FILIAL := cFilEEN                                   //MJB-SAP-1100
      EEN->EEN_PROCES := EE7->EE7_PEDIDO                                  //MJB-SAP-1100
      EEN->EEN_OCORRE := "P"                                              //MJB-SAP-1100
   Else                                                                   //MJB-SAP-1100
      RecLock("EEN",.F.)                                                  //MJB-SAP-1100
   Endif                                                                  //MJB-SAP-1100
   EEN->EEN_IMPORT := Int_PE->NPENOTIFY                                   //MJB-SAP-1100
   EEN->EEN_IMLOJA := Int_PE->NPENOLOJA                                   //MJB-SAP-1100
   EEN->EEN_IMPODE := SA1->A1_NOME                                        //MJB-SAP-1100
   EEN->EEN_ENDIMP := EECMEND("SA1",1,EEN->(EEN_IMPORT+EEN_IMLOJA),.T.,LEN(EEN->EEN_ENDIMP))[1] //MJB-SAP-1100 //FDR - 17/05/13
   EEN->EEN_END2IM := EECMEND("SA1",1,EEN->(EEN_IMPORT+EEN_IMLOJA),.T.,LEN(EEN->EEN_END2IM))[2] //MJB-SAP-1100 //FDR - 17/05/13
   EEN->(MsUnlock())                                                      //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100
   
IF !EMPTY(Int_PE->NPEMARCAC)
   lIncMSMM:=.F.
   IF Int_PE->NPETIPO=INCLUSAO .OR. EMPTY(ALLTRIM(EE7->EE7_CODMAR))
      lIncMSMM:=.T.
      nNumMsmm+=1
   ENDIF
   
   // by CAF 12/03/2003 - Tirar os espaços da direita.
   cTxtMM := ALLTRIM(Int_PE->NPEMARCAC)
   cTxtMM := IN100Memo(cTxtMM,"EEC_MARCAC")
   // ***
   
   MSMM(IF(!lIncMSMM,EE7->EE7_CODMAR,IF(lMsmm,STRZERO(nNumMsmm,6),)),TAMSX3("EE7_MARCAC")[1],,cTxtMM,1,,,"EE7","EE7_CODMAR")
EndIf   

IF !EMPTY(Int_PE->NPEGENERI)
   lIncMSMM:=.F.
   IF Int_PE->NPETIPO=INCLUSAO .OR. EMPTY(ALLTRIM(EE7->EE7_CODMAR))
      lIncMSMM:=.T.
      nNumMsmm+=1
   ENDIF
   MSMM(IF(!lIncMSMM,EE7->EE7_DSCGEN,IF(lMsmm,STRZERO(nNumMsmm,6),)),TAMSX3("EE7_GENERI")[1],,ALLTRIM(Int_PE->NPEGENERI),1,,,"EE7","EE7_DSCGEN")
EndIf

If !EMPTY(Int_PE->NPEOBSPED) 
   lIncMSMM:=.F.
   IF Int_PE->NPETIPO=INCLUSAO .OR. EMPTY(ALLTRIM(EE7->EE7_CODMAR))
      lIncMSMM:=.T.
      nNumMsmm+=1
   ENDIF
   MSMM(IF(!lIncMSMM,EE7->EE7_CODOBP,IF(lMsmm,STRZERO(nNumMsmm,6),)),TAMSX3("EE7_OBSPED")[1],,ALLTRIM(Int_PE->NPEOBSPED),1,,,"EE7","EE7_CODOBP")
EndIf
   
If !EMPTY(Int_PE->NPEOBS)
   lIncMSMM:=.F.
   IF Int_PE->NPETIPO=INCLUSAO .OR. EMPTY(ALLTRIM(EE7->EE7_CODMAR))
      lIncMSMM:=.T.
      nNumMsmm+=1
   ENDIF
   MSMM(IF(!lIncMSMM,EE7->EE7_CODMEM,IF(lMsmm,STRZERO(nNumMsmm,6),)),TAMSX3("EE7_OBS")[1],,ALLTRIM(Int_PE->NPEOBS),1,,,"EE7","EE7_CODMEM")
EndIf                                  

Reclock("EE7",.F.)

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVPE")
ENDIF

nTOTAL   := EE7->EE7_TOTPED
nTOTITE  := nVLCOMIS := nTOTLIQ := nTOTBRU := 0
lLASTREC := .F.
cFuncao  := CAD_PD
bMessage := FIELDWBLOCK('NPDMSG',SELECT('Int_PD'))

Int_PD->(DBSEEK(Int_PE->NPEPEDIDO+Int_PE->NPESEQ)) 

DO WHILE ! Int_PD->(EOF()) .AND. Int_PD->NPDPEDIDO+Int_PD->NPDSEQ == Int_PE->NPEPEDIDO+Int_PE->NPESEQ

  IF ! Int_PD->NPDINT_OK = "T"
     Int_PD->(DBSKIP())
     LOOP
  ENDIF

  IF !EE8->(DBSEEK(cFilEE8+AVKey(Int_PD->NPDPEDIDO,"EE8_PEDIDO")+AVKey(Int_PD->NPDPOSICAO,"EE8_SEQUEN")))
    EE8->(DBSEEK(cFilEE8+AVKey(Int_PD->NPDPEDIDO,"EE8_PEDIDO")+AVKey(STR(VAL(Int_PD->NPDPOSICAO),LEN(EE8->EE8_SEQUEN)),"EE8_SEQUEN"))) //RHP
  ENDIF
  IF (Int_PD->NPDTIPO=EXCLUSAO .Or. Int_PD->NPDTIPO=ALTERACAO) .AND. EE8->(EOF())
     Int_PD->(DBSKIP())
     LOOP
  EndIf

  IF Int_PD->NPDTIPO=EXCLUSAO 
     IF ASCAN(aTabEE7,{|chave| chave[1] == Int_PD->NPDPEDIDO}) = 0
        AADD(aTabEE7,{Int_PD->NPDPEDIDO,0})
     ENDIF
     
     MSMM(EE8->EE8_DESC,,,,2)
     Reclock("EE8",.F.)        
     If EasyEntryPoint("IN100CLI") 
        ExecBlock("IN100CLI",.F.,.F.,"DELPD")
     ENDIF
     nTOTAL  := nTOTAL-EE8->(EE8_SLDINI*EE8_PRECO)
     EE8->(DBDELETE())
     EE8->(MSUNLOCK())
  Else
     If Int_PD->NPDTIPO=INCLUSAO
        Reclock("EE8",.T.)
     Else
        Reclock("EE8",.F.)
        nTOTAL := nTOTAL-EE8->(EE8_SLDINI*EE8_PRECO)
     EndIf
     EE8->EE8_FILIAL := cFILEE8
     IF(!EMPTY(Int_PD->NPDPEDIDO ),EE8->EE8_PEDIDO  := Int_PD->NPDPEDIDO ,) 
     IF(!EMPTY(Int_PD->NPDCOD_I  ),EE8->EE8_COD_I   := Int_PD->NPDCOD_I  ,) 
     IF(!EMPTY(Int_PD->NPDFORN   ),EE8->EE8_FORN    := Int_PD->NPDFORN   ,) 
     IF(!EMPTY(Int_PD->NPDFOLOJA ),EE8->EE8_FOLOJA  := Int_PD->NPDFOLOJA ,) 
     IF(!EMPTY(Int_PD->NPDFABR   ),EE8->EE8_FABR    := Int_PD->NPDFABR   ,) 
     IF(!EMPTY(Int_PD->NPDFALOJA ),EE8->EE8_FALOJA  := Int_PD->NPDFALOJA ,) 
     IF(!EMPTY(Int_PD->NPDPART_N ),EE8->EE8_PART_N  := Int_PD->NPDPART_N ,) 
     IF(!EMPTY(Int_PD->NPDDTPREM ),EE8->EE8_DTPREM  := IN100CTD(Int_PD->NPDDTPREM,,'DDMMAAAA'),) //MJB-SAP-1100
     IF(!EMPTY(Int_PD->NPDDTENTR ),EE8->EE8_DTENTR  := IN100CTD(Int_PD->NPDDTENTR,,'DDMMAAAA'),) //MJB-SAP-1100 
     IF(!EMPTY(Int_PD->NPDUNIDAD ),EE8->EE8_UNIDAD  := Int_PD->NPDUNIDAD ,) 
     
     /*
        ER - 15/09/2006
        Controle do Saldo Atual para Alteração de Item
     */
     nSldAtu := 0
     If Int_PD->NPDTIPO == ALTERACAO 
        
        nSldOld := EE8->EE8_SLDATU
        
        If EE8->EE8_SLDINI <> nSldOld
           If Val(Int_PD->NPDSLDINI) > EE8->EE8_SLDINI
              nSldAtu := (Val(Int_PD->NPDSLDINI)-EE8->EE8_SLDINI)+nSldOld
           ElseIf Val(Int_PD->NPDSLDINI) < EE8->EE8_SLDINI
              nDiferenca := EE8->EE8_SLDINI - Val(Int_PD->NPDSLDINI)
              nSldAtu := EE8->EE8_SLDATU - nDiferenca
           Else
              nSldAtu := nSldOld
           EndIf
        Else
           nSldAtu := Val(Int_PD->NPDSLDINI)
        EndIf

     Else
        nSldAtu := Val(Int_PD->NPDSLDINI)
     EndIf   
        
     EE8->EE8_SLDATU := nSldAtu
     
     IF(!EMPTY(Int_PD->NPDSLDINI ),EE8->EE8_SLDINI  := Val(Int_PD->NPDSLDINI),) 
     IF(!EMPTY(Int_PD->NPDEMBAL1 ),EE8->EE8_EMBAL1  := Int_PD->NPDEMBAL1 ,) 
     IF(!EMPTY(Int_PD->NPDQE     ),EE8->EE8_QE      := Val(Int_PD->NPDQE)    ,) 
     IF(!EMPTY(Int_PD->NPDQTDEM1 ),EE8->EE8_QTDEM1  := Val(Int_PD->NPDQTDEM1),) 
     IF(!EMPTY(Int_PD->NPDPRECO  ),EE8->EE8_PRECO   := Val(Int_PD->NPDPRECO) ,) 
     IF(!EMPTY(Int_PD->NPDPRECOI ),EE8->EE8_PRECOI  := Val(Int_PD->NPDPRECOI),) 
     IF(!EMPTY(Int_PD->NPDPSLQUN ),EE8->EE8_PSLQUN  := Val(Int_PD->NPDPSLQUN),) 
     IF(!EMPTY(Int_PD->NPDPSLQTO ),EE8->EE8_PSLQTO  := Val(Int_PD->NPDPSLQTO),)
     IF lNPDPSBRUN
        IF(!EMPTY(Int_PD->NPDPSBRUN ),EE8->EE8_PSBRUN  := Val(Int_PD->NPDPSBRUN),)
        IF ! lCALCPESO
           lCALCPESO := IF(EMPTY(INT_PD->NPDPSBRUN),.T.,.F.)
        ENDIF
     ENDIF
     IF lNPDPSBRTO
        IF(!EMPTY(Int_PD->NPDPSBRTO ),EE8->EE8_PSBRTO := Val(Int_PD->NPDPSBRTO),)
        IF ! lCALCPESO
           lCALCPESO := IF(EMPTY(INT_PD->NPDPSBRTO),.T.,.F.)
        ENDIF
     ENDIF
     IF(!EMPTY(Int_PD->NPDFPCOD  ),EE8->EE8_FPCOD   := Int_PD->NPDFPCOD  ,) 
     IF(!EMPTY(Int_PD->NPDGPCOD  ),EE8->EE8_GPCOD   := Int_PD->NPDGPCOD  ,) 
     IF(!EMPTY(Int_PD->NPDDPCOD  ),EE8->EE8_DPCOD   := Int_PD->NPDDPCOD  ,) 
     IF(!EMPTY(Int_PD->NPDPOSIPI ),EE8->EE8_POSIPI  := Int_PD->NPDPOSIPI ,) 

     /** By JBJ - 07/03/03 - 09:48 - Busca dos códigos do cadastro.
     IF(!EMPTY(Int_PD->NPDNLNCCA ),EE8->EE8_NLNCCA  := Int_PD->NPDNLNCCA ,) 
     IF(!EMPTY(Int_PD->NPDNALSH  ),EE8->EE8_NALSH   := Int_PD->NPDNALSH  ,) 
     */

     If !Empty(Int_PD->NPDNLNCCA)
        EE8->EE8_NLNCCA := Int_PD->NPDNLNCCA
     Else
        SB1->(DbSeek(cFilSB1+AvKey(Int_PD->NPDCOD_I,"EE8_COD_I")))
        EE8->EE8_NLNCCA := SB1->B1_NALNCCA
     EndIf

     If !Empty(Int_PD->NPDNALSH)
        EE8->EE8_NALSH := Int_PD->NPDNALSH
     Else
        SB1->(DbSeek(cFilSB1+AvKey(Int_PD->NPDCOD_I,"EE8_COD_I")))
        EE8->EE8_NALSH := SB1->B1_NALSH
     EndIf

     IF(!EMPTY(Int_PD->NPDPOSICAO),EE8->EE8_SEQUEN  := STR(VAL(Int_PD->NPDPOSICAO),LEN(EE8->EE8_SEQUEN)),) 
     IF(!EMPTY(Int_PD->NPDREFCLI) ,EE8->EE8_REFCLI  := Int_PD->NPDREFCLI,)
     If !EMPTY(Int_PD->NPDDECIT)
        lIncMSMM:=.F.
        IF Int_PD->NPDTIPO=INCLUSAO .OR. EMPTY(ALLTRIM(EE8->EE8_DESC))
           lIncMSMM:=.T.
           nNumMsmm+=1
        ENDIF
        MSMM(IF(!lIncMSMM,EE8->EE8_DESC,IF(lMsmm,STRZERO(nNumMsmm,6),)),TAMSX3("EE8_VM_DES")[1],,ALLTRIM(Int_PD->NPDDECIT),1,,,"EE8","EE8_DESC")
     EndIf                                  
     
     EE8->(MsUnLock())

     Reclock("EE8",.F.)
     If EasyEntryPoint("IN100CLI")
        ExecBlock("IN100CLI",.F.,.F.,"GRVPD")
     ENDIF

     //igor chiba 23/12/2010
     //  chamar a funçao do avinteg para o item do pedido , esta funçao grava na base os campos que não tratados pelo EICIN100
     IF lBUpDate
        oldcfuncao:=cfuncao
        cfuncao   :="PD"
        EasyExRdm("AvIntExtra")
        cfuncao   :=oldcfuncao
     ENDIF

     
     EE8->(MsUnLock())

     Reclock("EE8",.F.)
     If EasyEntryPoint("IN100CLI")
        ExecBlock("IN100CLI",.F.,.F.,"GRVPD")
     ENDIF
     nTOTAL  := nTOTAL+EE8->(EE8_SLDINI*EE8_PRECO)
  EndIf
  Int_PD->(DBSKIP())
ENDDO
EE7->EE7_TOTPED := 0
nVLDESPESA      := EE7->((EE7_SEGPRE+EE7_FRPREV+EE7_FRPCOM+EE7_DESPIN)-EE7_DESCON)
nAUXDESP        := nVLDESPESA
nTOTRATEIO      := 0
IF ! Empty(EE7->EE7_VALCOM) .And. EE7->EE7_TIPCOM == "3" // Tipo de Comissao = Deduzir da Fatura
   nVLCOMIS := EE7->(IF(EE7_TIPCVL="1",(EE7_VALCOM/100)*nTOTAL,; // PERCENTUAL
                                       EE7_VALCOM))              // VALOR NORMAL
ENDIF
nPRECOTOT := nTOTAL
IF EE7->EE7_PRECOA $ cNAO
   nPRECOTOT := (nTOTAL-EE7->(EE7_SEGPRE+EE7_FRPREV+EE7_FRPCOM+EE7_DESPIN))+EE7->EE7_DESCON+NVLCOMIS
Endif
EE8->(DBSETORDER(1))
EE8->(DBSEEK(cFilEE8+EE7->EE7_PEDIDO))
DO WHILE ! EE8->(EOF()) .AND.;
   EE8->(EE8_FILIAL+EE8_PEDIDO) = (cFilEE8+EE7->EE7_PEDIDO)
   *
   EE8->(RECLOCK("EE8",.F.))
   nFATOR     := IF(nTOTAL=0,0,EE8->(EE8_PRECO*EE8_SLDINI)/nTOTAL)
   nTOTRATEIO := nTOTRATEIO+nFATOR
   // Verifica se e o ultimo registro ...
   nRECATUAL  := EE8->(RECNO())
   EE8->(DBSKIP())
   IF EE8->(EOF()) .OR. EE8->(EE8_FILIAL+EE8_PEDIDO) # (cFilEE8+EE7->EE7_PEDIDO)
      lLASTREC := .T.
      // Ultimo registro ...
      IF nTOTRATEIO # 1
         nFATOR := nFATOR+(1-nTOTRATEIO)
      ENDIF
   ENDIF
   EE8->(DBGOTO(nRECATUAL))
   nPRECOI         := ROUND((nFATOR*nPRECOTOT)/EE8->EE8_SLDINI,nDECPRC)
   EE8->EE8_PRECOI := nPRECOI
   nAUXVAL         := nFATOR*nVLDESPESA
 //EE8->EE8_PRCTOT := ROUND((nPRECOI*EE8->EE8_SLDINI)+nAUXVAL,4)
   EE8->EE8_PRCTOT := ROUND((nPRECOI*EE8->EE8_SLDINI)+nAUXVAL, EECPreco("EE8_PRCTOT", AV_DECIMAL))
 //EE8->EE8_PRCINC := ROUND(nPRECOI*EE8->EE8_SLDINI,4)
   EE8->EE8_PRCINC := ROUND(nPRECOI*EE8->EE8_SLDINI, EECPreco("EE8_PRCINC", AV_DECIMAL))
   IF EE7->EE7_PRECOA $ cSim
    //EE8->EE8_PRCINC := ROUND(EE8->(EE8_PRECO*EE8_SLDINI),2)
      EE8->EE8_PRCINC := ROUND(EE8->(EE8_PRECO*EE8_SLDINI), EECPreco("EE8_PRCINC", AV_DECIMAL))
   ELSE
    //EE8->EE8_PRCTOT := ROUND(EE8->(EE8_PRECO*EE8_SLDINI),2)
      EE8->EE8_PRCTOT := ROUND(EE8->(EE8_PRECO*EE8_SLDINI), EECPreco("EE8_PRCTOT", AV_DECIMAL))
   ENDIF
   nAUXDESP := nAUXDESP-nAUXVAL
   IF lLASTREC .AND. nAUXDESP # 0
      EE8->EE8_PRCTOT := EE8->EE8_PRCTOT+nAUXDESP
   ENDIF
   EE7->EE7_TOTPED := EE7->EE7_TOTPED+EE8->EE8_PRCINC
   nTOTITE         := nTOTITE+1
   // CALCULANDO OS PESOS
   IF lCALCPESO
      AP101CalcPsBr(OC_PE)
   ENDIF
   nTOTLIQ := nTOTLIQ+EE8->EE8_PSLQTO
   nTOTBRU := nTOTBRU+EE8->EE8_PSBRTO
   EE8->(MSUNLOCK(),DBSKIP())
Enddo
// GRAVA OS TOTAIS DA CAPA - EE7
EE7->EE7_TOTITE := nTOTITE  // QUANTIDADE DE ITENS DO PROCESSO
EE7->EE7_PESLIQ := nTOTLIQ
EE7->EE7_PESBRU := nTOTBRU

/*
AMS - 16/09/2005. Calculo dos totais no item.
*/
AP105CallPrecoI(, .F.) 

If EasyEntryPoint("IN100CLI")  
      ExecBlock("IN100CLI",.F.,.F.,"ICALCPESO")
ENDIF

*
DBSELECTAREA('Int_PE')
FOR I=1 TO LEN(aTabEE7)
    IF ! EE8->(DBSEEK(cFilEE8+AVKey(aTabEE7[I,1],"EE8_PEDIDO")))
       IF EE7->(DBSEEK(cFilEE7+AVKey(aTabEE7[I,1],"EE7_PEDIDO")))
          If EasyEntryPoint("IN100CLI")
             ExecBlock("IN100CLI",.F.,.F.,"DELPE")
          ENDIF   
          MSMM(EE7->EE7_CODMAR,,,,2)
          MSMM(EE7->EE7_DSCGEN,,,,2)
          MSMM(EE7->EE7_CODOBP,,,,2)
          MSMM(EE7->EE7_CODMEM,,,,2)
          Reclock("EE7",.F.)          
          EE7->(DBDELETE())
       ENDIF
    ENDIF
NEXT
cFuncao := CAD_PE
bMessage:= bSave
EE7->(MSUNLOCK())
End Transaction

DBSELECTAREA('Int_PE')

RestOrd(aOrd)

RETURN .T.

**************************************IMPRESSAO DO ITEM ********************************
*-----------------------------------------------------------------------------
FUNCTION IN100PrItPe(cTit,cAreaD,lEnd,wnRel,cString,bTit,bCab,bDet,bKeyDet,bWhile,cAreaH)
*-----------------------------------------------------------------------------
LOCAL nLinha
M_Pag:= 1
Limite:=130
Li:= 80

SetRegua(nTotReg)

If aReturn[4] == 1                              // Comprimido
   @ 001,000 PSAY &(aDriver[1])
ElseIf aReturn[4] == 2                          // Normal
   @ 001,000 PSAY &(aDriver[2])
EndIf

DBSELECTAREA(cAreaH)
DBGOTOP()
DBEVAL( {||IN100RelItPe(cAreaD,bTit,bCab,bDet,bKeyDet,bWhile,@lEnd,wnRel,cString,cAreaH) } )
DBGOTOP()
(cAreaD)->(DBGOTOP())

IF Li != 80
   Li++
   roda(0,"",tamanho)
End
(cAreaD)->(DBGOTOP())

RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100RelItPe(cAreaD,bTit,bCab,bDet,bKeyDet,bWhile,lEnd,wnRel,cString,cAreaH)
*-----------------------------------------------------------------------------
LOCAL cKeyDet:=EVAL(bKeyDet)
IncRegua()
DBSELECTAREA(cAreaH)
If &(cValid)
   IF (Li+nTamCab) > 55
      EVAL(bTit)
   ELSE
      @ Li++,001 PSAY REPLI(CHR(196),135)
      EVAL(bCab)
   ENDIF
   (cAreaD)->(DBSEEK(cKeyDet))
   (cAreaD)->(DBEVAL(bDet,,bWhile))
EndIf
RETURN .T.

*-----------------------------------------------------------------------------
FUNCTION IN100TitIT(cTit,lEnd)
*-----------------------------------------------------------------------------
Cabec(cTit,cCabec1,cCabec2,nomeprog,tamanho,nComprimido)

IN100CabIT()

*-----------------------------------------------------------------------------
FUNCTION IN100CabIT()
*-----------------------------------------------------------------------------
LOCAL cStatus:=IF(EVAL(bStatus),STR0209,STR0210)  // ACEITO, REJEITADO // Indice
LOCAL cStaItem:=IF(Int_IT->NITTIPO=STR0212,IF(Int_IT->NITITEM_OK= "T","",STR0211),"") // "A"    "              ITEM POSSUI IDIOMA REJEITADO"
LOCAL dDtInteg:=IN100CTD(EVAL(bDtInteg))

@ Li++,001 PSAY STR0213+IN100TIPO()+"  /  "+cStatus+cStaItem   // TIPO /  Status...: 
@ Li++,054 PSAY STR0214+DTOC(dDtInteg) 						   // Data Integracao..: 
@ Li  ,001 PSAY STR0087+"...: "+Int_IT->NITCOD_I 			   // Codigo do Item...: 
@ Li  ,054 PSAY STR0089+"..: "+Int_IT->NITUNI 				   // Unidade de Medida..: 
@ Li  ,108 PSAY STR0217+Int_IT->NITPESO_L  					   // "Peso Liquido.......: "

Li++
@ Li,001 PSAY STR0088+".: "+MEMOLINE(Int_IT->NITDESC_G,20) // Descricao Generica

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"IMPCAPAIT1")
EndIf

Li++
@ Li,001 PSAY STR0046+".........: " // Mensagem.........: 
IN100RelE_MSG()

IF Li <= 55
// @++Li,001  PSAY "Status                           Tipo        Cadastro     Idioma       Descricao                                              Mensagem"
   @++Li,001  PSAY STR0030+"                           "+STR0044+"        "+STR0101+"     "+STR0102+"       "+STR0100+"                                              "+STR0046
   @++Li,001  PSAY "------------------------------ ------------- ----------   -----------  -----------------------------------------------------  -----------------------------------------"
   Li++
   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"IMPCABIDITENS")
   EndIf
ENDIF
RETURN NIL

*-----------------------------------------------------------------------------
FUNCTION IN100DetID(cTit)
*-----------------------------------------------------------------------------
LOCAL cStatus:=IF(EVAL(bStatus),STR0209,STR0210) // "ACEITO","REJEITADO"
LOCAL Indice, nLinMsg:=MLCOUNT(ALLTRIM(Int_ID->NIDMSG),LEN_MSG)
//LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))

IF Li > 55
   IN100TitIT(cTit,@lEnd)
ENDIF

@ Li,001 PSAY cStatus
@ Li,032 PSAY Int_ID->NIDTIPO
@ Li,046 PSAY Int_ID->NIDCAD
@ Li,059 PSAY Int_ID->NIDIDIOMA
@ Li,072 PSAY MEMOLINE(Int_ID->NIDDESCID,51)

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"IMPISITENS")
    EndIf

FOR Indice:=1 TO nLinMsg
    IF(Li > 55, IN100TitIT(cTit),)
    @Li++,128 PSAY MEMOLINE(Int_ID->NIDMSG,LEN_MSG,Indice)
Next
IF(nLinMsg=0,Li++,)

RETURN NIL                                             


*-----------------------------------------------------------------------------
FUNCTION IN100TitPE(cTit,lEnd)
*-----------------------------------------------------------------------------
Li:=Cabec(cTit,cCabec1,cCabec2,nomeprog,tamanho,nComprimido)

IN100CabPE()
Return .T.

*-----------------------------------------------------------------------------
FUNCTION IN100CabPE()
*-----------------------------------------------------------------------------
LOCAL cStatus:=IF(EVAL(bStatus),STR0209,STR0210) //"ACEITO"###"REJEITADO" //, Indice
LOCAL cStaItem:=IF(Int_PE->NPETIPO='A',IF(Int_PE->NPEITEM_OK= "T","",STR0254),"") //"       PROCESSO POSSUI ITEM REJEITADO"
LOCAL dDtInteg:=IN100CTD(EVAL(bDtInteg))

Li++
@ Li,001 PSAY STR0213+IN100TIPO()+" / "+cStatus+cStaItem // TIPO /  Status......: 
@ Li,054   PSAY STR0214+DTOC(dDtInteg) 						 // Data Integracao.....: 
@ Li,108   PSAY STR0215+Int_PE->NPERESPON 				// Analista Respons....: 

Li++
@ Li,001 PSAY STR0216+Int_PE->NPEPEDIDO 					 // Codigo do Processo..: 
@ Li,054 PSAY STR0218+DTOC(IN100CTD(Int_PE->NPEDTPROC)) 	 // Data do Processo....: 
@ Li,108 PSAY STR0219+DTOC(IN100CTD(Int_PE->NPEDTPEDI))		 // Data do Pedido......: 

Li++
@ Li,001 PSAY STR0220+AVKey(Int_PE->NPEIMPORT,"EE7_IMPORT") 					 // Codigo do Importador: 
@ Li,054 PSAY STR0221+Int_PE->NPEIMLOJA 			   // Loja do Importador..: 

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"IMPCAPAPE0")
EndIf

Li++
@ Li,001 PSAY STR0222+Int_PE->NPEFORN 			// Codigo do Fornec....: 
@ Li,054 PSAY STR0223+Int_PE->NPEFOLOJA         // Loja do Fornecedor..: 

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"IMPCAPAPE1")
EndIf

Li++
@ Li,001 PSAY STR0224 // "Mensagem.........: "
Linha:=Li
IN100RelE_MSG()
Li:=Linha

IF Li <= 55
// @++Li,001 PSAY "Status           Tipo     Item                       Descricao                                     Unidade          Quantidade     Preco Unit.     Peso Liq.        Peso Bruto       Mensagem"
   @++Li,001 PSAY STR0030+"           "+STR0044+"     "+STR0225+"                       "+STR0100+"                                     "+STR0121+"          "+STR0155+"     "+STR0155+"  "+STR0172+"        "+STR0226+"       "+STR0046
   @++Li,001 PSAY "---------------- -------- -------------------------- --------------------------------------------- ---------------  -------------- --------------- ---------------- ---------------- ---------------------------------------"
   Li++

   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"IMPCABPDITENS")
   EndIf

ENDIF
RETURN NIL

*-----------------------------------------------------------------------------
FUNCTION IN100DetPE(cTit,lEnd)
*-----------------------------------------------------------------------------
LOCAL cStatus:=IF(EVAL(bStatus),STR0209,STR0210)  // "ACEITO","REJEITADO"
LOCAL Indice, nLinMsg:=MLCOUNT(ALLTRIM(Int_PD->NPDMSG),LEN_MSG)
//LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))

IF Li > 55
   IN100TitPE(cTit,@lEnd)
ENDIF

@ Li,001 PSAY ALLTRIM(cStatus)
@ Li,018 PSAY ALLTRIM(Int_PD->NPDTIPO)
@ Li,027 PSAY ALLTRIM(Int_PD->NPDCOD_I)
@ Li,054 PSAY ALLTRIM(MEMOLINE(Int_PD->NPDDECIT,45))+" "
@ Li,100 PSAY LEFT(Int_PD->NPDUNIDAD,7)
@ Li,108 PSAY RIGHT(TRAN(VAL(Int_PD->NPDSLDINI),AVSX3("EE8_SLDINI",6)),17)
//@ Li,127 PSAY RIGHT(TRAN(VAL(Int_PD->NPDPRECO) ,AVSX3("EE8_PRECO" ,6)),20)
@ Li,127 PSAY RIGHT(TRAN(VAL(Int_PD->NPDPRECO),EECPreco("EE8_PRECO", AV_PICTURE)),20)
@ Li,148 PSAY TRAN(VAL(Int_PD->NPDPSLQUN),AVSX3("EE8_PSLQUN",6))
@ Li,165 PSAY TRAN(VAL(Int_PD->NPDPSLQTO),AVSX3("EE8_PSLQTO",6))

If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"IMPPDITENS")
EndIf

FOR Indice:=1 TO nLinMsg
    IF(Li > 55, IN100TitPE(cTit),)   //58
    @Li++,182 PSAY MEMOLINE(Int_PD->NPDMSG,LEN_MSG,Indice)
NEXT
IF(nLinMsg=0,Li++,)
RETURN NIL

Function INIDIOMA(cCampo)
LOCAL cRet
   If SX5->(DBSEEK(cFilSX5+'ID'+cCampo))
      cRet:=cCampo+"-"+X5DESCRI()
   Else
      cRet:=cCampo
   EndIf
Return cRet
*--------------------------------------------------------------------
FUNCTION IN100NS()
LOCAL cPI1 := AVSX3("EEM_VLNF"  ,AV_PICTURE),;
      cPI2 := AVSX3("EEM_VLMERC",AV_PICTURE),;
      cPI3 := AVSX3("EEM_VLFRET",AV_PICTURE),;
      cPI4 := AVSX3("EEM_VLSEGU",AV_PICTURE),;
      cPI5 := AVSX3("EEM_OUTROS",AV_PICTURE)
*
AADD(TB_Cols,{{|| NNSPRO                     },"",STR0246})  // PROCESSO
AADD(TB_COLS,{{|| NNSNF                      },"",STR0233})  // NOTA FISCAL
AADD(TB_COLS,{{|| NNSSER                     },"",STR0234})  // SERIE DA NOTA FISCAL
AADD(TB_COLS,{{|| IN100CTD(NNSDT)            },"",STR0235})  // DATA DA NOTA FISCAL
AADD(TB_COLS,{{|| IN100TIPNS()               },"",STR0236})  // TIPO DE NOTA FISCAL
AADD(TB_COLS,{{|| TRANSFORM(VAL(NNSVNF),cPI1)},"",STR0237})  // VALOR DA NOTA FISCAL
AADD(TB_COLS,{{|| TRANSFORM(VAL(NNSVME),cPI2)},"",STR0238})  // VALOR DA MERCADORIA
AADD(TB_COLS,{{|| TRANSFORM(VAL(NNSVFR),cPI3)},"",STR0239})  // VALOR DO FRETE
AADD(TB_COLS,{{|| TRANSFORM(VAL(NNSVSE),cPI4)},"",STR0240})  // VALOR DO SEGURO
AADD(TB_COLS,{{|| TRANSFORM(VAL(NNSTOU),cPI5)},"",STR0241})  // VALOR OUTRAS DESPESAS
AADD(TB_COLS,{{|| NNSPED                     },"",STR0243})  // NUMERO DO PEDIDO DO ITEM
AADD(TB_COLS,{{|| NNSITE                     },"",STR0244})  // ITEM
AADD(TB_COLS,{{|| NNSPOS                     },"",STR0245})  // SEQUENCIA DO ITEM NO PEDIDO
*
ASIZE(TBRCols,0)
AADD(TBRCols,{{|| IN100Status()              },STR0030}) // Status
AADD(TBRCols,{{|| IN100Tipo()                },STR0044}) // Tipo
AADD(TBRCols,{{|| IN100CTD(NNSINT_DT)        },STR0045}) // Dt Integ
AADD(TBRCols,{{|| NNSPRO                     },STR0246}) // PROCESSO
AADD(TBRCOLS,{{|| NNSNF                      },STR0233}) // NOTA FISCAL
AADD(TBRCOLS,{{|| NNSSER                     },STR0234}) // SERIE DA NOTA FISCAL
AADD(TBRCOLS,{{|| IN100CTD(NNSDT)            },STR0235}) // DATA DA NOTA FISCAL
AADD(TBRCOLS,{{|| IN100TIPNS()               },STR0236}) // TIPO DE NOTA FISCAL
AADD(TBRCOLS,{{|| TRANSFORM(VAL(NNSVNF),cPI1)},STR0237}) // VALOR DA NOTA FISCAL
AADD(TBRCOLS,{{|| TRANSFORM(VAL(NNSVME),cPI2)},STR0238}) // VALOR DA MERCADORIA
AADD(TBRCOLS,{{|| TRANSFORM(VAL(NNSVFR),cPI3)},STR0239}) // VALOR DO FRETE
AADD(TBRCOLS,{{|| TRANSFORM(VAL(NNSVSE),cPI4)},STR0240}) // VALOR DO SEGURO
AADD(TBRCOLS,{{|| NNSPED                     },STR0243}) // NUMERO DO PEDIDO DO ITEM
AADD(TBRCOLS,{{|| NNSITE                     },STR0244}) // ITEM
AADD(TBRCOLS,{{|| NNSPOS                     },STR0245}) // SEQUENCIA DO ITEM NO PEDIDO
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLNS")
ENDIF                           
AADD(TB_Cols,{{|| IN100E_Msg(.T.)}  ,"",STR0046})
Return .T.

*--------------------------------------------------------------------
FUNCTION IN100LERNS()
LOCAL lEEM, nVlNf:=0
aEE9PROC := {}
aNF_NS   := {}
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERNS")
ENDIF
 
// VERIFICA SE CAMPOS OBRIGATORIOS FORAM ENVIADOS
IF EMPTY(INT_NS->NNSPRO)
   EVAL(bMSG,STR0246+STR0230) // PROCESSO NAO INFORMADO
ENDIF
IF EMPTY(INT_NS->NNSNF)
   EVAL(bmsg,STR0233+STR0230)  // NOTA FISCAL NAO INFORMADA
ENDIF   
IF EMPTY(INT_NS->NNSSER)
   EVAL(bmsg,STR0234+STR0230)  // SERIE NAO INFORMADA
ENDIF   
IF ! IN100CTD(INT_NS->NNSDT,.T.)
   EVAL(bMSG,STR0235+STR0227)  // DATA DA NOTA FISCAL INVALIDA
ENDIF   
IF AT(INT_NS->NNSTNF,"123") = 0
   EVAL(bmsg,STR0236+STR0227)  // TIPO INVALIDO
ENDIF
IF IN100NAONUM(INT_NS->NNSVNF)
   EVAL(bmsg,STR0237+STR0227)  // VALOR N.F. INVALIDO
ENDIF
IF INT_NS->(!EMPTY(NNSVME) .AND. TYPE(NNSVME) # "N") .OR.;
   VAL(INT_NS->NNSVME) < 0
   *
   EVAL(bmsg,STR0238+STR0227)  // VALOR DA MERCADORIA INVALIDO
ENDIF
IF INT_NS->(!EMPTY(NNSVFR) .AND. TYPE(NNSVFR) # "N") .OR.;
   VAL(INT_NS->NNSVFR) < 0
   *
   EVAL(bmsg,STR0239+STR0227)  // VALOR DO FRETE INVALIDO
ENDIF
IF INT_NS->(!EMPTY(NNSVSE) .AND. TYPE(NNSVSE) # "N") .OR.;
   VAL(INT_NS->NNSVSE) < 0
   *
   EVAL(bmsg,STR0240+STR0227)  // VALOR DO SEGURO INVALIDO
ENDIF
IF INT_NS->(!EMPTY(NNSTOU) .AND. TYPE(NNSTOU) # "N") .OR.;
   VAL(INT_NS->NNSTOU) < 0
   *
   EVAL(bmsg,STR0241+STR0227)  // TOTAL DE OUTRAS DESPESAS INVALIDO
ENDIF
IF EMPTY(INT_NS->NNSPED)
   EVAL(bMSG,STR0243+STR0230) // PEDIDO NAO INFORMADO
ENDIF
*
EEC->(DBSETORDER(1))
IF ! (EEC->(DBSEEK(cFilEEC+INT_NS->NNSPRO)))
   EVAL(bmsg,STR0246+STR0242)  // PROCESSO NAO CADASTRADO
ELSEIF EEC->EEC_STATUS = ST_EM
       EVAL(bMSG,STR0246+" "+STR0247) // PROCESSO EMBARCADO
ELSEIF EEC->EEC_STATUS = ST_PC
       EVAL(bMSG,STR0246+" "+STR0248) // PROCESSO CANCELADO
ENDIF
*
EE9->(DBSETORDER(1))
IF !(EE9->(DBSEEK(cFilEE9+INT_NS->(AVKEY(NNSPED,"EE9_PEDIDO")+AVKEY(NNSPOS,"EE9_SEQUEN")+AVKEY(NNSPRO,"EE9_PREEMB"))))) .OR. ;
   !(EE9->(DBSEEK(cFilEE9+INT_NS->(AVKEY(NNSPED,"EE9_PEDIDO")+STR(VAL(NNSPOS),LEN(EE9->EE9_SEQUEN))+AVKEY(NNSPRO,"EE9_PREEMB")))))
   EVAL(bmsg,STR0249)  // PEDIDO+SEQUENCIA+PROCESSO NAO EXISTE
ELSEIF EE9->EE9_COD_I # INT_NS->NNSITE
       EVAL(bMSG,STR0250) // ITEM ENVIADO NAO CONFERE COM ITEM DO PROCESSO
ENDIF
*
lEEM := POSEEM()
IF INT_NS->NNSTIPO = INCLUSAO .AND. lEEM
   EVAL(bMSG,STR0233+STR0229)  // SEQUENCIA INVALIDA
ELSEIF INT_NS->NNSTIPO = ALTERACAO .AND. ! lEEM
       IF lINCALTNS
          INT_NS->NNSTIPO := INCLUSAO
       ELSE
          EVAL(bMSG,STR0233+STR0242)  // NOTA FISCAL NAO CADASTRADA
       ENDIF
ELSEIF INT_NS->NNSTIPO = EXCLUSAO .AND. ! lEEM
       EVAL(bMSG,STR0233+STR0242)  // NOTA FISCAL NAO CADASTRADA
ENDIF

nVlNf := (Val(Int_Ns->NNSVFR)+Val(Int_Ns->NNSVSE)+Val(Int_Ns->NNSTOU)+Val(Int_Ns->NNSVME))
If EasyGParam( "MV_AVG0102",, .T. ) //RMD - 29/08/05   
   If nVlNf <> Val(Int_Ns->NNSVNF)
      Eval(bMsg,STR0300) //"Total da nota não confere com a soma das Despesas+Vl.Merc."
   EndIf
EndIf

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALNS")
ENDIF

IN100VerErro(cErro,cAviso)
IF Int_NS->NNSINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF
Return(.T.)
*--------------------------------------------------------------------
FUNCTION IN100GRVNS()
LOCAL n1,lEEM := .F.
IF ASCAN(aEE9PROC,INT_NS->NNSPRO) = 0
   AADD(aEE9PROC,INT_NS->NNSPRO)
ENDIF
n1 := ASCAN(aNF_NS,{|X| X[1] = INT_NS->(NNSPRO+NNSSER+NNSNF)})
IF n1 = 0
   AADD(aNF_NS,{INT_NS->(NNSPRO+NNSSER+NNSNF),0})
   IF INT_NS->NNSTIPO = ALTERACAO .OR. INT_NS->NNSTIPO = EXCLUSAO
      lEEM := POSEEM()
      EEM->(RECLOCK("EEM",.F.))
      aNF_NS[LEN(aNF_NS),2] := EEM->(RECNO())
      EEM->EEM_VLMERC       := 0
   ENDIF
ENDIF
IF INT_NS->NNSTIPO = INCLUSAO
   IF n1 = 0
      EEM->(RECLOCK("EEM",.T.))
      EEM->EEM_FILIAL       := cFilEEM
      EEM->EEM_PREEMB       := INT_NS->NNSPRO
      EEM->EEM_TIPOCA       := EEM_NF
      aNF_NS[LEN(aNF_NS),2] := EEM->(RECNO())
   ENDIF
ENDIF
IF n1 # 0 .AND. INT_NS->NNSTIPO # EXCLUSAO
   EEM->(DBGOTO(aNF_NS[n1,2]))
   EEM->(RECLOCK("EEM",.F.))
ENDIF
EE9->(DBSETORDER(1))
IF  EE9->(DBSEEK(cFilEE9+INT_NS->(AVKEY(NNSPED,"EE9_PEDIDO")+AVKEY(NNSPOS,"EE9_SEQUEN")+AVKEY(NNSPRO,"EE9_PREEMB")))) .OR.;
  EE9->(DBSEEK(cFilEE9+INT_NS->(AVKEY(NNSPED,"EE9_PEDIDO")+AVKEY(NNSPOS,"EE9_SEQUEN")+STR(VAL(NNSPRO),LEN(EE9->EE9_PREEMB)))))
EE9->(RECLOCK("EE9",.F.))
IF INT_NS->NNSTIPO = EXCLUSAO
   IF lEEM
      //** AAF 09/01/08 - Estorna a Nota Fiscal no Contábil
      If EasyGParam("MV_EEC_ECO",,.F.)
         AE100EstCon("ESTORNA_NF",EEM->EEM_PREEMB)
      EndIf
      //**
      
      EEM->(DBDELETE())
	  EEM->(DBCOMMITALL())
   ENDIF
   EE9->EE9_NF    := ""
   EE9->EE9_SERIE := ""
ELSE
   EEM->EEM_NRNF   := IF(n1=0,INT_NS->NNSNF          ,EEM->EEM_NRNF)
   EEM->EEM_SERIE  := IF(n1=0,INT_NS->NNSSER         ,EEM->EEM_SERIE)
   
   //RMD - 24/02/15 - Projeto Chave NF
   SerieNfId("EEM",1,"EEM_SERIE",,,,EEM->EEM_SERIE)
   
   EEM->EEM_DTNF   := IF(n1=0,IN100CTD(INT_NS->NNSDT),EEM->EEM_DTNF)
   EEM->EEM_TIPONF := IF(n1=0,INT_NS->NNSTNF         ,EEM->EEM_TIPONF)
   EEM->EEM_VLNF   := IF(n1=0,VAL(INT_NS->NNSVNF)    ,EEM->EEM_VLNF)
   EEM->EEM_VLFRET := IF(n1=0,VAL(INT_NS->NNSVFR)    ,EEM->EEM_VLFRET)
   EEM->EEM_VLSEGU := IF(n1=0,VAL(INT_NS->NNSVSE)    ,EEM->EEM_VLSEGU)
   EEM->EEM_OUTROS := IF(n1=0,VAL(INT_NS->NNSTOU)    ,EEM->EEM_OUTROS)
   EEM->EEM_VLMERC := EEM->EEM_VLMERC+VAL(INT_NS->NNSVME)
   *
   EE9->EE9_NF    := INT_NS->NNSNF
   EE9->EE9_SERIE := INT_NS->NNSSER
   
   //RMD - 24/02/15 - Projeto Chave NF
   SerieNfId("EE9",1,"EE9_SERIE",,,,EE9->EE9_SERIE)
   
ENDIF
If EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"GRVNS")
ENDIF
EEM->(MSUNLOCK())
EE9->(MSUNLOCK())
ENDIF
Return(.T.)
*-------------------------------------------------------------------
FUNCTION IN100TIPNS()
RETURN(IF(INT_NS->NNSTNF="1",STR0251,;
          IF(INT_NS->NNSTNF="2",STR0252,;
             IF(INT_NS->NNSTNF="3",STR0253,""))))
*--------------------------------------------------------------------
FUNCTION IN100TIPNC()
RETURN(IF(INT_NC->NNCTNF="1",STR0251,;
          IF(INT_NC->NNCTNF="2",STR0252,;
             IF(INT_NC->NNCTNF="3",STR0253,""))))
*--------------------------------------------------------------------
STATIC FUNCTION POSEEM()
LOCAL lRET := .F.
EEM->(DBSETORDER(1))
EEM->(DBSEEK(cFilEEM+AVKEY(INT_NS->NNSPRO,"EEM_PREEMB")+EEM_NF+AVKEY(INT_NS->NNSNF,"EEM_NRNF")+INT_NS->NNSTNF))
DO WHILE ! EEM->(EOF()) .AND.;
   EEM->(EEM_FILIAL+EEM_PREEMB+EEM_TIPOCA+EEM_NRNF+EEM_TIPONF) = (cFilEEM+AVKEY(INT_NS->NNSPRO,"EEM_PREEMB")+EEM_NF+AVKEY(INT_NS->NNSNF,"EEM_NRNF")+INT_NS->NNSTNF)
   *
   IF EEM->EEM_SERIE = INT_NS->NNSSER
      lRET := .T.
      EXIT
   ENDIF
   EEM->(DBSKIP())
ENDDO
RETURN(lRET)
*--------------------------------------------------------------------
FUNCTION IN100NC()
LOCAL cPI1 := AVSX3("EEM_VLNF"  ,AV_PICTURE),;
      cPI2 := AVSX3("EEM_VLMERC",AV_PICTURE),;
      cPI3 := AVSX3("EEM_VLFRET",AV_PICTURE),;
      cPI4 := AVSX3("EEM_VLSEGU",AV_PICTURE),;
      cPI5 := AVSX3("EEM_OUTROS",AV_PICTURE),;                                                                                          
      cPI6 := IF(EEM->(FieldPos("EEM_TXTB")) > 0,AVSX3("EEM_TXTB"  ,AV_PICTURE),AVSX3("EEM_OUTROS",AV_PICTURE))
      //Incluido por ER 04/08/2005
*
AADD(TB_Cols,{{|| IN100StaIte()              },"",STR0128}) // Tem Item Rejeitado
AADD(TB_Cols,{{|| NNCPRO                     },"",STR0129}) // Código do Processo
AADD(TB_COLS,{{|| NNCNF                      },"",STR0233}) // NOTA FISCAL
AADD(TB_COLS,{{|| NNCSER                     },"",STR0234}) // SERIE DA NOTA FISCAL
AADD(TB_COLS,{{|| IN100CTD(NNCDT)            },"",STR0235}) // DATA DA NOTA FISCAL
AADD(TB_COLS,{{|| IN100TIPNC()               },"",STR0236}) // TIPO DE NOTA FISCAL
AADD(TB_COLS,{{|| TRANSFORM(VAL(NNCVNF),cPI1)},"",STR0237}) // VALOR DA NOTA FISCAL
AADD(TB_COLS,{{|| TRANSFORM(VAL(NNCVME),cPI2)},"",STR0238}) // VALOR DA MERCADORIA
AADD(TB_COLS,{{|| TRANSFORM(VAL(NNCVFR),cPI3)},"",STR0239}) // VALOR DO FRETE
AADD(TB_COLS,{{|| TRANSFORM(VAL(NNCVSE),cPI4)},"",STR0240}) // VALOR DO SEGURO
AADD(TB_COLS,{{|| TRANSFORM(VAL(NNCTOU),cPI5)},"",STR0241}) // VALOR OUTRAS DESPESAS
AADD(TB_COLS,{{|| TRANSFORM(VAL(NNCTX) ,cPI6)},"",STR0255}) // TAXA
IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLNC")
ENDIF
AADD(TB_Cols,{{||IN100E_Msg(.T.)},"",STR0046}) // Mensagem
*
TB_Col_D := {}
AADD(TB_Col_D,{{|| IN100Status()              },"",STR0030}) // Status
AADD(TB_Col_D,{{|| IN100TIPO()                },"",STR0044}) // Tipo
AADD(TB_Col_D,{{|| NNDPRO                     },"",STR0129}) // Código do Processo
AADD(TB_COL_D,{{|| NNDNF                      },"",STR0233}) // NOTA FISCAL
AADD(TB_COL_D,{{|| NNDSER                     },"",STR0234}) // SERIE DA NOTA FISCAL
AADD(TB_COL_D,{{|| TRANSFORM(VAL(NNDVNF),cPI1)},"",STR0237}) // VALOR DA NOTA FISCAL
AADD(TB_COL_D,{{|| TRANSFORM(VAL(NNDVME),cPI2)},"",STR0238}) // VALOR DA MERCADORIA
AADD(TB_COL_D,{{|| TRANSFORM(VAL(NNDVFR),cPI3)},"",STR0239}) // VALOR DO FRETE
AADD(TB_COL_D,{{|| TRANSFORM(VAL(NNDVSE),cPI4)},"",STR0240}) // VALOR DO SEGURO
AADD(TB_COL_D,{{|| TRANSFORM(VAL(NNDTOU),cPI5)},"",STR0241}) // VALOR OUTRAS DESPESAS
AADD(TB_COL_D,{{|| NNDPED                     },"",STR0243}) // PEDIDO
AADD(TB_COL_D,{{|| NNDITE                     },"",STR0244}) // ITEM
AADD(TB_COL_D,{{|| NNDPOS                     },"",STR0245}) // SEQUENCIA
AADD(TB_COL_D,{{|| NNDQTD                     },"",STR0256}) // QUANTIDADE
IF EasyEntryPoint("IN100CLI")  
   ExecBlock("IN100CLI",.F.,.F.,"COLND")
ENDIF
AADD(TB_Col_D,{{|| IN100E_Msg(.T.)} ,"" ,STR0046}) // Mensagem
Return .T.
*--------------------------------------------------------------------

/*
Função     : IN100LERNC
Objetivo   : Validar NF (Capa).
Retorno    : .T.
Autor      : Alexsander Martins dos Santos
Data e Hora: 31/08/2004 às 10:28.
*/

Function IN100LERNC()
Local nInc, nInc2
LOCAL lEES,lITERRO, nVlNf:=0
Local nSomaItReais, nSomaItMoeda, nQuantEES, nQuantEE9
Local cCnpj:=Space(14), cExport:= Space(AvSx3("EEC_EXPORT",AV_TAMANHO)), cExLoja := Space(AvSx3("EEC_EXLOJA",AV_TAMANHO))
Local lItemComCnpj := .F., lTipoNfCompl := .F.
Local nSomaFrReais, nSomaFrMoeda, nSomaSeReais, nSomaSeMoeda, nSomaOuDReais, nSomaOuDMoeda
Local nI, lIntegraSeq, nTipValCapa := 0
Local	cOldFuncao:=cFuncao
Local lBUpDate:= .F.

If Type("bUpDate") == "B"
   lBUpDate:= .T.
EndIf

Int_NC->NNCMSG := ""
Int_NC->NNCITEM_OK := "T" // ** By JBJ 03/04/03 - Tratamento para coluna "Tem Itens Rejeitados".

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERNC")
ENDIF

If EEM->(FieldPos("EEM_CNPJ")) > 0  // By JPP - 20/03/2006 - 09:20  
   lTipoNfCompl := INT_NC->NNCTNF == EEM_CP // EEM_CP = "2" = Nota Fiscal Complementar
   EEC->(DBSETORDER(1))
   If (EEC->(DbSeek(cFILEEC+AVKEY(INT_NC->NNCPRO ,"EEC_PREEMB"))))
      // cExport := EEC->EEC_EXPORT 
      // cExLoja := EEC->EEC_EXLOJA  
      cExport := EEC->EEC_FORN
      cExLoja := EEC->EEC_FOLOJA
   ENDIF

   If Empty(INT_NC->NNCCNPJ)
      SA2->(DbSetOrder(1))                                  
      If SA2->(DbSeek(cFilSA2+AvKey(cExport,"A2_COD")+AvKey(cExloja,"A2_LOJA")))
         cCnpj := SA2->A2_CGC
      EndIf
   Else
      cCnpj :=INT_NC->NNCCNPJ 
   EndIf
EndIf                          

IF EMPTY(Int_NC->NNCPRO)
   EVAL(bmsg,STR0129+STR0230) // Codigo Processo não informado
ELSE
   EEC->(DBSETORDER(1))
   IF ! (EEC->(DBSEEK(cFILEEC+AVKEY(INT_NC->NNCPRO ,"EEC_PREEMB"))))
      EVAL(bMSG,STR0246+STR0242)  // PROCESSO NAO CADASTRADO
   ENDIF
   
   //ER - 22/03/06 às 11:00 - Alteração nos critérios usados para o parametro MV_NFDTC
   If !Empty(EEC->EEC_DTEMBA)
      If !EEC->(EOF())
         If DtoS(IN100CTD(INT_NC->NNCDT)) > DtoS(EEC->EEC_DTEMBA)
            If !EasyGParam("MV_NFDTC",,.F.)
               EVAL(bMSG,STR0332) //"Embarque Finalizado"      
            EndIf
         EndIf
      EndIf
     
      /*
      //** GFC - 19/07/05 - Novo parametro que indica se será permitido integrar nota após o embarque - Nopado por ER - 22/03/06
      IF EasyGParam("MV_NFDTC",,.T.) .AND. !EEC->(EOF())
         IF !EMPTY(INT_NC->NNCDT) 
            IF DTOS(EEC->EEC_DTEMBA) < dtos(IN100CTD(INT_NC->NNCDT)) 
               EVAL(bMSG,STR0340,.T.)  // DATA DA NF MAIOR QUE A DATA DO EMBARQUE
            ENDIF
         ENDIF
      Else
         EVAL(bMSG,STR0332) //"Embarque Finalizado"
      EndIf
      //**
      */
   EndIf
   If EEM->(FieldPos("EEM_CNPJ")) > 0  // By JPP - 17/03/2006 - 16:00 
      EEM->(DbSetOrder(3))
      EEM->(DbSeek(cFILEEM+AvKey(cCnpj,"EEM_CNPJ")+AvKey(INT_NC->NNCNF,"EEM_NRNF")+AvKey(INT_NC->NNCSER,"EEM_SERIE")))  
   Else   
      EEM->(DBSETORDER(1))
      EEM->(DBSEEK(cFILEEM+AVKEY(INT_NC->NNCPRO,"EEM_PREEMB")+"N"+AVKEY(INT_NC->NNCNF,"EEM_NRNF")+AVKEY(INT_NC->NNCTNF,"EEM_TIPONF")))
   EndIf  
   lIntegraSeq := .T.
   If !Empty(INT_NC->NNCREC)
      For nI := 1 To Len(aSeqCapa) // By JPP - 29/11/2006 - 12:00 - Rotina utilizada para tratar situações que existam integrações simultaneas, Ex: integração do tipo inclusão e em seguida exclusão.            
          If aSeqCapa[nI][1] == Int_Nc->(NNCPRO+NNCSER+NNCNF) .And. ;
             aSeqCapa[nI][2] < INT_NC->NNCREC .And. ;  
             aSeqCapa[nI][3] == EXCLUSAO .And. ;
             INT_NC->NNCTIPO == INCLUSAO 
             *
             lIntegraSeq := .F.
          ElseIf aSeqCapa[nI][1] == Int_Nc->(NNCPRO+NNCSER+NNCNF) .And. ;
                 aSeqCapa[nI][2] < INT_NC->NNCREC .And. ;  
                 aSeqCapa[nI][3] == INCLUSAO .And. ;
                 INT_NC->NNCTIPO == EXCLUSAO 
                 *
                 lIntegraSeq := .F.    
          ElseIf aSeqCapa[nI][1] == Int_Nc->(NNCPRO+NNCSER+NNCNF) .And. ;
                 aSeqCapa[nI][2] < INT_NC->NNCREC .And. ;  
                 aSeqCapa[nI][3] == INCLUSAO .And. ;
                 INT_NC->NNCTIPO == "C" // Cancelamento 
                 *
                 lIntegraSeq := .F.                    
          EndIf
      Next
   EndIf   
    
   IF INT_NC->NNCTIPO = INCLUSAO .AND. EEM->(FOUND())    
      If lIntegraSeq
         EVAL(bMSG,STR0233+STR0229)  // NOTA FISCAL JA CADASTRADA
      EndIf
   ELSEIF (INT_NC->NNCTIPO = ALTERACAO .OR. INT_NC->NNCTIPO = EXCLUSAO .Or. INT_NC->NNCTIPO = "C") .AND.;
          ! EEM->(FOUND())
          *
          If lIntegraSeq
             EVAL(bMSG,STR0233+STR0242)  // NOTA FISCAL NAO CADASTRADA
          EndIf
   ENDIF
ENDIF
IF EMPTY(INT_NC->NNCNF)
   EVAL(bMSG,STR0233+STR0230) // Nota Fiscal nao Informada
ENDIF
IF EMPTY(INT_NC->NNCSER)
   EVAL(bMSG,STR0234+STR0230) // SERIE NAO INFORMADA
ENDIF
IF EMPTY(INT_NC->NNCDT)
   EVAL(bMSG,STR0235+STR0230)  // DATA DA NF NAO INFORMADA
ENDIF
IF EMPTY(INT_NC->NNCTNF)
   EVAL(bMSG,STR0236+STR0230)  // TIPO NAO INFORMADO
ELSEIF AT(INT_NC->NNCTNF,"123") = 0
       EVAL(bMSG,STR0236+STR0227) // TIPO INVALIDO
ENDIF
IF EMPTY(INT_NC->NNCVNF)
   EVAL(bMSG,STR0237+STR0230)  // VALOR DA NF NAO INFORMADO
ELSEIF VAL(INT_NC->NNCVNF) <= 0
       EVAL(bMSG,STR0237+STR0227)  // VALOR DA NF INVALIDO
ENDIF
IF EMPTY(INT_NC->NNCTX) .AND. lNFITENS
   EVAL(bMSG,STR0255+STR0230)  // TAXA NAO INFORMADA
ENDIF
//FDR - 19/02/2013
IF !EMPTY(INT_NC->NNCCF) .AND. !SX5->(DBSEEK(cFilSX5+'13'+AvKey(INT_NC->NNCCF,"X5_CHAVE")))
   EVAL(bmsg,STR0361) //"Código Fiscal sem cadastro"
Endif

INT_ND->(DBSETORDER(1))
IF ! INT_ND->(DBSEEK(INT_NC->(NNCPRO+NNCSER+NNCNF+NNCREC)))  // By JPP - 28/11/2006 - 16:50 - Inclusão do campo NNCREC na chave. 
   EVAL(bMSG,STR0161) // Processo não possui itens
ENDIF

nVlNf := (Val(Int_Nc->NNCVFR)+Val(Int_Nc->NNCVSE)+Val(Int_Nc->NNCTOU)+Val(Int_Nc->NNCVME))
If EasyGParam( "MV_AVG0102",, .T. ) //RMD - 29/08/05
   If nVlNf <> Val(Int_Nc->NNCVNF)
      Eval(bMsg,STR0300) //"Total da nota não confere com a soma das Despesas+Vl.Merc."
   EndIf
EndIf

//** JPM 18/11/04 - Verifica se o total da NF na capa corresponde à soma dos itens.
nSomaItReais:=0
nSomaItMoeda:=0
// By JPP - 20/03/2006 - 15:50
nSomaFrReais  := 0
nSomaFrMoeda  := 0 
nSomaSeReais  := 0
nSomaSeMoeda  := 0
nSomaOuDReais := 0
nSomaOuDMoeda := 0  

Int_Nd->(DbSetOrder(1))
Int_Nd->(DbSeek(INT_NC->(NNCPRO+NNCSER+NNCNF+NNCREC))) // By JPP - 28/11/2006 - 16:50 - Inclusão do campo NNCREC na chave. 

While Int_Nc->(NNCPRO+NNCSER+NNCNF+NNCREC) == Int_Nd->(NNDPRO+NNDSER+NNDNF+NNDREC) .and. Int_Nd->(!EoF()) // By JPP - 28/11/2006 - 16:50 - Inclusão dos campos NNCREC/NNDREC na chave. 
   nSomaItReais += Val(Int_Nd->NNDVNF)
   nSomaItMoeda += Val(Int_Nd->NNDVNFM) 
   If EEM->(FieldPos("EEM_CNPJ")) > 0 // By JPP - 20/03/2006 - 10:00 
      If !Empty(Int_Nd->NNDCNPJ) 
         lItemComCnpj:= .T.
      EndIf
      nSomaFrReais  += Val(INT_ND->NNDVFR)
      nSomaFrMoeda  += Val(INT_ND->NNDVFRM) 
      nSomaSeReais  += Val(INT_ND->NNDVSE)
      nSomaSeMoeda  += Val(INT_ND->NNDVSEM)
      nSomaOuDReais += Val(INT_ND->NNDTOU)
      nSomaOuDMoeda += Val(INT_ND->NNDTOUM)  
   EndIf   
   aAdd(aSeqItem,{Int_ND->(NNDPRO+NNDSER+NNDNF),INT_ND->NNDREC,INT_NC->NNCTIPO,val(Int_Nd->NNDQTD),Int_Nd->NNDPED,Int_Nd->NNDPOS}) // By JPP - 29/11/2006 - 12:00 - Array utilizado para tratar situações que existam integrações simultaneas, Ex: integração do tipo inclusão e em seguida exclusão.            

   Int_Nd->(DbSkip())
EndDo 

If EEM->(FieldPos("EEM_CNPJ")) > 0  // By JPP - 20/03/2006 - 09:20
   If ! Empty(Int_Nc->NNCCNPJ)
      SA2->(DbSetOrder(3))
      If !SA2->(DbSeek(cFilSA2+Int_Nc->NNCCNPJ))
         Eval(bMsg,STR0345) // "CNPJ não cadastrado no cadastro de Fornecedores/Exportadores"
      EndIf   
   Else
      If lItemComCnpj // Existe pelo menos um item com CNPJ.
         Eval(bMsg,STR0346) //"Item com CNPJ. O CNPJ da capa da Nota Fiscal deve ser informado."
      EndIf
      If Empty(cCnpj) 
         Eval(bMsg,STR0347) // "O CNPJ exportador não está preenchido no cadastro de Fornecedores/Exportadores."
      EndIf
   EndIf
   If lTipoNfCompl // By JPP - 20/03/2006 - 16:00            
      If val(Int_Nc->NNCVFR) <> nSomaFrReais  
         Eval(bMsg,STR0348) // "Divergência entre capa e itens - Frete R$."
      EndIf
      If val(Int_Nc->NNCVFRM) <> nSomaFrMoeda  
         Eval(bMsg,STR0349) // "Divergência entre capa e itens - Frete na Moeda."
      EndIf
      If val(Int_Nc->NNCVSE) <> nSomaSeReais 
         Eval(bMsg,STR0350) // "Divergência entre capa e itens - Seguro R$."
      EndIf
      If val(Int_Nc->NNCVSEM) <> nSomaSeMoeda  
         Eval(bMsg,STR0351) // "Divergência entre capa e itens - Seguro na Moeda." 
      EndIf
      If val(Int_Nc->NNCTOU) <> nSomaOuDReais 
         Eval(bMsg,STR0352) // "Divergência entre capa e itens - Total outras Desp. R$."
      EndIf
      If val(Int_Nc->NNCTOUM) <> nSomaOuDMoeda  
         Eval(bMsg,STR0353) // "Divergência entre capa e itens - Total outras Desp. na Moeda."
      EndIf
   EndIf
EndIf

If val(Int_Nc->NNCVNF) <> nSomaItReais 
   Eval(bMsg,STR0327)//"Divergência entre capa e itens - Valor R$." 
EndIf

If val(Int_Nc->NNCVNFM) <> nSomaItMoeda
   Eval(bMsg,STR0328)//"Divergência entre capa e itens - Valor na Moeda." 
EndIf      
//** JPM - Fim

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALNC")
ENDIF
IN100VerErro(cErro,cAviso)
cErro   := NIL
cAVISO  := NIL
lITERRO := .F.   

//** JPM - Parâmetro que define a margem de divergencia aceitável entre a quantidade no embarque e na nota(em %)     
nMargem := EasyGParam("MV_AVG0075", .F., .F.)
if ValType(nMargem) == "L"
   nMargem := 1
Else
   if nMargem >= 0
      nMargem := (nMargem / 100) + 1
   Else
      /*
      AMS - 30/11/2004 às 10:33. Substituido a MsgStop por Eval(bMsg, Mensagem).
      MsgStop(STR0329,STR0330)//"O conteúdo do parâmetro MV_AVG0075 está incorreto. O sistema adotará o conteúdo padrão (zero)."."Aviso"
      */
      Eval(bMSG, STR0329)
      nMargem := 1
   Endif
Endif                 
//** JPM - Fim

IF INT_NC->NNCTIPO # EXCLUSAO .And. INT_NC->NNCTIPO # "C"
   // VALIDA OS ITENS DAS NOTAS FISCAIS   
   Int_Nd->(DbSetOrder(1))
   Int_Nd->(DbSeek(INT_NC->(NNCPRO+NNCSER+NNCNF+NNCREC)))  // By JPP - 28/11/2006 - 16:50 - Inclusão do campo NNCREC na chave. 
   DO WHILE ! INT_ND->(EOF()) .AND.;
      INT_ND->(NNDPRO+NNDSER+NNDNF+NNDREC) =  INT_NC->(NNCPRO+NNCSER+NNCNF+NNCREC)  // By JPP - 28/11/2006 - 16:50 - Inclusão dos campos NNCREC/NNDREC na chave. 
      *
      IF EasyEntryPoint("IN100CLI")
         EXECBLOCK("IN100CLI",.F.,.F.,"LERND")
      ENDIF
      EE9->(DBSETORDER(1))
      //IF ! (EE9->(DBSEEK(cFILEE9+AVKEY(INT_ND->NNDPED,"EE9_PEDIDO")+AVKEY(INT_ND->NNDPOS,"EE9_SEQUEN"))))
      IF ! (EE9->(DBSEEK(cFILEE9+AVKEY(INT_ND->NNDPED,"EE9_PEDIDO")+STR(VAL(INT_ND->NNDPOS),AVSX3("EE9_SEQUEN",AV_TAMANHO)) )))//FSY - 29/05/2013 - adicionado validação para remover  Zero a esquerda do INT_ND->NNDPOS
         EVAL(bMSG,STR0249) // Pedido+Sequencia+Processo nao existe
      ELSEIF EE9->EE9_COD_I # AVKEY(INT_ND->NNDITE,"EE9_COD_I")
             EVAL(bMSG,STR0250) // Item enviado nao confere com item do processo
      ENDIF
      lEES := .F.
      EES->(DBSETORDER(1))
      EES->(DBSEEK(cFILEES+AVKEY(INT_ND->NNDPRO,"EES_PREEMB")+AVKEY(INT_ND->NNDNF,"EES_NRNF")))
      DO WHILE ! EES->(EOF()) .AND.;
         EES->(EES_FILIAL+EES_PREEMB+EES_NRNF) = (cFILEES+AVKEY(INT_ND->NNDPRO,"EES_PREEMB")+AVKEY(INT_ND->NNDNF,"EES_NRNF"))
         *
         IF AVKEY(EES->EES_COD_I,"EE9_COD_I") = AVKEY(INT_ND->NNDITE,"EE9_COD_I") .and. AVKEY(EES->EES_PEDIDO,"EE9_PEDIDO") = AVKEY(INT_ND->NNDPED,"EE9_PEDIDO")
            lEES := .T.
            EXIT
         ENDIF
         EES->(DBSKIP())
      ENDDO
      
      lIntegraSeq := .T.
      If !Empty(INT_ND->NNDREC)
         For nI := 1 To Len(aSeqCapa) // By JPP - 29/11/2006 - 12:00 - Rotina utilizada para tratar situações que existam integrações simultaneas, Ex: integração do tipo inclusão e em seguida exclusão.            
             If aSeqCapa[nI][1] == Int_Nd->(NNDPRO+NNDSER+NNDNF) .And. ;
                aSeqCapa[nI][2] < INT_ND->NNDREC .And. ;  
                aSeqCapa[nI][3] == EXCLUSAO .And. ;
                INT_ND->NNDTIPO == INCLUSAO 
                *
                lIntegraSeq := .F.
             EndIf
         Next
      EndIf   
      
      IF INT_ND->NNDTIPO = INCLUSAO .AND. lEES .And. !lTipoNfCompl // By JPP - 16/03/2006 - 17:00 
         If lIntegraSeq 
            EVAL(bMSG,STR0244+STR0229)  // ITEM JA CADASTRADO
         EndIf
      ELSEIF (INT_ND->NNDTIPO = ALTERACAO .OR. INT_ND->NNDTIPO = EXCLUSAO) .AND.;
             ! lEES
             *
             EVAL(bMSG,STR0244+STR0242) // Item nao cadastrado(a)
      ENDIF
      IF EMPTY(INT_ND->NNDSER)
         EVAL(bMSG,STR0234+STR0230) // SERIE NAO INFORMADA
      ENDIF
      IF EMPTY(INT_ND->NNDVNF)                         
      
         EVAL(bMSG,STR0237+STR0230)  // VALOR DA NF NAO INFORMADO
      ELSEIF VAL(INT_ND->NNDVNF) <= 0
             EVAL(bMSG,STR0237+STR0227)  // VALOR DA NF INVALIDO
      ENDIF
      IF EMPTY(INT_ND->NNDPED)
         EVAL(bMSG,STR0243+STR0230)  // ITEM DO PEDIDO NAO INFORMADO
      ENDIF
      IF EMPTY(INT_ND->NNDITE)  
         EVAL(bMSG,STR0225+STR0230) // ITEM INVALIDO
      ENDIF
      IF EMPTY(INT_ND->NNDQTD) .And. !lTipoNfCompl // By JPP - 16/03/2006 - 17:00 
         EVAL(bMSG,STR0256+STR0230) // QUANTIDADE NAO INFORMADA
      ELSEIF VAL(INT_ND->NNDQTD) <= 0 .And. !lTipoNfCompl // By JPP - 16/03/2006 - 17:00 
             EVAL(bMSG,STR0256+STR0227) // QUANTIDADE INVALIDA
      ENDIF

      nVlNf := (Val(Int_ND->NNDVFR)+Val(Int_ND->NNDVSE)+Val(Int_ND->NNDTOU)+Val(Int_ND->NNDVME))
      If EasyGParam( "MV_AVG0102",, .T. ) //RMD - 29/08/05
         If nVlNf <> Val(Int_ND->NNDVNF)
            Eval(bMsg,STR0300) //"Total da nota não confere com a soma das Despesas+Vl.Merc."
         EndIf
      EndIf                                                                    

      //** JPM - 18/11/04 
      //Valida a quantidade, considerando a margem de divergencia encontrada no parametro MV_AVG0075
      EE9->(DBSetOrder(2)) //Proc. Embarque + Pedido + Sequência do Item(pedido)
      EES->(DBSetOrder(1))
      nQuantEES := nQuantEE9 := 0
      If EES->(DbSeek(cFilEES+AvKey(Int_Nd->NNDPRO,"EES_PREEMB")))
         While EES->(!EoF()) .AND. EES->(EES_FILIAL+EES_PREEMB) = (cFilEES+AvKey(Int_Nd->NNDPRO,"EES_PREEMB"))
            /*
            AMS - 20/12/2004 às 20:34. Correção da condição para selecioner as NF correspondente a seq.emb.
            IF AvKey(EES->EES_COD_I,"EE9_COD_I") = AvKey(Int_Nd->NNDITE,"EE9_COD_I")
            */
            If EEM->(FieldPos("EEM_CNPJ")) > 0  // By JPP - 20/03/2006 - 11:00 // Despreza as notas fiscais complementares
               EEM->(DBSETORDER(3)) // Filial+CNPJ+Nota fiscal+Série
               EEM->(DBSEEK(cFILEEM+Avkey(EES->EES_CNPJ,"EES_CNPJ")+AvKey(EES->EES_NRNF,"EES_NRNF")+AVKEY(EES->EES_SERIE,"EES_SERIE")))
               If lTipoNfCompl // EEM->(EEM_TIPONF) == "2"
                  EES->(DbSkip())
                  Loop
               EndIf
            EndIf
            If EES->(AVKey(EES_PEDIDO, "EE9_PEDIDO") == AVKey(Int_Nd->NNDPED, "EE9_PEDIDO") .and. AVKey(EES_SEQUEN, "EE9_SEQUEN") == STR(VAL(INT_ND->NNDPOS),AVSX3("EE9_SEQUEN",AV_TAMANHO)) )//FSY - 29/05/2013 - adicionado validação para remover  Zero a esquerda do INT_ND->NNDPOS
               nQuantEES += EES->EES_QTDE
            Endif
            EES->(DbSkip())
         EndDo
      Endif
      IF (EE9->(DBSeek(cFilEE9+AvKey(Int_Nd->NNDPRO,"EE9_PREEMB")+AvKey(Int_Nd->NNDPED,"EE9_PEDIDO");
                              +STR(VAL(INT_ND->NNDPOS),AVSX3("EE9_SEQUEN",AV_TAMANHO)) )))//FSY - 29/05/2013 - adicionado validação para remover  Zero a esquerda do INT_ND->NNDPOS
         nQuantEE9 := EE9->EE9_SLDINI
      Endif
      If !Empty(INT_ND->NNDREC)
         For nI := 1 To Len(aSeqItem) // By JPP - 29/11/2006 - 12:00 - Rotina utilizada para tratar situações que existam integrações simultaneas, Ex: integração do tipo inclusão e em seguida exclusão.            
             If aSeqItem[nI][2] >= INT_ND->NNDREC
                Exit
             EndIf
             If Ascan(aSeqCapa,{|X| X[1] == aSeqItem[nI][1] .And. X[2] == aSeqItem[nI][2] .And. X[3]== EXCLUSAO}) > 0
                If (aSeqItem[nI][1] = Int_ND->(NNDPRO+NNDSER+NNDNF) .And. aSeqItem[nI][5] == Int_Nd->NNDPED .And. aSeqItem[nI][6] == Int_Nd->NNDPOS)
                   nQuantEES -= aSeqItem[nI][4]
                EndIf
             ElseIf Ascan(aSeqCapa,{|X| X[1] == aSeqItem[nI][1] .And. X[2] == aSeqItem[nI][2] .And. X[3]== INCLUSAO}) > 0
                 If (aSeqItem[nI][1] = Int_ND->(NNDPRO+NNDSER+NNDNF) .And. aSeqItem[nI][5] == Int_Nd->NNDPED .And. aSeqItem[nI][6] == Int_Nd->NNDPOS)
                    nQuantEES += aSeqItem[nI][4]
                 EndIf
             EndIf
         Next
      EndIf
      If val(Int_Nd->NNDQTD) > ((nQuantEE9 * nMargem) - nQuantEES) 
         Eval(bMsg,STR0331)//"Qtde. do item é maior que a qtde. não faturada do embarque."
      Endif
      //** JPM - Fim
      
      If EEM->(FieldPos("EEM_CNPJ")) > 0  // By JPP - 20/03/2006 - 09:20
         If (Val(INT_ND->NNDQTD) = 0 .Or. Empty(INT_ND->NNDQTD)) .And.;
            (!Empty(Int_ND->NNDVME) .And. Val(Int_ND->NNDVME) > 0) .And. lTipoNfCompl // By JPP - 16/03/2006 - 17:00 
            Eval(bMsg,STR0354) // "A quantidade do item deve ser informada."
         EndIf
      
         If (!Empty(INT_ND->NNDQTD) .And. Val(INT_ND->NNDQTD) > 0) .And. ;
            (Empty(Int_ND->NNDVME) .Or. Val(Int_ND->NNDVME) == 0) .And. lTipoNfCompl // By JPP - 16/03/2006 - 17:00 
            Eval(bMsg,STR0355) // "O valor da mercadoria deve ser informado."
         EndIf
      
         If Empty(INT_ND->NNDCNPJ) .And. !Empty(INT_NC->NNCCNPJ)
            Eval(bMsg,STR0356) // "O CNPJ do emissor da nota fiscal deve ser informado."
         EndIf
          
         If Empty(INT_NC->NNCCNPJ) .And. Empty(INT_ND->NNDCNPJ) 
            INT_ND->NNDCNPJ := cCnpj // Se o Cnpj não for informado, grava o cnpj do exportador.
         EndIf
         
         If INT_ND->NNDCNPJ <> INT_NC->NNCCNPJ .And. !Empty(INT_NC->NNCCNPJ)
            Eval(bMsg,STR0357) // "O CNPJ da capa da nota fiscal difere do CNPJ do item da nota fiscal."
         EndIf 
         
      EndIf
      
      IF EasyEntryPoint("IN100CLI")
         EXECBLOCK("IN100CLI",.F.,.F.,"VALND")
      ENDIF
      IF cERRO # NIL .OR. cAVISO # NIL
         INT_ND->NNDINT_OK := "F"
         INT_ND->NNDMSG    := IF(cERRO#NIL,cERRO,cAVISO)
         cERRO             := NIL
         cAVISO            := NIL
         lITERRO           := .T.
      ELSE
         INT_ND->NNDINT_OK := "T"
      ENDIF            
      
      if lBUpDate	//--- ADC 09/02/2011 Para tratamento da integração EICIN100 x AvInteg
         cOldFuncao := cFuncao
         cFuncao    := "ND"
         Eval(bUpDate, INT_ND->NNDMSG,INT_ND->NNDINT_OK)
         cFuncao    := cOldFuncao
         If INT_ND->NNDINT_OK == "F"
            lITERRO           := .T.
         EndIf
      endif

      INT_ND->(DBSKIP())
   ENDDO
Else
	//---------------------------------------------------------------------------------------------------------------
	// ADC 11/02/2011 -	Foi incluída esta opção ELSE para fazer com que o programa realize o restante das validações
	//							necessárias com relação aos itens da nota fiscal de saída. Isto porque, quando a opção esco-
	//							lhida de  integração fosse a EXCLUSÃO ou CANCELAMENTO, os campos de FLAG de validação do re-
	//							gistro ACEITO ou REJEITADO para o arquivo de trabalho INT_ND não eram atualizados, deixando-
	//							-os com o conteúdo BRANCO.  Uma vez que, agora as integrações podem ser executadas com tabe-
	//							las de muro, a atualização do FLAG de PROCESSADO  se faz necessário também para os registros
	//							dos ITENS DA NFS enviados.
	//---------------------------------------------------------------------------------------------------------------
	// É EXCLUSÃO ou CANCELAMENTO, realiza demais validações dos registros dos ITENS DA NFS...
   Int_Nd->(DbSetOrder(1))
   Int_Nd->(DbSeek(INT_NC->(NNCPRO+NNCSER+NNCNF+NNCREC)))
   Do While INT_ND->(!Eof()) .AND. INT_ND->(NNDPRO+NNDSER+NNDNF+NNDREC) ==  INT_NC->(NNCPRO+NNCSER+NNCNF+NNCREC)
      //---	ADC 11/02/2011	O ponto abaixo foi criado neste lugar apenas para manter a compatibilidade com a rotina acima
      //							destinada aos movimentos de INCLUSÃO ou ALTERAÇÃO da NFS. Porém, o parâmetro "LERND_EXCLUSAO_CANCELAMENTO"
      //							utilizado neste lugar não influenciará demais customizações já existentes.
      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"LERND_EXCLUSAO_CANCELAMENTO")
      ENDIF
      //
      EE9->(dBSetOrder(1))
      If EE9->(!dBSeek(cFILEE9+AVKEY(INT_ND->NNDPED,"EE9_PEDIDO")+STR(VAL(INT_ND->NNDPOS),AVSX3("EE9_SEQUEN",AV_TAMANHO)) ))//FSY - 29/05/2013 - adicionado validação para remover  Zero a esquerda do INT_ND->NNDPOS
         EVAL(bMSG,STR0249) // Pedido+Sequencia+Processo nao existe
      ElseIf EE9->EE9_COD_I # AVKEY(INT_ND->NNDITE,"EE9_COD_I")
         EVAL(bMSG,STR0250) // Item enviado nao confere com item do processo
      EndIf
      lEES := .F.
      EES->(dBSetOrder(1))
      EES->(dBSeek(cFILEES+AVKEY(INT_ND->NNDPRO,"EES_PREEMB")+AVKEY(INT_ND->NNDNF,"EES_NRNF")))
      Do While EES->(!Eof()) .AND. EES->(EES_FILIAL+EES_PREEMB+EES_NRNF) == (cFILEES+AVKEY(INT_ND->NNDPRO,"EES_PREEMB")+AVKEY(INT_ND->NNDNF,"EES_NRNF"))
         If AVKEY(EES->EES_COD_I,"EE9_COD_I") == AVKEY(INT_ND->NNDITE,"EE9_COD_I") .AND.;
            AVKEY(EES->EES_PEDIDO,"EE9_PEDIDO") == AVKEY(INT_ND->NNDPED,"EE9_PEDIDO")
            lEES := .T.
            EXIT
         EndIf
         EES->(dBSkip())
      EndDo
      //
      If INT_ND->NNDTIPO <> INT_NC->NNCTIPO
         EVAL(bMSG,STR0360)  // Divergência entre capa e itens - Tipo de integração
      ElseIf !lEES
         EVAL(bMSG,STR0244+STR0242) // Item nao cadastrado(a)
      EndIf
      If Empty(INT_ND->NNDSER)
         EVAL(bMSG,STR0234+STR0230) // SERIE NAO INFORMADA
      EndIf
      If Empty(INT_ND->NNDVNF)                         
         EVAL(bMSG,STR0237+STR0230)  // VALOR DA NF NAO INFORMADO
      ElseIf Val(INT_ND->NNDVNF) <= 0
         EVAL(bMSG,STR0237+STR0227)  // VALOR DA NF INVALIDO
      EndIf
      If Empty(INT_ND->NNDPED)
         EVAL(bMSG,STR0243+STR0230)  // ITEM DO PEDIDO NAO INFORMADO
      EndIf
      If Empty(INT_ND->NNDITE)  
         EVAL(bMSG,STR0225+STR0230) // ITEM INVALIDO
      EndIf
      If Empty(INT_ND->NNDQTD) .And. !lTipoNfCompl
         EVAL(bMSG,STR0256+STR0230) // QUANTIDADE NAO INFORMADA
      ElseIf Val(INT_ND->NNDQTD) <= 0 .And. !lTipoNfCompl
         EVAL(bMSG,STR0256+STR0227) // QUANTIDADE INVALIDA
      ENDIF
      //
      nVlNf := (Val(Int_ND->NNDVFR)+Val(Int_ND->NNDVSE)+Val(Int_ND->NNDTOU)+Val(Int_ND->NNDVME))
      If EasyGParam( "MV_AVG0102",, .T. )
         If nVlNf <> Val(Int_ND->NNDVNF)
            Eval(bMsg,STR0300) //"Total da nota não confere com a soma das Despesas+Vl.Merc."
         EndIf
      EndIf                                                                    
      //
      If EEM->(FieldPos("EEM_CNPJ")) > 0
         If (Val(INT_ND->NNDQTD) == 0 .Or. Empty(INT_ND->NNDQTD)) .And.;
            (!Empty(Int_ND->NNDVME) .And. Val(Int_ND->NNDVME)>0)  .And.;
            lTipoNfCompl
            Eval(bMsg,STR0354) // "A quantidade do item deve ser informada."
         EndIf

         If (!Empty(INT_ND->NNDQTD) .And. Val(INT_ND->NNDQTD) > 0) .And.;
            (Empty(Int_ND->NNDVME) .Or. Val(Int_ND->NNDVME) == 0)  .And.;
            lTipoNfCompl
            Eval(bMsg,STR0355) // "O valor da mercadoria deve ser informado."
         EndIf

         If Empty(INT_ND->NNDCNPJ) .And. !Empty(INT_NC->NNCCNPJ)
            Eval(bMsg,STR0356) // "O CNPJ do emissor da nota fiscal deve ser informado."
         EndIf

         If Empty(INT_NC->NNCCNPJ) .And. Empty(INT_ND->NNDCNPJ)
            INT_ND->NNDCNPJ := cCnpj // Se o Cnpj não for informado, grava o cnpj do exportador.
         EndIf

         If INT_ND->NNDCNPJ <> INT_NC->NNCCNPJ .And. !Empty(INT_NC->NNCCNPJ)
            Eval(bMsg,STR0357) // "O CNPJ da capa da nota fiscal difere do CNPJ do item da nota fiscal."
         EndIf 
      EndIf
      //---	ADC 11/02/2011	O ponto abaixo foi criado neste lugar apenas para manter a compatibilidade com a rotina acima
      //							destinada aos movimentos de INCLUSÃO ou ALTERAÇÃO da NFS. Porém, o parâmetro "VALND_EXCLUSAO_CANCELAMENTO"
      //							utilizado neste lugar não influenciará demais customizações já existentes.
      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"VALND_EXCLUSAO_CANCELAMENTO")
      EndIf
      //
      //---	ADC 11/02/2011	Atualiza campos de controle dos ITENS DA NFS para identificar registros ACEITOS ou REJEITADOS...
      If cERRO # NIL .or. cAVISO # NIL
         INT_ND->NNDINT_OK := "F"
         INT_ND->NNDMSG    := IF(cERRO#NIL,cERRO,cAVISO)
         cERRO             := NIL
         cAVISO            := NIL
         lITERRO           := .T.
      Else
         INT_ND->NNDINT_OK := "T"
      EndIf
      //
      If lBUpDate	//--- ADC 11/02/2011 Para tratamento da integração EICIN100 x AvInteg
         cOldFuncao := cFuncao
         cFuncao    := "ND"
         Eval(bUpDate, INT_ND->NNDMSG,INT_ND->NNDINT_OK)
         cFuncao    := cOldFuncao
         If INT_ND->NNDINT_OK == "F"
            lITERRO           := .T.
         EndIf
      EndIf
      //
      INT_ND->(dBSkip())
   EndDo
EndIf
If EEM->(FieldPos("EEM_CNPJ")) > 0  // By JPP - 20/03/2006 - 09:20
   If Empty(INT_NC->NNCCNPJ)   // Se o Cnpj não estiver preenchido grava o CNPJ do Exportador                                                                   
      INT_NC->NNCCNPJ := cCnpj
   EndIf
EndIf

//aAdd(aValCapa,{Int_Nc->(NNCPRO+NNCSER+NNCNF),INT_NC->NNCREC,INT_NC->NNCTIPO, Int_Nc->(Recno()), 0})

IF lITERRO
   Int_NC->NNCITEM_OK := "F"
   INT_NC->NNCMSG     := STR0174 + ENTER // Aviso: .....Vide Itens
   INT_NC->NNCINT_OK  := "F"
ENDIF
IF INT_NC->NNCINT_OK = "T"
   nResumoCer+=1
   aAdd(aSeqCapa,{Int_Nc->(NNCPRO+NNCSER+NNCNF),INT_NC->NNCREC,INT_NC->NNCTIPO}) // By JPP - 29/11/2006 - 12:00 - Array utilizado para tratar situações que existam integrações simultaneas, Ex: integração do tipo inclusão e em seguida exclusão.
ELSE
   aAdd(aCapaErro,{Int_Nc->(NNCPRO+NNCSER+NNCNF), INT_NC->NNCREC, INT_NC->NNCTIPO, Int_Nc->(Recno()), 0})
   nResumoErr+=1
ENDIF   
//
//--- ADC 14/02/2011 Para tratamento da integração EICIN100 x AvInteg (atualizando corretamente o Status
//							do registro da Capa conforme as últimas validações realizadas nos registros)
If lBUpDate
   Eval(bUpDate, INT_NC->NNCMSG,INT_NC->NNCINT_OK)
EndIf
//

nTipValCapa := 0

//If aScan(aCapaErro, {|x| x[1] == Int_Nc->(NNCPRO+NNCSER+NNCNF) }) > 0 
If aScan(aValCapa, {|x| x[1] == Int_Nc->(NNCPRO+NNCSER+NNCNF) }) > 0   
   For nInc := 1 To Len(aValCapa)
      If aValCapa[nInc][1] == Int_Nc->(NNCPRO+NNCSER+NNCNF) .And. Empty(aValCapa[nInc][2]);
         .And. aValCapa[nInc][5] == 0
         nRecnoOld := Int_Nc->(Recno())
         Int_Nc->(DbGoTo(aValCapa[nInc][4]))
         Int_NC->NNCITEM_OK := "F"
         INT_NC->NNCMSG     := INT_NC->NNCMSG + STR0358//"Existe mais de uma operação com a mesma nota. Para que a integração funcione corretamente, a sequência de integração das notas deve ser informada."
         INT_NC->NNCINT_OK  := "F"
         //--- ADC 14/02/2011 Para tratamento da integração EICIN100 x AvInteg (atualizando corretamente o Status
         //							do registro da Capa conforme as últimas validações realizadas nos registros)
         If lBUpDate
            Eval(bUpDate, INT_NC->NNCMSG,INT_NC->NNCINT_OK)
         EndIf
         //
         Int_Nc->(DbGoTo(nRecnoOld))
         aValCapa[nInc][5] := 1

         Int_NC->NNCITEM_OK := "F"
         INT_NC->NNCMSG     := INT_NC->NNCMSG + STR0358//"Existe mais de uma operação com a mesma nota. Para que a integração funcione corretamente, a sequência de integração das notas deve ser informada."
         INT_NC->NNCINT_OK  := "F"
         //--- ADC 14/02/2011 Para tratamento da integração EICIN100 x AvInteg (atualizando corretamente o Status
         //							do registro da Capa conforme as últimas validações realizadas nos registros)
         If lBUpDate
            Eval(bUpDate, INT_NC->NNCMSG,INT_NC->NNCINT_OK)
         EndIf
         //
         
         nTipValCapa := 1
         
      EndIf
   Next
EndIf

aAdd(aValCapa,{Int_Nc->(NNCPRO+NNCSER+NNCNF),INT_NC->NNCREC,INT_NC->NNCTIPO, Int_Nc->(Recno()), nTipValCapa})

RETURN(.T.)


/*
Função     : IN100GRVNC
Objetivo   : Gravar NF (Capa).
Retorno    : .T.
Autor      : Alexsander Martins dos Santos
Data e Hora: 30/08/2004 às 10:13.
*/

Function IN100GRVNC()

Local lRet      := .T.
Local aSaveOrd  := SaveOrd({"EEC", "EEM", "EES"}, 1)

Local nPos
Local lEEMFaltaCmp := .F.
Local lEESFaltaCmp := .F.
Local lBUpDate:= .F.

If Type("bUpDate") == "B"
   lBUpDate:= .T.
EndIf

Begin Sequence

   Begin Transaction

      /*
      Exclusão da NF e dos itens.
      */
      If INT_NC->NNCTIPO = EXCLUSAO
         
         //** AAF 09/01/08 - Estorna a Nota Fiscal no Contábil
         If EasyGParam("MV_EEC_ECO",,.F.)
            AE100EstCon("ESTORNA_NF",EEM->EEM_PREEMB)
         EndIf
         //**
         
         If EEM->(FieldPos("EEM_CNPJ")) > 0  // By JPP - 20/03/2006 - 09:20  
            EEM->(DBSETORDER(3))
            EEM->(DBSEEK(cFILEEM+AVKEY(INT_NC->NNCCNPJ,"EEM_CNPJ")+AVKEY(INT_NC->NNCNF,"EEM_NRNF")+AVKEY(INT_NC->NNCSER,"EEM_SERIE")))

            RECLOCK("EEM", .F.)

            EES->(DBSETORDER(3))
            //EES->(DBSEEK(cFILEES+AVKEY(INT_ND->NNDCNPJ,"EES_CNPJ")+AVKEY(INT_ND->NNDNF,"EES_NRNF")+AVKEY(INT_ND->NNDSER,"EES_SERIE")))
            EES->(DBSEEK(cFILEES+AVKEY(INT_NC->NNCCNPJ,"EES_CNPJ")+AVKEY(INT_NC->NNCNF,"EES_NRNF")+AVKEY(INT_NC->NNCSER,"EES_SERIE")))

            DO WHILE !EES->(EOF()) .AND.;
                     EES->(EES_FILIAL+EES_CNPJ+EES_NRNF+EES_SERIE) = (cFILEES+AVKEY(INT_NC->NNCCNPJ,"EES_CNPJ")+AVKEY(INT_NC->NNCNF,"EES_NRNF")+AVKEY(INT_NC->NNCSER,"EES_SERIE"))

               EES->(RECLOCK("EES", .F.))
               EES->(DBDELETE())
               EES->(MsUnLock())	//--- ADC 11/02/2011
               EES->(DBSKIP())

            ENDDO
         Else
            EEM->(DBSETORDER(1))
            EEM->(DBSEEK(cFILEEM+AVKEY(INT_NC->NNCPRO,"EEM_PREEMB")+"N"+AVKEY(INT_NC->NNCNF,"EEM_NRNF")+AVKEY(INT_NC->NNCTNF,"EEM_TIPONF")))

            RECLOCK("EEM", .F.)

            EES->(DBSETORDER(1))
            //EES->(DBSEEK(cFILEES+AVKEY(INT_ND->NNDPRO,"EES_PREEMB")+AVKEY(INT_ND->NNDNF,"EES_NRNF"))) // By JPP - 27/07/2007 - 16:50 - Para localizar as notas do item, deve-se basear na nota informada na capa INT_NC e não no item INT_ND, pois não há posicionamento do item.
            EES->(DBSEEK(cFILEES+AVKEY(INT_NC->NNCPRO,"EES_PREEMB")+AVKEY(INT_NC->NNCNF,"EES_NRNF"))) // By JPP - 27/07/2007 - 16:50
            DO WHILE !EES->(EOF()) .AND.;
                     EES->(EES_FILIAL+EES_PREEMB+EES_NRNF) = (cFILEES+AVKEY(INT_NC->NNCPRO,"EES_PREEMB")+AVKEY(INT_NC->NNCNF,"EES_NRNF"))

               EES->(RECLOCK("EES", .F.))
               EES->(DBDELETE())
               EES->(MsUnLock())	//--- ADC 11/02/2011
               EES->(DBSKIP())

            ENDDO
         EndIf   

         IF EasyEntryPoint("IN100CLI")  
            EXECBLOCK("IN100CLI",.F.,.F.,"DELNC")
         ENDIF   

         EEM->(DBDELETE())
         EEM->(MsUnLock())	//--- ADC 11/02/2011
        
      EndIf

      /*
      Cancelamento da NF.
      */
      If INT_NC->NNCTIPO = "C"

         EEC->(dbSetOrder(1))
         EEC->(dbSeek(cFilEEC+Int_NC->NNCPRO))

         RecLock("EEC", .F.)

         EEC->EEC_FIM_PE := dDataBase
         EEC->EEC_STATUS := ST_PC
         EEC->EEC_STTDES := Tabela("YC", EEC->EEC_STATUS)

      EndIf

      /*
      Inclusão de NF.
      */      
      If INT_NC->NNCTIPO = INCLUSAO
      
         RecLock("EEM", .T.)

         EEM->EEM_FILIAL := cFILEEM
         EEM->EEM_PREEMB := INT_NC->NNCPRO
         EEM->EEM_TIPOCA := "N"
         EEM->EEM_NRNF   := INT_NC->NNCNF
         EEM->EEM_SERIE  := INT_NC->NNCSER
         
         //RMD - 24/02/15 - Projeto Chave NF
         SerieNfId("EEM",1,"EEM_SERIE",,,,EEM->EEM_SERIE)
         
         EEM->EEM_DTNF   := IN100CTD(INT_NC->NNCDT,,"DDMMAAAA")
         EEM->EEM_TIPONF := INT_NC->NNCTNF
         EEM->EEM_VLNF   := VAL(INT_NC->NNCVNF)
         EEM->EEM_VLMERC := VAL(INT_NC->NNCVME)
         EEM->EEM_VLFRET := VAL(INT_NC->NNCVFR)
         EEM->EEM_VLSEGU := VAL(INT_NC->NNCVSE)
         EEM->EEM_OUTROS := VAL(INT_NC->NNCTOU)

         aCmpEEM := { "EEM_VLNFM",  "EEM_VLMERM", "EEM_VLFREM",;
                      "EEM_VLSEGM", "EEM_OUTROM", "EEM_TXFRET",;
                      "EEM_TXSEGU", "EEM_TXOUDE" }

         For nPos := 1 To Len(aCmpEEM)
            If EEM->(FieldPos(aCmpEEM[nPos])) = 0
               lEEMFaltaCmp := .T.
               Exit
            EndIf
         Next

         If !lEEMFaltaCmp
            EEM->EEM_VLNFM  := VAL(INT_NC->NNCVNFM)
            EEM->EEM_VLMERM := VAL(INT_NC->NNCVMEM)
            EEM->EEM_VLFREM := VAL(INT_NC->NNCVFRM)
            EEM->EEM_TXFRET := VAL(INT_NC->NNCTXFR)
            EEM->EEM_VLSEGM := VAL(INT_NC->NNCVSEM)
            EEM->EEM_TXSEGU := VAL(INT_NC->NNCTXSE)
            EEM->EEM_OUTROM := VAL(INT_NC->NNCTOUM)
            EEM->EEM_TXOUDE := VAL(INT_NC->NNCTXOD)
         EndIf

         IF EEM->(FIELDPOS("EEM_TXTB")) > 0
            EEM->EEM_TXTB := VAL(INT_NC->NNCTX)
         ENDIF

         If EEM->(FieldPos("EEM_CF")) > 0
            EEM->EEM_CF := INT_NC->NNCCF
         EndIf

         If EEM->(FieldPos("EEM_CNPJ")) > 0  // By JPP - 20/03/2006 - 09:20  
            EEM->EEM_CNPJ := INT_NC->NNCCNPJ
         EndIf
         /*
         Inclusão dos itens da NF.
         */
         INT_ND->(DBSEEK(INT_NC->(NNCPRO+NNCSER+NNCNF+NNCREC)))  // By JPP - 28/11/2006 - 16:50 - Inclusão do campo NNCREC na chave. 
         DO WHILE ! INT_ND->(EOF()) .AND. INT_ND->(NNDPRO+NNDSER+NNDNF+NNDREC) = INT_NC->(NNCPRO+NNCSER+NNCNF+NNCREC)  // By JPP - 28/11/2006 - 16:50 - Inclusão dos campos NNCREC/NNDREC na chave. 
            
            IF INT_ND->NNDTIPO = INCLUSAO
             
               EES->(RECLOCK("EES",.T.))

            ELSEIF INT_ND->NNDTIPO = EXCLUSAO                        
            
               If EES->(FieldPos("EES_CNPJ")) > 0  // By JPP - 20/03/2006 - 09:20  
                  EES->(DbSetOrder(3))
                  EES->(DbSeek(cFILEES+AvKey(INT_ND->NNDCNPJ,"EES_CNPJ")+AVKEY(INT_ND->NNDNF,"EES_NRNF")+AVKEY(INT_ND->NNDSER,"EES_SERIE")))
               
                  DO WHILE !EES->(EOF()) .AND.;
                            EES->(EES_FILIAL+EES_CNPJ+EES_NRNF+EES_SERIE) = (cFILEES+AvKey(INT_ND->NNDCNPJ,"EES_CNPJ")+;
                                                                            AvKey(INT_ND->NNDNF,"EES_NRNF")+;
                                                                            AvKey(INT_ND->NNDSER,"EES_SERIE"))

                     IF AVKEY(EES->EES_COD_I,"EE9_COD_I") = AVKEY(INT_ND->NNDITE,"EE9_COD_I")
                        EXIT
                     ENDIF

                     EES->(DBSKIP())

                  ENDDO
               Else    // Rotina antiga
                  EES->(DBSETORDER(1))
                  EES->(DBSEEK(cFILEES+AVKEY(INT_ND->NNDPRO,"EES_PREEMB")+AVKEY(INT_ND->NNDNF,"EES_NRNF")))
               
                  DO WHILE !EES->(EOF()) .AND.;
                            EES->(EES_FILIAL+EES_PREEMB+EES_NRNF) = (cFILEES+AVKEY(INT_ND->NNDPRO,"EES_PREEMB")+AVKEY(INT_ND->NNDNF,"EES_NRNF"))

                     IF AVKEY(EES->EES_COD_I,"EE9_COD_I") = AVKEY(INT_ND->NNDITE,"EE9_COD_I")
                        EXIT
                     ENDIF

                     EES->(DBSKIP())

                  ENDDO               
               EndIf
               
               EES->(RECLOCK("EES", .F.))
               EES->(DBDELETE())

               IF EasyEntryPoint("IN100CLI")

                  EXECBLOCK("IN100CLI",.F.,.F.,"DELND")
               ENDIF                     

            ENDIF

            EES->EES_FILIAL := cFILEES
            EES->EES_PREEMB := INT_ND->NNDPRO
            EES->EES_NRNF   := INT_ND->NNDNF
            EES->EES_SERIE  := INT_ND->NNDSER
            
            //RMD - 24/02/15 - Projeto Chave NF
            SerieNfId("EES",1,"EES_SERIE",,,,EES->EES_SERIE)
            
            EES->EES_DTNF   := IN100CTD(INT_NC->NNCDT,,"DDMMAAAA")   //TRP - 11/09/2012 - Gravar a Data do item da Nota com a data da Capa.
            EES->EES_VLNF   := VAL(INT_ND->NNDVNF)
            EES->EES_VLMERC := VAL(INT_ND->NNDVME)
            EES->EES_VLFRET := VAL(INT_ND->NNDVFR)
            EES->EES_VLSEGU := VAL(INT_ND->NNDVSE)
            EES->EES_VLOUTR := VAL(INT_ND->NNDTOU)
            EES->EES_PEDIDO := INT_ND->NNDPED
            EES->EES_COD_I  := INT_ND->NNDITE
            EES->EES_SEQUEN := STR(VAL(INT_ND->NNDPOS),LEN(EES->EES_SEQUEN))
            EES->EES_QTDE   := VAL(INT_ND->NNDQTD)            

            aCmpEES := { "EES_VLNFM",  "EES_VLMERM", "EES_VLFREM",;
                         "EES_VLSEGM", "EES_VLOUTM" }

            For nPos := 1 To Len(aCmpEES)
               If EES->(FieldPos(aCmpEES[nPos])) = 0
                  lEESFaltaCmp := .T.
                  Exit
               EndIf
            Next

            If !lEESFaltaCmp
               EES->EES_VLNFM  := VAL(INT_ND->NNDVNFM)
               EES->EES_VLMERM := VAL(INT_ND->NNDVMEM)
               EES->EES_VLFREM := VAL(INT_ND->NNDVFRM)
               EES->EES_VLSEGM := VAL(INT_ND->NNDVSEM)
               EES->EES_VLOUTM := VAL(INT_ND->NNDTOUM)
            EndIf
            If EES->(FieldPos("EES_CNPJ")) > 0  // By JPP - 20/03/2006 - 09:20  
               EES->EES_CNPJ := INT_ND->NNDCNPJ
            EndIf


            IF EasyEntryPoint("IN100CLI")
               EXECBLOCK("IN100CLI",.F.,.F.,"GRVND")
            ENDIF
         
            //igorchiba  23/12/2010 
            // chamar a funçao do avinteg para o  item nota fiscal saida, esta funçao grava na base os campos que não tratados pelo EICIN100
            IF lBUpDate
               oldcfuncao:=cfuncao
               cfuncao   :="ND"
               EasyExRdm("AvIntExtra")
              cfuncao    :=oldcfuncao
            ENDIF
            

            INT_ND->(DBSKIP())

         ENDDO

         If EasyGParam("MV_AVG0069", .F., .F.)
            If aScan(aEECProc, INT_NC->NNCPRO) = 0
               aAdd(aEECProc,  INT_NC->NNCPRO)
            EndIf
         EndIf

         IF EasyEntryPoint("IN100CLI")
            EXECBLOCK("IN100CLI",.F.,.F.,"GRVNC")
         ENDIF

      EndIf

   End Transaction

End Sequence

RestOrd(aSaveOrd)

Return(lRet)


//AAS
*----------------------*
FUNCTION IN100PRECO()
*----------------------*
AADD(TB_Cols,{ {|| Int_TP->NTPPRO }, ""                              , STR0314 }) //"Produto" 
AADD(TB_Cols,{ {|| Int_TP->NTPPAI }, ""										, STR0315 }) //"Pais"
AADD(TB_Cols,{ {|| Int_TP->NTPMPA }, ""										, STR0316 }) //"Moeda Pais"
AADD(TB_Cols,{ {|| TRANSFORM(VAL(Int_TP->NTPPPA),AVSX3("EX5_PRECO",6))},""   , STR0317 }) //"Preco Pais"
AADD(TB_Cols,{ {|| IN100CTD(Int_TP->NTPINI) }, ""							, STR0318 }) //"Data INICIAL Pais"
AADD(TB_Cols,{ {|| IN100CTD(Int_TP->NTPFIM) }, ""							, STR0325 }) //"Data final Pais"
AADD(TB_Cols,{ {|| Int_TP->NTPCLI }, ""										, STR0319 }) //"Cliente" 
AADD(TB_Cols,{ {|| Int_TP->NTPLOJ }, ""										, STR0321 }) //"Loja"
AADD(TB_Cols,{ {|| Int_TP->NTPMCL }, ""										, STR0320 }) //"Moeda Cliente"
AADD(TB_Cols,{ {|| TRANSFORM(VAL(Int_TP->NTPPR1),AVSX3("EX5_PRECO",6))},""   , STR0322 }) //"Prec. Venda"
AADD(TB_Cols,{ {|| IN100CTD(Int_TP->NTPIN2) }, ""							, STR0323 }) //"Data Inicio Cliente"  
AADD(TB_Cols,{ {|| IN100CTD(Int_TP->NTPFI2) }, ""							, STR0324 }) //"Data Fim Cliente"

ASIZE(TBRCols,0)
AADD(TBRCols,{ "IN100Status()"              , STR0036 }) 
AADD(TBRCols,{ "IN100Tipo()"                , STR0037 }) 
AADD(TBRCols,{ "IN100CTD(Int_TP->NTPINT_DT)", STR0071 })
AADD(TBRCols,{ "Int_TP->NTPPRO"             , STR0314 }) 
AADD(TBRCols,{ "Int_TP->NTPPAI"             , STR0315 })
AADD(TBRCols,{ "Int_TP->NTPMPA"             , STR0316 }) 
AADD(TBRCols,{ "TRANSFORM(VAL(Int_TP->NTPPPA),'"+AVSX3("EX5_PRECO",6)+"')", STR0317})//AAF 30/09/04 - Incluso a Picture
AADD(TBRCols,{ "IN100CTD(Int_TP->NTPINI)"   , STR0318 })
AADD(TBRCols,{ "IN100CTD(Int_TP->NTPFIM)"   , STR0325 })
AADD(TBRCols,{ "Int_TP->NTPCLI"             , STR0319 }) 
AADD(TBRCols,{ "Int_TP->NTPMCL"             , STR0320 })
AADD(TBRCols,{ "Int_TP->NTPLOJ"             , STR0321 }) 
AADD(TBRCols,{ "TRANSFORM(VAL(Int_TP->NTPPR1),'"+AVSX3("EX5_PRECO",6)+"')", STR0322})//AAF 30/09/04 - Incluso a Picture
AADD(TBRCols,{ "IN100CTD(Int_TP->NTPIN2)"   , STR0323 })
AADD(TBRCols,{ "IN100CTD(Int_TP->NTPFI2)"   , STR0324 })

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"COLTP")
ENDIF
AADD(TB_Cols,{ {|| IN100E_Msg(.T.) }, "", STR0112 }) // "Mensagem"
SB1->(DBSETORDER(1))
SYA->(DBSETORDER(1))
SYF->(DBSETORDER(1))
SA1->(DBSETORDER(1))
RETURN .T.

*--------------------*
FUNCTION IN100LerTP()
*--------------------*
Local lAltera:=.F.
Local aSaveOrd := SaveOrd("EX5", 1)
Local cPaisAtu:="" //País do cliente atual - Alcir Alves - 22-09-05
Int_TP->NTPTIP2 := Int_TP->NTPTIPO

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"LERTP")
ENDIF


//Alcir Alves - 22-09-05
// segundo analise do Alx.Costa so poderam ser integrados dados se a triade de chaves (cod,moeda,valor) do pais/cliente ou ambos estiverem preenchidos
If Int_TP->NTPTIPO <> EXCLUSAO .AND. !(EMPTY(Int_TP->NTPPPA) .AND. EMPTY(Int_TP->NTPMPA) .AND. EMPTY(Int_TP->NTPPAI)) //somente graava no sx5 quando os tres campos do país estiverem preenchidos (Codigo,Moeda e Valor)
   IF (EMPTY(Int_TP->NTPPPA) .AND. ( !EMPTY(Int_TP->NTPMPA) .OR. !EMPTY(Int_TP->NTPPAI))) .OR. ;
      (EMPTY(Int_TP->NTPMPA) .AND. ( !EMPTY(Int_TP->NTPPPA) .OR. !EMPTY(Int_TP->NTPPAI))) .OR. ;
      (EMPTY(Int_TP->NTPPAI) .AND. ( !EMPTY(Int_TP->NTPPPA) .OR. !EMPTY(Int_TP->NTPMPA)))   
      EVAL(bmsg,STR0341) //Codigo,Moeda e Valor do País inválidos
    ENDIF
ENDIF
//
 
IF ! SB1->(DBSEEK(cFilSB1+Int_TP->NTPPRO))
   EVAL(bmsg,STR0303) //Produto não cadastrado 
ENDIF
  
IF !EMPTY(Int_TP->NTPPAI)
   IF ! SYA->(DBSEEK(cFilSYA+Int_TP->NTPPAI))
      EVAL(bmsg,STR0304) //País não cadastrado
   ENDIF 
ENDIF

IF !EMPTY(Int_TP->NTPMPA)
   IF ! SYF->(DBSEEK(cFilSYF+Int_TP->NTPMPA))
      EVAL(bmsg,STR0305) ///Moeda do pais não cadastrado
   ENDIF   
ENDIF

If !Empty(Int_TP->NTPINI) .and. !IN100CTD(Int_TP->NTPINI,.T.)
   EVAL(bmsg,STR0325+STR0227) //Data Inicial Pais inválido
EndIf

If !Empty(Int_TP->NTPFIM) .and. !IN100CTD(Int_TP->NTPFIM,.T.)
   EVAL(bmsg,STR0318+STR0227) //Data Final Pais inválido
EndIf

If Int_TP->NTPTIPO <> EXCLUSAO
   If !Empty(Val(Int_TP->NTPPPA)) .and. IN100NaoNum(Int_TP->NTPPPA)//AAF 25/10/04 - Verifica o Valor e não a String
      EVAL(bmsg,STR0317+STR0227) //Preço Pais inválido
   ElseIf !Empty(Int_TP->NTPINI) .and. !Empty(Int_TP->NTPFIM) .and. Empty(Val(Int_TP->NTPPPA))//AAF 25/10/04 - Verifica o Valor e não a String
      EVAL(bmsg,STR0317+STR0230) //Preço Pais não informado
   Endif
EndIf

//Alcir Alves - 22-09-05
// segundo analise do Alx.Costa so poderam ser integrados dados se a triade de chaves (cod,moeda,valor) do pais/cliente ou ambos estiverem preenchidos
If Int_TP->NTPTIPO <> EXCLUSAO .AND. !(EMPTY(Int_TP->NTPPR1) .AND. EMPTY(Int_TP->NTPMCL) .AND. EMPTY(Int_TP->NTPCLI)) //somente grava no sx6 quando os tres campos do CLIENTE estiverem preenchidos Codigo,Moeda e Valor
   IF (EMPTY(Int_TP->NTPPR1) .AND. ( !EMPTY(Int_TP->NTPMCL) .OR. !EMPTY(Int_TP->NTPCLI))) .OR. ;
      (EMPTY(Int_TP->NTPMCL) .AND. ( !EMPTY(Int_TP->NTPPR1) .OR. !EMPTY(Int_TP->NTPCLI))) .OR. ;
      (EMPTY(Int_TP->NTPCLI) .AND. ( !EMPTY(Int_TP->NTPPR1) .OR. !EMPTY(Int_TP->NTPMCL)))   
      EVAL(bmsg,STR0342) //Codigo,Moeda e Valor do Cliente inválidos
    ENDIF
ENDIF
//        
 
If !Empty(Int_TP->NTPCLI)
   IF EMPTY(Int_TP->NTPLOJ)
      Int_TP->NTPLOJ:=". "
   ENDIF     
   IF ! SA1->(DBSEEK(cFilSA1+Int_TP->NTPCLI+Int_TP->NTPLOJ))
      EVAL(bmsg,STR0307) ///Cliente não cadastrado
   ENDIF
   if empty(SA1->A1_PAIS)
      EVAL(bmsg,STR0343) ///"País no cadastro de cliente vazio"
   else
      cPaisAtu:=AvKey(SA1->A1_PAIS, "EX6_PAIS") 
   endif
   
   
   
   If Empty(Int_TP->NTPMCL)
      EVAL(bmsg,STR0320+STR0230) // Moeda Cliente não informado
   ElseIf ! SYF->(DBSEEK(cFilSYF+Int_TP->NTPMCL))
      EVAL(bmsg,STR0306) ///Moeda do cliente não cadastrado
   ENDIF   
     
   If Empty(Int_TP->NTPPR1)
      EVAL(bmsg,STR0322+STR0230) // Preco Venda nao informado
   ElseIf IN100NaoNum(Int_TP->NTPPR1)
      EVAL(bmsg,STR0322+STR0227) // Preco Venda inválido
   EndIf
   
   If !Empty(Int_TP->NTPIN2) .and. !IN100CTD(Int_TP->NTPIN2,.T.)
      EVAL(bmsg,STR0323+STR0227) //Data Inicial Cliente inválido
   EndIf

   If !Empty(Int_TP->NTPFI2) .and. !IN100CTD(Int_TP->NTPFI2,.T.)
      EVAL(bmsg,STR0324+STR0227) //Data Final Cliente inválido
   EndIf
ENDIF
  
/*Alteração
A data inicial não pode ser menor que a data de hoje caso periodo esteja em aberto
Quando em aberto*/
  
/*"NTPPR1"
"NTPIN2"
"NTPFI2"*/
if (!EMPTY(Int_TP->NTPPPA) .AND. !EMPTY(Int_TP->NTPMPA) .AND. !EMPTY(Int_TP->NTPPAI))  
   If !Empty(Int_TP->NTPINI)
      EX5->(dbSetOrder(2))
      If !EX5->(dbSeek(cFilEX5+Int_TP->NTPPRO+Int_TP->NTPPAI+DtoS(IN100CTD(Int_TP->NTPFIM))+DtoS(IN100CTD(Int_TP->NTPINI))))
         If Int_TP->NTPTIPO = EXCLUSAO .and. (!EMPTY(Int_TP->NTPPPA) .AND. !EMPTY(Int_TP->NTPMPA) .AND. !EMPTY(Int_TP->NTPPAI)) //Alcir Alves -22-09-05
            EVAL(bmsg,STR0313) // Tabela de preco não cadastrada para este produto e país
         ElseIf EX5->(dbSeek(cFilEX5+Int_TP->NTPPRO+Int_TP->NTPPAI))
            If !Empty(EX5->EX5_DTFIM)
               If Int_TP->NTPTIPO = ALTERACAO
                  Int_TP->NTPTIPO := INCLUSAO
               EndIf
               EX5->(AvSeekLast(cFilEX5+Int_TP->NTPPRO+Int_TP->NTPPAI))
               If IN100CTD(Int_TP->NTPINI) < EX5->EX5_DTFIM
                  EVAL(bmsg,STR0325+STR0227) // Data Inicial Inválida
               Endif
            Else
               Do While !EX5->(EOF()) .and. IN100CTD(Int_TP->NTPINI) > EX5->EX5_DTINI
                  EX5->(dbSkip())
               EndDo
               If IN100CTD(Int_TP->NTPINI) = EX5->EX5_DTINI
                  lAltera := .T.
                  Int_TP->NTPTIPO := ALTERACAO
               Else
                  Int_TP->NTPTIPO := INCLUSAO
               EndIf
               If !lAltera .and. Empty(Int_TP->NTPFIM) .and. IN100CTD(Int_TP->NTPINI) < dDataBase
                  EVAL(bmsg,STR0325+STR0227) // Data Inicial Inválida
               EndIf
            EndIf
         ElseIf Int_TP->NTPTIPO = ALTERACAO
            Int_TP->NTPTIPO := INCLUSAO
         EndIf
      ElseIf Int_TP->NTPTIPO = INCLUSAO
         Int_TP->NTPTIPO := ALTERACAO
      EndIf
   ElseIf !Empty(Int_TP->NTPFIM)
      EVAL(bmsg,STR0325+STR0230) //Data Inicial não informada
   ElseIf EX5->(dbSeek(cFilEX5+Int_TP->NTPPRO+Int_TP->NTPPAI)) 
      If Int_TP->NTPTIPO = INCLUSAO
         Int_TP->NTPTIPO := ALTERACAO
      Endif
   Else
      If Int_TP->NTPTIPO = ALTERACAO
         Int_TP->NTPTIPO := INCLUSAO
      ElseIf Int_TP->NTPTIPO = EXCLUSAO .and. (!EMPTY(Int_TP->NTPPPA) .AND. !EMPTY(Int_TP->NTPMPA) .AND. !EMPTY(Int_TP->NTPPAI)) //Alcir Alves -22-09-05
         EVAL(bmsg,STR0313) // Tabela de preco não cadastrada para este produto e país
      Endif
   EndIf
endif


If (!EMPTY(Int_TP->NTPPR1) .AND. !EMPTY(Int_TP->NTPMCL) .AND. !EMPTY(Int_TP->NTPCLI)) //Alcir Alves - 22-09-05

   If !Empty(Int_TP->NTPIN2)
      EX6->(dbSetOrder(3))
      If !EX6->(dbSeek(cFilEX6+Int_TP->NTPPRO+cPaisAtu+Int_TP->NTPCLI+Int_TP->NTPLOJ+DtoS(IN100CTD(Int_TP->NTPFI2))+DtoS(IN100CTD(Int_TP->NTPIN2))))//HFD - 10.mar.2009 - Inclusão do campo loja
         If Int_TP->NTPTIP2 = EXCLUSAO 
            EVAL(bmsg,STR0312) // Tabela de preco não cadastrada para este produto e cliente
         ElseIf EX6->(dbSeek(cFilEX6+Int_TP->NTPPRO+cPaisAtu+Int_TP->NTPCLI+Int_TP->NTPLOJ))//HFD - 10.mar.2009 - Inclusão do campo loja
            If !Empty(EX6->EX6_DTFIM)
               If Int_TP->NTPTIP2 = ALTERACAO
                  Int_TP->NTPTIP2 := INCLUSAO
                  Int_TP->NTPTIPO := Int_TP->NTPTIP2
               EndIf
               EX6->(AvSeekLast(cFilEX6+Int_TP->NTPPRO+Int_TP->NTPPAI+Int_TP->NTPCLI+Int_TP->NTPLOJ))//HFD - 10.mar.2009 - Inclusão do campo loja
               If IN100CTD(Int_TP->NTPIN2) < EX6->EX6_DTFIM
                  EVAL(bmsg,STR0324+STR0227) // Data Inicial Inválida
               Endif
            Else
               Do While !EX6->(EOF()) .and. IN100CTD(Int_TP->NTPIN2) > EX6->EX6_DTINI
                  EX6->(dbSkip())
               EndDo
               If IN100CTD(Int_TP->NTPIN2) = EX6->EX6_DTINI
                  lAltera := .T.
                  Int_TP->NTPTIP2 := ALTERACAO
               Else
                  Int_TP->NTPTIP2 := INCLUSAO
               EndIf
               Int_TP->NTPTIPO := Int_TP->NTPTIP2
               If !lAltera .and. Empty(Int_TP->NTPFI2) .and. IN100CTD(Int_TP->NTPIN2) < dDataBase
                  EVAL(bmsg,STR0324+STR0227) // Data Inicial Inválida
               EndIf
            EndIf
         ElseIf Int_TP->NTPTIP2 = ALTERACAO
            Int_TP->NTPTIP2 := INCLUSAO
            Int_TP->NTPTIPO := Int_TP->NTPTIP2
         EndIf
      ElseIf Int_TP->NTPTIP2 = INCLUSAO
         Int_TP->NTPTIP2 := ALTERACAO
         Int_TP->NTPTIPO := Int_TP->NTPTIP2
      EndIf
   ElseIf !Empty(Int_TP->NTPFI2)
      EVAL(bmsg,STR0324+STR0230) //Data Inicial não informada
   ElseIf EX6->(dbSeek(cFilEX6+Int_TP->NTPPRO+cPaisAtu+Int_TP->NTPCLI+Int_TP->NTPLOJ)) //HFD - 10.mar.2009 - Inclusão do campo loja
      If Int_TP->NTPTIP2 = INCLUSAO
         Int_TP->NTPTIP2 := ALTERACAO
         Int_TP->NTPTIPO := Int_TP->NTPTIP2 
      Endif
   Else
      If Int_TP->NTPTIP2 = ALTERACAO
         Int_TP->NTPTIP2 := INCLUSAO
         Int_TP->NTPTIPO := Int_TP->NTPTIP2          
      ElseIf Int_TP->NTPTIP2 = EXCLUSAO 
         EVAL(bmsg,STR0312) // Tabela de preco não cadastrada para este produto e cliente
      Endif
   EndIf
EndIf
  
EX5->(DBSETORDER(1))
EX6->(DBSETORDER(1))
/*EX5ACHA:=EX5->(DBSEEK(cFilEX5+Int_TP->NTPPRO+Int_TP->NTPPAI))
 
if !empty(Int_TP->NTPCLI)
   EX6->(DBSETORDER(1))
   EX6ACHA:=EX6->(DBSEEK(cFilEX6+Int_TP->NTPPRO+Int_TP->NTPPAI+Int_TP->NTPCLI+Int_TP->NTPLOJ))
else
   EX6ACHA:=.F.
endif
   
IF Int_TP->NTPTIPO == INCLUSAO
   IF EX6ACHA==.T.
      EVAL(bmsg,STR0310) // Tabela de preco já cadastrada para este produto e cliente
   ENDIF	
   IF EX5ACHA==.T. .and. empty(Int_TP->NTPCLI) 
      EVAL(bmsg,STR0309) // "Tabela de preco já cadastrada para este produto e país"
   ENDIF	
ELSEIF Int_TP->NTPTIPO == EXCLUSAO
   IF EX6ACHA==.F. .and. !empty(Int_TP->NTPCLI)
      EVAL(bmsg,STR0312) // Tabela de preco não cadastrada para este produto e cliente
   ENDIF	
   IF EX5ACHA==.F.
      EVAL(bmsg,STR0311) // Produto e país não localizado
   ENDIF	
ENDIF*/

If Int_TP->NTPTIPO == INCLUSAO .and. EX5->(dbSeek(cFilEX5+AvKey(Int_TP->NTPPRO, "EX5_COD_I")+AvKey(Int_TP->NTPPAI, "EX5_PAIS")))
   While EX5->(!Eof() .and. EX5_FILIAL == cFilEX5 .and. EX5_COD_I == AvKey(Int_TP->NTPPRO, "EX5_COD_I") .and. EX5_PAIS == AvKey(Int_TP->NTPPAI, "EX5_PAIS"))
      If Empty(EX5->EX5_DTFIM)
         Eval(bmsg, "Existe preço sem aprovação para este pais.")
         Exit
      EndIf
      EX5->(dbSkip())
   End
EndIf

If !Empty(Int_TP->NTPCLI) .and. (Int_TP->NTPTIPO == ALTERACAO .or. Int_TP->NTPTIPO == INCLUSAO)
   If EX6->(dbSeek(cFilEX6+AvKey(Int_TP->NTPPRO, "EX6_COD_I")+cPaisAtu+AvKey(Int_TP->NTPCLI, "EX6_CLIENT") + AvKey(Int_TP->NTPLOJ, "EX6_CLLOJA")))
      While EX6->(!Eof() .and. EX6_FILIAL == cFilEX6 .and. EX6_COD_I == AvKey(Int_TP->NTPPRO, "EX6_COD_I") .and. EX6_PAIS == AvKey(Int_TP->NTPPAI, "EX6_PAIS") .and. EX6_CLIENT == AvKey(Int_TP->NTPCLI, "EX6_CLIENT") .and. EX6_CLLOJA == AvKey(Int_TP->NTPLOJ, "EX6_CLLOJA"))
         If EX6->(Empty(EX6_DTINI) .and. Empty(EX6_DTFIM))
            Eval(bmsg, "Existe preço sem aprovação para este cliente.")
            Exit
         EndIf
         EX6->(dbSkip())
      End
   EndIf
EndIf

IF EasyEntryPoint("IN100CLI")
   ExecBlock("IN100CLI",.F.,.F.,"VALTP")
ENDIF

IN100VerErro(cErro,cAviso)
IF Int_TP->NTPINT_OK = "T"
   nResumoCer+=1
ELSE
   nResumoErr+=1
ENDIF
 
RestOrd(aSaveOrd)

Return .T.

//ALCIR - 26-07-04

*------------------------------------------------------------------------------------------*
FUNCTION IN100GrvTP()
*------------------------------------------------------------------------------------------*
LOCAL lAtu:=.T. //cAlias, sArea
Local lIncTP := .F.,ldelTP:=.F. 
EX5->(dbSetOrder(2))
EX6->(dbSetOrder(3))
//Alcir Alves - caso integração de cliente atribui o país do cadastro
if (!EMPTY(Int_TP->NTPPR1) .AND. !EMPTY(Int_TP->NTPMCL) .and. !EMPTY(Int_TP->NTPCLI))
   SA1->(DBSEEK(cFilSA1+Int_TP->NTPCLI+Int_TP->NTPLOJ))
   Int_TP->NTPPAI:=SA1->A1_PAIS
endif
//
If (Int_TP->NTPTIPO = INCLUSAO .and. !EX5->(dbSeek(cFilEX5+Int_TP->NTPPRO+Int_TP->NTPPAI+DtoS(IN100CTD(Int_TP->NTPFIM))+DtoS(IN100CTD(Int_TP->NTPINI))))) .and.; 
   (!EMPTY(Int_TP->NTPPPA) .AND. !EMPTY(Int_TP->NTPMPA) .and. !EMPTY(Int_TP->NTPPAI)) //Alcir Alves //Alcir Alves - 22-09-05
   If EX5->(dbSeek(cFilEX5+Int_TP->NTPPRO+Int_TP->NTPPAI)) .and. Empty(EX5->EX5_DTFIM)
      EX5->(RecLock("EX5",.F.))
      EX5->EX5_DTFIM := IN100CTD(Int_TP->NTPINI) - 1
      EX5->(msUnlock())
   EndIf
   IN100RecLock('EX5')
   EX5->EX5_FILIAL   := cFilEX5
   EX5->EX5_COD_I    := Int_TP->NTPPRO
   EX5->EX5_PAIS     := Int_TP->NTPPAI //Alcir Alves - 22-09-05
   EX5->EX5_MOEDA    := Int_TP->NTPMPA
   EX5->EX5_PRECO    := Val(Int_TP->NTPPPA)
   EX5->EX5_DTINI    := IN100CTD(Int_TP->NTPINI)
   EX5->EX5_DTFIM    := IN100CTD(Int_TP->NTPFIM)
   EX5->EX5_USU      := "INTEGRACAO"
   EX5->EX5_HORA     := Left(Time(),5)
   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"GRVTP_EX5")
   EndIf
   
   EX5->(msUnlock())
ElseiF (Int_TP->NTPTIPO = ALTERACAO .or. (Int_TP->NTPTIPO <> EXCLUSAO .and. EX5->(dbSeek(cFilEX5+Int_TP->NTPPRO+Int_TP->NTPPAI+DtoS(IN100CTD(Int_TP->NTPFIM))+DtoS(IN100CTD(Int_TP->NTPINI)))))) .and. ;
       (!EMPTY(Int_TP->NTPPPA) .AND. !EMPTY(Int_TP->NTPMPA) .and. !EMPTY(Int_TP->NTPPAI)) //Alcir Alves //Alcir Alves - 22-09-05
   If !EX5->(dbSeek(cFilEX5+Int_TP->NTPPRO+Int_TP->NTPPAI+DtoS(IN100CTD(Int_TP->NTPFIM))+DtoS(IN100CTD(Int_TP->NTPINI))))
      EX5->(dbSeek(cFilEX5+Int_TP->NTPPRO+Int_TP->NTPPAI))
      
      /*
      Do While !EX5->(EOF()) .and. IN100CTD(Int_TP->NTPINI) <> EX5->EX5_DTINI
         EX5->(dbSkip())
      EndDo
      If EX5->(EOF()) .or. IN100CTD(Int_TP->NTPINI) <> EX5->EX5_DTINI
         lAtu := .F.
      EndIf
      */

      While EX5->(!Eof() .and. EX5_FILIAL == cFilEX5 .and. EX5_COD_I == Int_TP->NTPPRO .and. EX5_PAIS == Int_TP->NTPPAI)

         If EX5->EX5_DTINI == IN100CTD(Int_TP->NTPINI)
            lIncTP := .F.
            Exit
         Else
            lIncTP := .T.
         EndIf

         EX5->(dbSkip())

      End

   EndIf

   If lAtu

      If lIncTP
         EX5->(RecLock("EX5", .T.))
         EX5->EX5_FILIAL := cFilEX5
         EX5->EX5_COD_I  := Int_TP->NTPPRO
         EX5->EX5_PAIS   := Int_TP->NTPPAI //Alcir Alves - 22-09-05
      Else
         EX5->(RecLock("EX5", .F.))
      EndIf

      //EX5->(RecLock("EX5",.F.))
      If(!Empty(Int_TP->NTPMPA),EX5->EX5_MOEDA := Int_TP->NTPMPA,)
      If(!Empty(Int_TP->NTPPPA),EX5->EX5_PRECO := Val(Int_TP->NTPPPA),)
      If(!Empty(Int_TP->NTPINI),EX5->EX5_DTINI := IN100CTD(Int_TP->NTPINI),)
      If(!Empty(Int_TP->NTPFIM),EX5->EX5_DTFIM := IN100CTD(Int_TP->NTPFIM),)
      EX5->EX5_USU      := "INTEGRACAO"
      EX5->EX5_HORA     := Left(Time(),5)

      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"GRVTP_EX5")
      EndIf

      EX5->(msUnlock())
   Endif
ElseIf Int_TP->NTPTIPO = EXCLUSAO
   IF (!EMPTY(Int_TP->NTPPR1) .AND. !EMPTY(Int_TP->NTPMCL) .and. !EMPTY(Int_TP->NTPCLI))  //Alcir Alves //Alcir Alves - 22-09-05
      EX6->(dbSeek(cFilEX6+Int_TP->NTPPRO+Int_TP->NTPPAI+Int_TP->NTPCLI+Int_TP->NTPLOJ))//HFD - 10.mar.2009 - Inclusão do campo loja
      Do While !EX6->(EOF()) .and. EX6->EX6_FILIAL==cFilEX6 .and. EX6->EX6_COD_I==Int_TP->NTPPRO .and.;
         EX6->EX6_PAIS==Int_TP->NTPPAI .and. EX6->EX6_CLIENT==Int_TP->NTPCLI
         EX6->(Reclock("EX6",.F.,.T.))
         If EasyEntryPoint("IN100CLI")
            ExecBlock("IN100CLI",.F.,.F.,"GRVTP_EX6")
         EndIf
         //Alcir Alves - 23-09-05 - rotina adaptada para exclusão do registro em aguardo
         ldelTP := .F.
         While EX6->(!Eof() .and. EX6_FILIAL == cFilEX6 .and. EX6_COD_I == Int_TP->NTPPRO .and. EX6_CLIENT == Int_TP->NTPCLI .and. EX6_CLLOJA == Int_TP->NTPLOJ)
            If EX6->EX6_DTINI == IN100CTD(Int_TP->NTPIN2)
               ldelTP := .T.
               Exit
            EndIf
            EX6->(dbSkip())
         End
         //
         IF ldelTP
            EX6->(DBDELETE())
            EX6->(MSUNLOCK())
            EX6->(dbSkip())
         ENDIF
      EndDo
      //Alcir Alves - 23-09-05 - remove dados com valores zerados no país caso não exista mais clientes para o mesmo.
      if !EX6->(dbSeek(cFilEX6+Int_TP->NTPPRO+Int_TP->NTPPAI))
          IF EX5->(dbSeek(cFilEX5+Int_TP->NTPPRO+Int_TP->NTPPAI))
             DO while EX5->EX5_FILIAL==cFilEX5 .AND. EX5->EX5_COD_I==Int_TP->NTPPRO .AND. EX5->EX5_PAIS==Int_TP->NTPPAI
                IF EX5->EX5_PRECO==0
                   EX5->(Reclock("EX5",.F.,.T.))
                   EX5->(DBDELETE())
                   EX5->(MSUNLOCK())
                ENDIF
                EX5->(dbskip())
             ENDDO
          ENDIF
      ENDIF
      //
   ENDIF
   
   IF (!EMPTY(Int_TP->NTPPPA) .AND. !EMPTY(Int_TP->NTPMPA) .and. !EMPTY(Int_TP->NTPPAI)) //Alcir Alves //Alcir Alves - 22-09-05 
      
      ldelTP := .F.      
      While EX5->(!Eof() .and. EX5_FILIAL == cFilEX5 .and. EX5_COD_I == Int_TP->NTPPRO .and. EX5_PAIS == Int_TP->NTPPAI)
         If EX5->EX5_DTINI == IN100CTD(Int_TP->NTPINI)
            ldelTP := .T.
            Exit
         EndIf
         EX5->(dbSkip())
      End
      IF ldelTP  //EX5->(dbSeek(cFilEX5+Int_TP->NTPPRO+Int_TP->NTPPAI+DtoS(IN100CTD(Int_TP->NTPFIM))+DtoS(IN100CTD(Int_TP->NTPINI))))
          EX5->(Reclock("EX5",.F.,.T.))
          EX5->(DBDELETE())
          EX5->(MSUNLOCK())
      ENDIF 
   ENDIF


EndIf

If (Int_TP->NTPTIP2 = INCLUSAO .and. !EX6->(dbSeek(cFilEX6+Int_TP->NTPPRO+Int_TP->NTPPAI+Int_TP->NTPCLI+Int_TP->NTPLOJ+DtoS(IN100CTD(Int_TP->NTPFI2))+DtoS(IN100CTD(Int_TP->NTPIN2))))) .and. ;//HFD - 10.mar.2009 - Inclusão do campo loja
   (!EMPTY(Int_TP->NTPPR1) .AND. !EMPTY(Int_TP->NTPMCL) .and. !EMPTY(Int_TP->NTPCLI))  //Alcir Alves //Alcir Alves - 22-09-05
   If !Empty(Int_TP->NTPCLI)
      If EX6->(dbSeek(cFilEX6+Int_TP->NTPPRO+Int_TP->NTPPAI+Int_TP->NTPCLI+Int_TP->NTPLOJ)) .and. Empty(EX6->EX6_DTFIM)
         EX6->(RecLock("EX6",.F.))
         EX6->EX6_DTFIM := IN100CTD(Int_TP->NTPIN2) - 1
         EX6->(msUnlock())
      EndIf
      IN100RecLock('EX6')
      EX6->EX6_FILIAL   := cFilEX6
      EX6->EX6_COD_I    := Int_TP->NTPPRO
      EX6->EX6_CLIENT   := Int_TP->NTPCLI
      EX6->EX6_PAIS     := Int_TP->NTPPAI //Alcir Alves - 22-09-05
      EX6->EX6_CLLOJA   := Int_TP->NTPLOJ
      EX6->EX6_MOEDA    := Int_TP->NTPMCL
      EX6->EX6_PRECO    := Val(Int_TP->NTPPR1)
      EX6->EX6_DTINI    := IN100CTD(Int_TP->NTPIN2)
      EX6->EX6_DTFIM    := IN100CTD(Int_TP->NTPFI2)
      EX6->EX6_USU      := "INTEGRACAO"
      EX6->EX6_HORA     := Left(Time(),5)
      If EasyEntryPoint("IN100CLI")
         ExecBlock("IN100CLI",.F.,.F.,"GRVTP_EX6")
      EndIf
      EX6->(msUnlock())
      //Alcir Alves - 22-09-05 
      //força a gravação de um registro de pais caso o mesmo não exista
      //apenas para manter o link de relacionamento entre país/cliente na tabela de preços 
      IF  !EX5->(dbSeek(cFilEX5+Int_TP->NTPPRO+Int_TP->NTPPAI))
          IN100RecLock('EX5')
          EX5->EX5_FILIAL   := cFilEX5
          EX5->EX5_COD_I    := Int_TP->NTPPRO
          EX5->EX5_PAIS     := Int_TP->NTPPAI 
          EX5->EX5_MOEDA    := Int_TP->NTPMCL
          EX5->EX5_PRECO    := 0 
          EX5->EX5_USU      := "INTEGRACAO"
          EX5->EX5_HORA     := Left(Time(),5)
          EX5->(msUnlock())
      endif
      //
   EndIf
ElseIf (Int_TP->NTPTIP2 = ALTERACAO .or. (Int_TP->NTPTIP2 <> EXCLUSAO .and. EX6->(dbSeek(cFilEX6+Int_TP->NTPPRO+Int_TP->NTPPAI+Int_TP->NTPCLI+Int_TP->NTPLOJ+DtoS(IN100CTD(Int_TP->NTPFI2))+DtoS(IN100CTD(Int_TP->NTPIN2)))))) .and. ;//HFD - 10.mar.2009 - Inclusão do campo loja
       (!EMPTY(Int_TP->NTPPR1) .AND. !EMPTY(Int_TP->NTPMCL) .and. !EMPTY(Int_TP->NTPCLI))  //Alcir Alves //Alcir Alves - 22-09-05
   If !Empty(Int_TP->NTPCLI)
      If !EX6->(dbSeek(cFilEX6+Int_TP->NTPPRO+Int_TP->NTPPAI+Int_TP->NTPCLI+Int_TP->NTPLOJ+DtoS(IN100CTD(Int_TP->NTPFI2))+DtoS(IN100CTD(Int_TP->NTPIN2))))
         EX6->(dbSeek(cFilEX6+Int_TP->NTPPRO+Int_TP->NTPPAI+Int_TP->NTPCLI+Int_TP->NTPLOJ))
         /*
         Do While !EX6->(EOF()) .and. IN100CTD(Int_TP->NTPIN2) <> EX6->EX6_DTINI
            EX6->(dbSkip())
         EndDo
         */
         lIncTP := .T.
         lAtu   := .T.
         While EX6->(!Eof() .and. EX6_FILIAL == cFilEX6 .and. EX6_COD_I == Int_TP->NTPPRO .and. EX6_CLIENT == Int_TP->NTPCLI .and. EX6_CLLOJA == Int_TP->NTPLOJ)
            If EX6->EX6_DTINI == IN100CTD(Int_TP->NTPIN2)
               lIncTP := .F.
               Exit
            EndIf
            EX6->(dbSkip())
         End
      EndIf
      If lAtu

         If lIncTP
            EX6->(RecLock("EX6", .T.))
            EX6->EX6_FILIAL := cFilEX6
            EX6->EX6_COD_I  := Int_TP->NTPPRO
            EX6->EX6_PAIS     := Int_TP->NTPPAI //Alcir Alves - 22-09-05
            EX6->EX6_CLIENT := Int_TP->NTPCLI
            EX6->EX6_CLLOJA := Int_TP->NTPLOJ
            EX6->EX6_MOEDA  := Int_TP->NTPMCL
         Else
            EX6->(RecLock("EX6", .F.))
         EndIf

         //EX6->(RecLock("EX6",.F.))
         If(!Empty(Int_TP->NTPPR1),EX6->EX6_PRECO := Val(Int_TP->NTPPR1),)
         If(!Empty(Int_TP->NTPIN2),EX6->EX6_DTINI := IN100CTD(Int_TP->NTPIN2),)
         If(!Empty(Int_TP->NTPFI2),EX6->EX6_DTFIM := IN100CTD(Int_TP->NTPFI2),)
         EX6->EX6_USU      := "INTEGRACAO"
         EX6->EX6_HORA     := Left(Time(),5)

         If EasyEntryPoint("IN100CLI")
            ExecBlock("IN100CLI",.F.,.F.,"GRVTP_EX6")
         EndIf
         
         EX6->(msUnlock())
      Endif
   EndIf
EndIf

/*
//LOCALIZA REGISTROS
EX5->(DBSETORDER(1))
lAchouEX5 := EX5->(DBSEEK(cFilEX5+Int_TP->NTPPRO+Int_TP->NTPPAI))
if !empty(Int_TP->NTPCLI)
   EX6->(DBSETORDER(1))
   lAchouEX6:=EX6->(DBSEEK(cFilEX6+Int_TP->NTPPRO+Int_TP->NTPPAI+Int_TP->NTPCLI+Int_TP->NTPLOJ))
else
   lAchouEX6:=.F.
endif

//EX5
IF Int_TP->NTPTIPO # INCLUSAO
   IF !lAchouEX5 .AND. Int_TP->NTPTIPO == ALTERACAO
      Int_TP->NTPTIPO := INCLUSAO
   ENDIF
   IF Int_TP->NTPTIPO # INCLUSAO
      cAlias:=ALIAS()
      Reclock("EX5",.F.)
      DBSELECTAREA(cAlias)
      IF Int_TP->NTPTIPO = EXCLUSAO
         EX5->(DBDELETE())
         EX5->(DBCOMMIT())
         EX5->(MSUNLOCK())
      ENDIF
   ENDIF
ENDIF
IF Int_TP->NTPTIPO # EXCLUSAO 
   IF Int_TP->NTPTIPO = INCLUSAO .AND. !lAchouEX5  //INCLUSÃO
      IN100RecLock('EX5')
      EX5->EX5_FILIAL   := cFilEX5
      EX5->EX5_COD_I    := Int_TP->NTPPRO
      EX5->EX5_PAIS     := Int_TP->NTPPAI
   ELSEif Int_TP->NTPTIPO # ALTERACAO 
      DBSELECTAREA("EX5")
 	  Reclock("EX5",.F.)
   ENDIF
   EX5->EX5_MOEDA := Int_TP->NTPMPA
   EX5->EX5_PRECO := VAL(Int_TP->NTPPPA)
   If lSX3EX5_DTINI
      EX5->EX5_DTINI := IN100CTD(Int_TP->NTPINI)
   EndIf
   If lSX3EX5_DTFIM
      EX5->EX5_DTFIM := IN100CTD(Int_TP->NTPFIM)
   EndIf
   EX5->EX5_USU   := "INTEGRACAO"
   EX5->EX5_HORA  := Left(Time(),5)
   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"GRVTP_EX5")
   EndIf
   EX5->(MSUNLOCK())
ENDIF


//EX6
IF Int_TP->NTPTIPO # INCLUSAO .and. lAchouEX6==.T.
   cAlias:=ALIAS()
   Reclock("EX6",.F.)
   DBSELECTAREA(cAlias)
   IF Int_TP->NTPTIPO == EXCLUSAO .AND. !empty(Int_TP->NTPCLI) .AND. lAchouEX6==.T.
      EX6->(DBDELETE())
      EX6->(DBCOMMIT())
      EX6->(MSUNLOCK())
      RETURN
   ENDIF
ENDIF
IF !empty(Int_TP->NTPCLI) 
   IF lAchouEX5==.T. .AND. Int_TP->NTPTIPO == ALTERACAO
      Int_TP->NTPTIPO := INCLUSAO
   ENDIF
   IF Int_TP->NTPTIPO == INCLUSAO .AND. !lAchouEX6 //INCLUSÃO
      IN100RecLock('EX6')
      EX6->EX6_FILIAL   := cFilEX5
      EX6->EX6_COD_I    := Int_TP->NTPPRO
      EX6->EX6_PAIS     := Int_TP->NTPPAI
      EX6->EX6_CLIENT   := Int_TP->NTPCLI
	  EX6->EX6_CLLOJA   := Int_TP->NTPLOJ
   ELSEif Int_TP->NTPTIPO # ALTERACAO 
   	  Int_TP->NTPTIPO := ALTERACAO
	  DBSELECTAREA("EX6")
	  Reclock("EX6",.F.)
   ENDIF
   EX6->EX6_MOEDA := Int_TP->NTPMCL
   EX6->EX6_PRECO := VAL(Int_TP->NTPPR1)
   If lSX3EX6_DTINI
      EX6->EX6_DTINI := IN100CTD(Int_TP->NTPIN2)
   EndIf
   If lSX3EX6_DTFIM
      EX6->EX6_DTFIM := IN100CTD(Int_TP->NTPFI2)
   EndIf
   EX6->EX6_USU   := "INTEGRACAO"
   EX6->EX6_HORA  := Left(Time(),5)
  
   If EasyEntryPoint("IN100CLI")
      ExecBlock("IN100CLI",.F.,.F.,"GRVTP_EX6")
   EndIf
   
ENDIF
EX6->(MSUNLOCK())*/

Return   //ALCIR - 26-07-04 //ALCIR - 26-07-04

*--------------------------------------------------------------------
FUNCTION IN100Memo(cTexto,cCpoMemo)
*--------------------------------------------------------------------
Local cRet := ""
Local nTam := 0, i

Begin Sequence
   nTam := AVSX3(cCpoMemo,AV_TAMANHO)
   
   For i:=1 To MlCount(cTexto,nTam)      
      IF i > 1
         cRet += ENTER
      Endif
      
      cRet += Rtrim(MemoLine(cTexto,nTam,i))
   Next i

End Sequence

Return cRet

/*
Funcao      : EE7IniPad
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Preencher o conteúdo dos campos de acordo com o inializador padrão.
              Aplicável aos campos não preenchidos pela integração (arquivo Int_PE).
Autor       : Wilsimar Fabrício da Silva
Data/Hora   : 11/11/2008
Revisao     : 
Obs.        :
*/

Static Function EE7IniPad()

//EE7_DECPES, EE7_DECQTD e EE7_DECPRC são campos numéricos

If EE7->EE7_DECPES == 0
   //Carrega o inicializador padrão
   EE7->EE7_DECPES := CriaVar("EE7_DECPES")
EndIf
If EE7->EE7_DECQTD == 0
   //Carrega o inicializador padrão
   EE7->EE7_DECQTD := CriaVar("EE7_DECQTD")
EndIf
If EE7->EE7_DECPRC == 0
   //Carrega o inicializador padrão
   EE7->EE7_DECPRC := CriaVar("EE7_DECPRC")
EndIf

Return Nil
