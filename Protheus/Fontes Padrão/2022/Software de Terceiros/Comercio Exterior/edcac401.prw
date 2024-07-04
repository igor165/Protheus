// ************************************************************************// 
// Programa....: EECAC401.PRW - v811 - Release 4
// Programador.: Alessandro Alves Ferreira - AAF
// Data........: 16 de Agosto de 2006
// Objetivo....: Continuação do EDCAC400 - Manutenção de Ato Concessório
//*************************************************************************//
#Include "Average.ch"
#Include "EDCAC401.CH"              


#Define ALL_REG .T.

#Define LIMITE_LOCKS 10000 //AAF 03/12/2008 - Limite de Locks do Protheus. Se travar mais registros da error.log (Number of locks exceeded - Total: 10000)

#Define CAMPOS_ADITIVO { {"ED3_QTDNCM"          ,                                                     ,"Campo 6(Quantidade) do Anexo ao Pedido de DrawBack n. (#ED3_ANEXO#) - exportados : U.M. (#ED3_UMNCM#) - (#ED3_QTDNCM#) ((#ED3_PROD#))"                    },;
                         {"ED4_QTDNCM"          ,                                                     ,"Campo 6(Quantidade) do Anexo ao Pedido de DrawBack n. (#ED4_ANEXO#) - por importar : U.M. (#ED4_UMNCM#) - (#ED4_QTDNCM#) ((#ED4_ITEM#))"                  },;
                         {"PRECOEXP"            ,"Round(ED3_VAL_EM*(1-(ED3_PERCAG/100)/ED3_QTDNCM),2)","Campo 9(Preço no local de embarque - Unitário) do Anexo ao Pedido de DrawBack n. (#ED3_ANEXO#) - exportados : US$ (#VALOR#) ((#ED3_PROD#))"               },;
                         {"PRECOIMP"            ,"Round(ED4_VALEMB/ED4_QTDNCM,2)"                     ,"Campo 9(Preço no local de embarque - Unitário) do Anexo ao Pedido de DrawBack n. (#ED4_ANEXO#) - por importar: US$ (#VALOR#) ((#ED4_ITEM#))"              },;
                         {"ED3_PESO"            ,                                                     ,"Campo 5(Peso líquido) do Anexo ao Pedido de DrawBack n. (#ED3_ANEXO#) - exportados : K.G. (#VALOR#) ((#ED3_PROD#))"                                       },;
                         {"ED4_PESO"            ,                                                     ,"Campo 5(Peso líquido) do Anexo ao Pedido de DrawBack n. (#ED4_ANEXO#) - por importar : K.G. (#VALOR#) ((#ED4_ITEM#))"                                     },;
                         {"ED4_VALEMB"          ,                                                     ,"Campo 10(Preço no local de embarque - Total) do Anexo ao Pedido de DrawBack n. (#ED4_ANEXO#) - por importar : US$ (#VALOR#) ((#ED4_ITEM#))"               },;
                         {"ED3_VAL_EM"          ,                                                     ,"Campo 10(Preço no local de embarque - Total) do Anexo ao Pedido de DrawBack n. (#ED3_ANEXO#) - exportados : US$ (#VALOR#) ((#ED3_PROD#))"                 },;
                         {"ED4_NCM"             ,                                                     ,"Campo 4(Item da tarifa) do Anexo ao Pedido de DrawBack n. (#ED4_ANEXO#) - por importar : NCM (#VALOR#) ((#ED4_ITEM#))"                                    },;
                         {"ED3_NCM"             ,                                                     ,"Campo 4(Item da tarifa) do Anexo ao Pedido de DrawBack n. (#ED3_ANEXO#) - exportados : NCM (#VALOR#) ((#ED3_PROD#))"                                      },;
                         {"TOT_PESO_IMP_PD"     ,"ED4_PESO"                                           ,"Campo 13(Total) do Pedido de Drawback - K.G. (#VALOR#)"                                                                                                   },;
                         {"TOT_PESO_ANEIMP_PG"  ,"ED4_PESO"                                           ,"Campo 11(Total) do Anexo ao Pedido de Drawback n. (#ED4_ANEXO#) - por importar: K.G. (#VALOR#) ((#ED4_ITEM#))"                                            },;
                         {"TOT_QTD_IMP_PD"      ,"ED4_QTDNCM"                                         ,"Campo 14(Total) do Pedido de Drawback - (#VALOR#)"                                                                                                        },;
                         {"TOT_QTD_ANEIMP_PG"   ,"ED4_QTDNCM"                                         ,"Campo 12(Total) do Anexo ao Pedido de Drawback n. (#ED4_ANEXO#) - por importar: (#VALOR#) ((#ED4_ITEM#))"                                                 },;
                         {"TOT_VAL_IMP_PD"      ,"ED4_VALEMB"                                         ,"Campo 12(Total) do Pedido de Drawback - US$ (#VALOR#)"                                                                                                    },;
                         {"TOT_VALEMB_IMP_PD"   ,"ED4_VALEMB"                                         ,"Campo 15(Valor total no local de embarque) do Pedido de Drawback - US$ (#VALOR#)"                                                                         },;
                         {"TOT_VALEMBEXT_IMP_PD","ED4_VALEMB"                                         ,"Campo 16(Valor total no local de embarque por extenso) do Pedido de Drawback - (#VALOR#)"                                                                 },;
                         {"TOT_VALEMB_ANEIMP_PG","ED4_VALEMB"                                         ,"Campo 13(Valor total no local de embarque equivalente a US$) do Anexo ao Pedido de Drawback n. (#ED4_ANEXO#) - por importar: US$ (#VALOR#) ((#ED4_ITEM#))"},;
                         {"TOT_PESO_EXP_PD"     ,"ED3_PESO"                                           ,"Campo 25(Total) do Pedido de Drawback - K.G. (#VALOR#)"                                                                                                   },;
                         {"TOT_PESO_ANEEXP_PG"  ,"ED3_PESO"                                           ,"Campo 11(Total) do Anexo ao Pedido de DrawBack n. (#ED3_ANEXO#) - exportados : K.G. (#VALOR#) ((#ED3_PROD#))"                                             },;
                         {"TOT_QTD_EXP_PD"      ,"ED3_QTDNCM"                                         ,"Campo 26(Total) do Pedido de Drawback - (#VALOR#)"                                                                                                        },;
                         {"TOT_QTD_ANEEXP_PG"   ,"ED3_QTDNCM"                                         ,"Campo 12(Total) do Anexo ao Pedido de Drawback n. (#ED3_ANEXO#) - exportados : (#VALOR#) ((#ED3_PROD#))"                                                  },;
                         {"TOT_VAL_EXP_PD"      ,"ED3_VAL_EM"                                         ,"Campo 24(Total) do Pedido de Drawback - US$ (#VALOR#)"                                                                                                    },;
                         {"TOT_VALEMB_EXP_PD"   ,"ED3_VAL_EM"                                         ,"Campo 27(Valor total no local de embarque) do Pedido de Drawback - US$ (#VALOR#)"                                                                         },;
                         {"TOT_VALEMBEXT_EXP_PD","ED3_VAL_EM"                                         ,"Campo 28(Valor total no local de embarque por extenso) do Pedido de Drawback - (#VALOR#)"                                                                 },;
                         {"TOT_VALEMB_ANEEXP_PG","ED3_VAL_EM"                                         ,"Campo 13(Valor total no local de embarque equivalente a US$) do Anexo ao Pedido de Drawback n. (#ED3_ANEXO#) - exportados : US$ (#VALOR#) ((#ED3_PROD#))" } }

//*************************************************************************************************************//
// Autor:    PLB - Pedro Baroni
// Data:     23/11/06
// Class:    EDCMultiUser
// Objetivo: Bloqueio de Registros para controle Multi-Usuário no SIGAEDC.
//*************************************************************************************************************//
Function EDCMultiUser()
If !AvFlags("INDICEED9")
   Return .F.
EndIf
Return EDCMultiUser():Novo()

Function EDCAditivo()
If !AvFlags("INDICEED9")
   Return .F.
EndIf
Return EDCAditivo():New() //Return EDCEDCAditivo():New() - BAK - 30/11/2011

Class EDCMultiUser
   
   Data ED0
   Data ED3
   Data ED4
   Data EDD
   Data SW8
   Data SW6
   Data ED8
   Data EE9
   Data ED9 // igor chiba 07/04/09
   Data EEC
   
   Method Novo()
   Method Reserva(cFunction,cAction)
   Method Solta(cFunction,cAction)
   Method Fim()
   
EndClass
                  
//*************************************************************************************************************//
// Autor:    PLB - Pedro Baroni
// Data:     23/11/06
// Class:    EDCTable
// Objetivo: Tabelas que terão seus Registros bloqueados - Classe pertencente ao EDCMultiUser.
//*************************************************************************************************************//
Class EDCTable

   Data cAlias
   Data nOrd
   Data oPai
   Data aLock
   Data nLocks //AAF 03/12/2008 - Numero de registros travados, devido a limitação do Protheus.

   Method Novo(cAlias,nOrd,oPai)
   Method Trava(oLock,lAll,lSoft)
   Method Destrava(oLock,lAll)
   Method Atualiza()
   Method BuscaPai(oLock)
   Method BuscaLock(oLock)
   Method FilhoUnico(oLock)

EndClass

//*************************************************************************************************************//
// Autor:    PLB - Pedro Baroni
// Data:     23/11/06
// Class:    EDCLock
// Objetivo: Chave de Registro(s) bloqueado(s) nas tabelas do objeto EDCTable.
//*************************************************************************************************************//
Class EDCLock

   Data cChave
	
   Method Novo(cChave)

EndClass

//*************************************************************************************************************//
// Autor:    AAF - Alessandro Alves Ferreira
// Data:     18/04/08
// Class:    EDCAditivo
// Objetivo: Geração dos aditivos em drawback isenção
//*************************************************************************************************************//
Class EDCAditivo
   
   Data Filial
   Data Pedido
   Data TablesOld
   Data TablesNew
   Data FieldChanged
   
   Method New(Filial,Pedido,TablesOld,TablesNew)
   Method ChangeCheck()
   Method TotVal(cAlias, cCampo, nReg)
   Method GeraAditivos()
   
EndClass

//*************************************************************************************************************//
// Autor:    PLB - Pedro Baroni
// Data:     23/11/06
// Classe:   EDCMultiUser
// Método:   Novo()
// Objetivo: Criar um objeto EDCMultiUser.
// Retorno:  Tipo   -> Objeto
//           Descr. -> Novo objeto
//*************************************************************************************************************//
Method Novo() Class EDCMultiUser

   ::ED0 := EDCTable():Novo("ED0",1)
   ::ED3 := EDCTable():Novo("ED3",1)
   ::ED4 := EDCTable():Novo("ED4",1)
   ::EDD := EDCTable():Novo("EDD",1)
   ::SW6 := EDCTable():Novo("SW6",1)
   ::SW8 := EDCTable():Novo("SW8",6,@::SW6)
   ::ED8 := EDCTable():Novo("ED8",4)
   ::EEC := EDCTable():Novo("EEC",1)
   ::EE9 := EDCTable():Novo("EE9",2,@::EEC)
   ::ED9 := EDCTable():Novo("ED9",1)

Return

//*************************************************************************************************************//
// Autor:      PLB - Pedro Baroni
// Data:       23/11/06
// Classe:     EDCMultiUser
// Método:     Reserva(cFunction,cAction)
// Parametros: cFunction -> Local de onde foi efetuada a chamada de reserva de registros.
//             cAction   -> Ação executada no local da chamada.
// Objetivo:   Reservar os registros necessarios de acordo com a ação e o local da chamada.
// Retorno:    Tipo   -> Lógico
//             Descr. -> Identifica se foi possivel reservar todos os registros necessarios.
//*************************************************************************************************************//
Method Reserva(cFunction,cAction) Class EDCMultiUser

 Local lRet   := .T.
 Local aOrd   := {}
 Local cAlias := ""
 Local cFilED3 := xFilial("ED3")
 Local cFilED4 := xFilial("ED4")
 Local cFilED8 := xFilial("ED8")
 Local cFilEDD := xFilial("EDD")
 Local cFilEE9 := xFilial("EE9")
 Local cFilED9 := xFilial("ED9") 
 Local cFilSW8 := xFilial("SW8")
 Local cFilSW5 := xFilial("SW5")
 //Local lDiExt  := EasyGParam("MV_EDCDIE",,.F.)   // Utilizacao da rotina de Manutencao de DI's Externas  - NOPADO POR - AOM - 04/11/10
 Local cAntImp := EasyGParam("MV_ANT_IMP",,"1")  // Local da Anterioridade de Drawback na Importacao
 Local lTemEDD := .F.
 Local cFilAux := ""
 Private lMultiFil := .F.

   aOrd := SaveOrd({"ED3","ED4","ED8","EDD","EE9","ED9","SW8","SW5","SX3"})

   SX3->( DBSetOrder(2) )
   lTemEDD := SX3->( DBSeek("EDD_FILIAL") )

   //** PLB 21/06/07 - Tratamento Multi-Filial para Drawback
   lMultiFil  := VerSenha(115)  ;
                 .And.  Posicione("SX2",1,"ED1","X2_MODO") == "C" ;
                 .And.  Posicione("SX2",1,"ED2","X2_MODO") == "C" ;
                 .And.  Posicione("SX2",1,"EDD","X2_MODO") == "C" ;
                 .And.  Posicione("SX2",1,"EE9","X2_MODO") == "E" ;
                 .And.  Posicione("SX2",1,"SW8","X2_MODO") == "E" ;
                 .And.  ED1->( FieldPos("ED1_FILORI") ) > 0  ;
                 .And.  ED2->( FieldPos("ED2_FILORI") ) > 0  ;
                 .And.  EDD->( FieldPos("EDD_FILEXP") ) > 0  ;
                 .And.  EDD->( FieldPos("EDD_FILIMP") ) > 0
   //**  
 
   Begin Sequence
   
      Do Case

         Case cFunction == "ATO"

            If cAction == "ALT/EXC"

               oLockED0 := EDCLock():Novo( (::ED0:cAlias)->&(IndexKey(::ED0:nOrd)) )
               Processa({||lRet:=::ED0:Trava(oLockED0)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
               If !lRet
                  Break
               EndIf

               oLockED3 := EDCLock():Novo(cFilED3+ED0->ED0_PD)
               Processa({||lRet:=::ED3:Trava(oLockED3,ALL_REG)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
               If !lRet
                  ::ED0:Destrava(oLockED0)
                  Break
               EndIf

               oLockED4 := EDCLock():Novo(cFilED4+ED0->ED0_PD)
               Processa({||lRet:=::ED4:Trava(oLockED4,ALL_REG)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
               If !lRet
                  ::ED0:Destrava(oLockED0)
                  ::ED3:Destrava(oLockED3,ALL_REG)
                  Break
               EndIf



            ElseIf cAction == "INC_ITEM"

               If lMultiFil
                  cFilAux := M->ED2_FILORI
               Else
                  cFilAux := cFilSW8
               EndIf
               oLockSW8 := EDCLock():Novo(cFilAux+M->ED2_HAWB+M->ED2_INVOIC+M->ED2_PO_NUM+M->ED2_POSICA+M->ED2_PGI_NU)
               Processa({||lRet:=::SW8:Trava(oLockSW8)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
               If !lRet
                  Break
               EndIf

               If ChkFile("ED8",.F.) // lDiExt .And. - NOPADO POR AOM - 04/11/10
                  oLockED8 := EDCLock():Novo(cFilED8+M->ED2_DI_NUM+M->ED2_ADICAO+M->ED2_POSICA)
                  Processa({||lRet:=::ED8:Trava(oLockED8)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                  If !lRet
                     Break
                  EndIf
               EndIf

            ElseIf cAction == "ALT/EXC_ITEM"  .Or.  cAction == "MARCA_DI"

               If cAction == "ALT/EXC_ITEM"
                  cAlias := "WorkED2"
               ElseIf cAction == "MARCA_DI"
                  cAlias := "WorkDI"
               EndIf

               If lMultiFil
                  cFilAux := Left((cAlias)->ED2_FILORI,2)
               Else
                  cFilAux := cFilSW8
               EndIf
               
               oLockSW8 := EDCLock():Novo(cFilAux+(cAlias)->ED2_HAWB+(cAlias)->ED2_INVOIC+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU)
               Processa({||lRet:=::SW8:Trava(oLockSW8)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
               If !lRet
                  Break
               EndIf

               If ChkFile("ED8",.F.) // NOPADO POR - AOM 04/11/10
                  oLockED8 := EDCLock():Novo(cFilED8+(cAlias)->ED2_DI_NUM+(cAlias)->ED2_ADICAO+(cAlias)->ED2_POSICA)
                  Processa({||lRet:=::ED8:Trava(oLockED8)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                  If !lRet
                     Break
                  EndIf
               EndIf

            ElseIf cAction == "PRODUTO"  .Or.  cAction == "MARCA_RE"

               If cAction == "PRODUTO"
                  cAlias := "WorkED1"
               ElseIf cAction == "MARCA_RE"
                  cAlias := "WorkRE"
               EndIf

               If lMultiFil
                  cFilAux := Left((cAlias)->ED1_FILORI,2)
               Else
                  cFilAux := cFilEE9
               EndIf

               // Igor Chiba 07/04/2009
               IF EMPTY(ED1->ED1_PREEMB)
                  cFilAux := cFilED9
                  oLockED9 := EDCLock():Novo(cFilAux+(cAlias)->ED1_PREEMB+(cAlias)->ED1_PEDIDO+(cAlias)->ED1_SEQUEN)
                  Processa({||lRet:=::ED9:Trava(oLockED9)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
               ELSE
               // FIM Igor Chiba 07/04/2009
                  oLockEE9 := EDCLock():Novo(cFilAux+(cAlias)->ED1_PREEMB+(cAlias)->ED1_PEDIDO+(cAlias)->ED1_SEQUEN)
                  Processa({||lRet:=::EE9:Trava(oLockEE9)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
               ENDIF
               
               If !lRet
                  Break
               EndIf

            EndIf   


         Case cFunction == "DI_EXT"

            If cAction == "ALT/EXC"

               oLockED8 := EDCLock():Novo( (::ED8:cAlias)->&(IndexKey(::ED8:nOrd)) )
               Processa({||lRet:=::ED8:Trava(oLockED8)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
               If !lRet
                  Break
               EndIf
               
            ElseIf cAction == "COMPROVA"

               oLockED8 := EDCLock():Novo( (::ED8:cAlias)->&(IndexKey(::ED8:nOrd)) )
               Processa({||lRet:=::ED8:Trava(oLockED8)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
               If !lRet
                  Break
               EndIf

               ED4->( DBSetOrder(2) )
               If ED4->( DBSeek(cFilED4+ED8->ED8_AC+ED8->ED8_SEQSIS) )
                  oLockED4 := EDCLock():Novo( (::ED4:cAlias)->&(IndexKey(::ED4:nOrd)) )
                  Processa({||lRet:=::ED4:Trava(oLockED4)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                  If !lRet
                     Break
                  EndIf
               EndIf

            ElseIf cAction == "GRV_COMPROVA"

               ED4->( DBSetOrder(2) )
               If ED4->( DBSeek(cFilED4+M->ED8_AC+M->ED8_SEQSIS) )
                  oLockED4 := EDCLock():Novo( (::ED4:cAlias)->&(IndexKey(::ED4:nOrd)) )
                  Processa({||lRet:=::ED4:Trava(oLockED4)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                  If !lRet
                     Break
                  EndIf
               EndIf

            EndIf


         Case cFunction == "COMPROVA_EXT"

            If cAction == "MANUTENCAO"
               
               //29.mai.2009 - 719548 - Travar também a comprovação externa - HFD
               oLockED0 := EDCLock():Novo( (::ED0:cAlias)->&(IndexKey(::ED0:nOrd)) )
               Processa({||lRet:=::ED0:Trava(oLockED0)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
               If !lRet
                  Break
               EndIf
               
               ED8->( DBSetOrder(3) )
               If ED8->( DBSeek(cFilED8+ED0->ED0_AC) )
                  Do While ED8->( !EoF()  .And.  ED8_FILIAL+ED8_AC == cFilED8+ED0->ED0_AC )
                     oLockED8 := EDCLock():Novo( (::ED8:cAlias)->&(IndexKey(::ED8:nOrd)) )
                     Processa({||lRet:=::ED8:Trava(oLockED8)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                     If !lRet
                        Break
                     EndIf
                     ED8->( DBSkip() )
                  EndDo
               EndIf
               
            ElseIf cAction == "INC_DI"

               ED4->( DBSetOrder(2) )
               If ED4->( DBSeek(cFilED4+M->ED8_AC+M->ED8_SEQSIS) )
                  oLockED4 := EDCLock():Novo( (::ED4:cAlias)->&(IndexKey(::ED4:nOrd)) )
                  Processa({||lRet:=::ED4:Trava(oLockED4)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                  If !lRet
                     Break
                  EndIf
               EndIf

            ElseIf cAction == "ALT/EXC_DI"

               ED4->( DBSetOrder(2) )
               If ED4->( DBSeek(cFilED4+WorkED8->ED8_AC+WorkED8->ED8_SEQSIS) )
                  oLockED4 := EDCLock():Novo( (::ED4:cAlias)->&(IndexKey(::ED4:nOrd)) )
                  Processa({||lRet:=::ED4:Trava(oLockED4)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                  If !lRet
                     Break
                  EndIf
               EndIf

            EndIf

         Case cFunction == "PLI"

            If cAction == "ESTORNA"
            
               If lMultiFil
                  cFilAux := SW4->W4_FILIAL
               Else
                  cFilAux := cFilSW5
               EndIf

               SW5->( DBSetOrder(1) )
               ED4->( DBSetOrder(2) )
               SW5->( DBSeek(cFilAux+SW4->W4_PGI_NUM) )
               Do While SW5->( !EoF()  .And.  W5_FILIAL+W5_PGI_NUM == cFilAux+SW4->W4_PGI_NUM )
                  If !Empty(SW5->W5_AC)  .And.  ED4->( DBSeek(cFilED4+SW5->W5_AC+SW5->W5_SEQSIS) )
                     oLockED4 := EDCLock():Novo( (::ED4:cAlias)->&(IndexKey(::ED4:nOrd)) )
                     Processa({||lRet:=::ED4:Trava(oLockED4)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                     If !lRet
                        ::Fim()
                        Break
                     EndIf
                  EndIf
                  SW5->( DBSkip() )
               EndDo

            ElseIf cAction == "ALT_ATO_1"  .Or.  cAction == "ALT_ATO_2"  .Or.  cAction == "ALT_ATO_3"

               If cAction == "ALT_ATO_1"  .Or.  cAction == "ALT_ATO_2"
                  oLockED4New := EDCLock():Novo( (::ED4:cAlias)->&(IndexKey(::ED4:nOrd)) )
                  Processa({||lRet:=::ED4:Trava(oLockED4New)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                  If !lRet
                     Break
                  EndIf
               EndIf

               If cAction == "ALT_ATO_1"  .Or.  cAction == "ALT_ATO_3"
                  ED4->( DBSetOrder(2) )
                  If ED4->( DBSeek(cFilED4+Work->WKAC+Work->WKSEQSIS) )
                     oLockED4Old := EDCLock():Novo( (::ED4:cAlias)->&(IndexKey(::ED4:nOrd)) )
                     Processa({||lRet:=::ED4:Trava(oLockED4Old)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                     If !lRet
                        If cAction == "ALT_ATO_1"
                           ::ED4:Destrava(oLockED4New)
                        EndIf
                        Break
                     EndIf
                  EndIf
               EndIf

            EndIf

         Case cFunction == "DI"

            If cAction == "ALTERA"
            
               ED4->( DBSetOrder(2) )
               EDD->( DBSetOrder(1) )
               If Select("Work") > 0  .And.  Work->(EasyRecCount() ) > 0
                  nRec := Work->( RecNo() )
                  Work->( DBGoTop() )
                  oED4Aux := ::ED4
                  oEDDAux := ::EDD
                  ::ED4 := EDCTable():Novo("ED4",1)
                  ::EDD := EDCTable():Novo("EDD",1)
                  Do While Work->( !EoF() )
                     If !Empty(Work->WKAC)
                        If ED4->( DBSeek(cFilED4+Work->WKAC+Work->WKSEQSIS) )
                           oLockED4 := EDCLock():Novo( (::ED4:cAlias)->&(IndexKey(::ED4:nOrd)) )
                           Processa({||lRet:=::ED4:Trava(oLockED4)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                           If !lRet
                              Exit
                           EndIf
                        EndIf
                        If cAntImp == "2"  .And.  EDD->( DBSeek(cFilEDD+Work->WKAC) )
                           oLockEDD := EDCLock():Novo( EDD->(EDD_FILIAL+EDD_AC) )
                           Processa({||lRet:=::EDD:Trava(oLockEDD,ALL_REG)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                           If !lRet
                              Exit
                           EndIf
                        EndIf
                     EndIf
                     Work->( DBSkip() )
                  EndDo
                  If !lRet
                     ::Solta("DI","ALTERA")
                     ::ED4 := oED4Aux
                     ::ED4:Atualiza()
                     ::EDD := oEDDAux
                     ::EDD:Atualiza()
                     Break
                  EndIf
                  Work->( DBGoTo(nRec) )
               ElseIf nOPC_mBrw == 4  // Alteração
                  If lMultiFil
                     cFilAux := cFilAnt
                  Else
                     cFilAux := cFilSW8
                  EndIf
                  SW8->( DBSetOrder(3) )
                  SW8->( DBSeek(cFilAux+SW6->W6_HAWB) )
                  Do While SW8->( !EoF()  .And.  W8_HAWB == SW6->W6_HAWB )
                     If !Empty(SW8->W8_AC)
                        If ED4->( DBSeek(cFilED4+SW8->W8_AC+SW8->W8_SEQSIS) )
                           oLockED4 := EDCLock():Novo( (::ED4:cAlias)->&(IndexKey(::ED4:nOrd)) )
                           Processa({||lRet:=::ED4:Trava(oLockED4)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                           If !lRet
                              Exit
                           EndIf
                        EndIf
                        If cAntImp == "2"  .And.  EDD->( DBSeek(cFilEDD+SW8->W8_AC) )
                           oLockEDD := EDCLock():Novo( EDD->(EDD_FILIAL+EDD_AC) )
                           Processa({||lRet:=::EDD:Trava(oLockEDD,ALL_REG)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                           If !lRet
                              Exit
                           EndIf
                        EndIf
                     EndIf
                     SW8->( DBSkip() )
                  EndDo
                  If !lRet
                     ::Solta("DI","ALTERA")
                     Break
                  EndIf
               EndIf
               
            ElseIf cAction == "ESTORNA"

               If lMultiFil
                  cFilAux := SW6->W6_FILIAL
               Else
                  cFilAux := cFilSW8
               EndIf

               ED4->( DBSetOrder(2) )
               EDD->( DBSetOrder(1) )
               SW8->( DBSetOrder(3) )
               SW8->( DBSeek(cFilAux+SW6->W6_HAWB) )
               Do While SW8->( !EoF()  .And.  W8_HAWB == SW6->W6_HAWB )
                  If !Empty(SW8->W8_AC)
                     If ED4->( DBSeek(cFilED4+SW8->W8_AC+SW8->W8_SEQSIS) )
                        oLockED4 := EDCLock():Novo( (::ED4:cAlias)->&(IndexKey(::ED4:nOrd)) )
                        Processa({||lRet:=::ED4:Trava(oLockED4)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                        If !lRet
                           Exit
                        EndIf
                     EndIf
                     If cAntImp == "2"  .And.  EDD->( DBSeek(cFilEDD+SW8->W8_AC) )
                        oLockEDD := EDCLock():Novo( EDD->(EDD_FILIAL+EDD_AC) )
                        Processa({||lRet:=::EDD:Trava(oLockEDD,ALL_REG)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                        If !lRet
                            Exit
                        EndIf
                     EndIf
                  EndIf
                  SW8->( DBSkip() )
               EndDo
               If !lRet
                  ::Fim()
                  Break
               EndIf

            ElseIf cAction == "SEL_ITEM"

               ED4->( DBSetOrder(2) )
               If ED4->( DBSeek(cFilED4+Work->WKAC+Work->WKSEQSIS) )
                  oLockED4 := EDCLock():Novo( (::ED4:cAlias)->&(IndexKey(::ED4:nOrd)) )
                  Processa({||lRet:=::ED4:Trava(oLockED4)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                  If !lRet
                     Break
                  EndIf
               EndIf

            EndIf
            
         Case cFunction == "EMBARQUE_EXP"

            If cAction == "APROPRIA"
               oLockED3 := EDCLock():Novo( (::ED3:cAlias)->&(IndexKey(::ED3:nOrd)) )
               Processa({||lRet:=::ED3:Trava(oLockED3)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
               If !lRet
                  Break
               EndIf
               If lTemEDD  .And.  EDD->( DBSetOrder(1), DBSeek(cFilEDD+ED3->ED3_AC) )
                  oLockEDD := EDCLock():Novo( EDD->(EDD_FILIAL+EDD_AC) )
                  Processa({||lRet:=::EDD:Trava(oLockEDD,ALL_REG)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                  If !lRet
                     ::ED3:Destrava(oLockED3)
                     Break
                  EndIf
               EndIf

            ElseIf cAction == "ESTORNA"  .Or.  cAction == "ESTORNA_ATO"
               WorkIP->( DBGoTop() )
               ED3->( DBSetOrder(2) )
               If lTemEDD
                  EDD->( DBSetOrder(1) )
               EndIf
               Do While WorkIP->( !EoF() )
                  If !Empty(WorkIP->EE9_ATOCON)  .And.  ED3->( DBSeek(cFilED3+WorkIP->EE9_ATOCON+WorkIP->EE9_SEQED3) )
                     oLockED3 := EDCLock():Novo( (::ED3:cAlias)->&(IndexKey(::ED3:nOrd)) )
                     Processa({||lRet:=::ED3:Trava(oLockED3)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                     If !lRet
                        ::Fim()
                        Break
                     EndIf
                     If lTemEDD  .And.  EDD->( DBSeek(cFilEDD+ED3->ED3_AC) )
                        oLockEDD := EDCLock():Novo( EDD->(EDD_FILIAL+EDD_AC) )
                        Processa({||lRet:=::EDD:Trava(oLockEDD,ALL_REG)},STR0027)  //"Bloqueando registros relacionados ao Drawback..."
                        If !lRet
                           ::Fim()
                           Break
                        EndIf
                     EndIf
                  EndIf
                  WorkIP->( DBSkip() )
               EndDo

            EndIf

         Case cFunction == "INTEGRACAO"
         
            If cAction == "EFETIVA_DI"
               oLockED8 := EDCLock():Novo( (::ED8:cAlias)->&(IndexKey(::ED8:nOrd)) )
               If !( lRet := ::ED8:Trava(oLockED8,,.F.) )
                  Break
               EndIf

            ElseIf cAction == "EFETIVA_ATO"
               oLockED4 := EDCLock():Novo( (::ED4:cAlias)->&(IndexKey(::ED4:nOrd)) )
               If !( lRet:=::ED4:Trava(oLockED4,,.F.) )
                  Break
               EndIf

            EndIf

      EndCase

   End Sequence
   
   RestOrd(aOrd,.T.)

Return lRet

//*************************************************************************************************************//
// Autor:      PLB - Pedro Baroni
// Data:       23/11/06
// Classe:     EDCMultiUser
// Método:     Solta(cFunction,cAction)
// Parametros: cFunction -> Local de onde foi efetuada a chamada para soltar os registros.
//             cAction   -> Ação executada no local da chamada.
// Objetivo:   Reservar os registros necessarios de acordo com a ação e o local da chamada.
//*************************************************************************************************************//
Method Solta(cFunction,cAction) Class EDCMultiUser

 Local lRet   := .T.
 Local cChave  := ""
 Local cFilED8 := xFilial("ED8")
 Local cFilEE9 := xFilial("EE9")
 Local cFilSW8 := xFilial("SW8")
 Local cFilED9 := xFilial("ED9")
 //Local lDiExt  := EasyGParam("MV_EDCDIE",,.F.)
 Local lTemEDD := .F.
 Local aOrd   := {}
 Local cFilAux := ""
 Private lMultiFil := .F.

   aOrd := SaveOrd({"ED3","ED4","ED8","EE9","SW8","SX3"})

   SX3->( DBSetOrder(2) )
   lTemEDD := SX3->( DBSeek("EDD_FILIAL") )

   //** PLB 21/06/07 - Tratamento Multi-Filial para Drawback
   lMultiFil  := VerSenha(115)  ;
                 .And.  Posicione("SX2",1,"ED1","X2_MODO") == "C" ;
                 .And.  Posicione("SX2",1,"ED2","X2_MODO") == "C" ;
                 .And.  Posicione("SX2",1,"EDD","X2_MODO") == "C" ;
                 .And.  Posicione("SX2",1,"EE9","X2_MODO") == "E" ;
                 .And.  Posicione("SX2",1,"SW8","X2_MODO") == "E" ;
                 .And.  ED1->( FieldPos("ED1_FILORI") ) > 0  ;
                 .And.  ED2->( FieldPos("ED2_FILORI") ) > 0  ;
                 .And.  EDD->( FieldPos("EDD_FILEXP") ) > 0  ;
                 .And.  EDD->( FieldPos("EDD_FILIMP") ) > 0
   //**  

   Begin Sequence
   
      Do Case

         Case cFunction == "ATO"

            If cAction == "DESMARCA_RE"

               If lMultiFil
                  cFilAux := Left(WorkRE->ED1_FILORI,2)
               Else
                  IF EMPTY(WorkRE->ED1_PREEMB)
                     cFilAux := cFilED9
                  Else
                     cFilAux := cFilEE9
                  EndIf
               EndIf
               
               //Igor Chiba 07/04/2009
               IF EMPTY(WorkRE->ED1_PREEMB)
                  oLockED9 := EDCLock():Novo(cFilAux+WorkRE->ED1_PREEMB+WorkRE->ED1_PEDIDO+WorkRE->ED1_SEQUEN)
                  ::ED9:Destrava(oLockED9)
               ELSE
               //FIM Igor Chiba 07/04/2009
                  oLockEE9 := EDCLock():Novo(cFilAux+WorkRE->ED1_PREEMB+WorkRE->ED1_PEDIDO+WorkRE->ED1_SEQUEN)
                  ::EE9:Destrava(oLockEE9)
               ENDIF
            ElseIf cAction == "FECHA_BROWSE_RE"

               WorkRE->( DBGoTop() )
               Do While WorkRE->( !EoF() )
                  If !Empty(WorkRE->MARCA)
                     If lMultiFil
                        cFilAux := Left(WorkRE->ED1_FILORI,2)
                     Else
                        IF EMPTY(WorkRE->ED1_PREEMB)
                           cFilAux := cFilED9
                        Else
                           cFilAux := cFilEE9
                        EndIf
                     EndIf
                     
                     //Igor Chiba 07/04/2009
                     IF EMPTY(WorkRE->ED1_PREEMB)
                        oLockED9 := EDCLock():Novo(cFilAux+WorkRE->ED1_PREEMB+WorkRE->ED1_PEDIDO+WorkRE->ED1_SEQUEN)
                        ::ED9:Destrava(oLockED9)
                     ELSE
                     //FIM Igor Chiba 07/04/2009
                        oLockEE9 := EDCLock():Novo(cFilAux+WorkRE->ED1_PREEMB+WorkRE->ED1_PEDIDO+WorkRE->ED1_SEQUEN)
                        ::EE9:Destrava(oLockEE9)
                     ENDIF
                  EndIf
                  WorkRE->( DBSkip() )
               EndDo

            ElseIf cAction == "DESMARCA_DI"

               If lMultiFil
                  cFilAux := Left(WorkDI->ED2_FILORI,2)
               Else
                  cFilAux := cFilSW8
               EndIf

               oLockSW8 := EDCLock():Novo(cFilAux+WorkDI->ED2_HAWB+WorkDI->ED2_INVOIC+WorkDI->ED2_PO_NUM+WorkDI->ED2_POSICA+WorkDI->ED2_PGI_NU)
               ::SW8:Destrava(oLockSW8)

               If ChkFile("ED8",.F.) //lDiExt .And. - NOPADO POR AOM - 04/11/10
                  oLockED8 := EDCLock():Novo(cFilED8+WorkDI->ED2_DI_NUM+WorkDI->ED2_ADICAO+WorkDI->ED2_POSICA)
                  ::ED8:Destrava(oLockED8)
               EndIf

            ElseIf cAction == "FECHA_BROWSE_DI"

               WorkDI->( DBGoTop() )
               Do While WorkDI->( !EoF() )
                  If !Empty(WorkDI->MARCA)
                     If lMultiFil
                        cFilAux := Left(WorkDI->ED2_FILORI,2)
                     Else
                        cFilAux := cFilSW8
                     EndIf
                     oLockSW8 := EDCLock():Novo(cFilAux+WorkDI->ED2_HAWB+WorkDI->ED2_INVOIC+WorkDI->ED2_PO_NUM+WorkDI->ED2_POSICA+WorkDI->ED2_PGI_NU)
                     ::SW8:Destrava(oLockSW8)
                     If ChkFile("ED8",.F.) //lDiExt .And.  - NOPADO POR AOM - 04/11/10
                        oLockED8 := EDCLock():Novo(cFilED8+WorkDI->ED2_DI_NUM+WorkDI->ED2_ADICAO+WorkDI->ED2_POSICA)
                        ::ED8:Destrava(oLockED8)
                     EndIf
                  EndIf
                  WorkDI->( DBSkip() )
               EndDo

            EndIf   

         Case cFunction == "PLI"

            If cAction == "ALT_ATO"
            
               ED4->( DBSetOrder(2) )
               If ED4->( DBSeek(cFilED4+Work->WKAC+Work->WKSEQSIS) )
                  oLockED4 := EDCLock():Novo( (::ED4:cAlias)->&(IndexKey(::ED4:nOrd)) )
                  ::ED4:Destrava(oLockED4)
               EndIf
            
            EndIf

         Case cFunction == "DI"

            If cAction == "ALTERA"
            
               Do While Len(::ED4:aLock) > 0
                  ::ED4:Destrava(::ED4:aLock[1])
               EndDo
               Do While Len(::EDD:aLock) > 0
                  ::EDD:Destrava(::EDD:aLock[1])
               EndDo

            ElseIf cAction == "SEL_ITEM"

               ED4->( DBSetOrder(2) )
               If ED4->( DBSeek(cFilED4+Work->WKAC+Work->WKSEQSIS) )
                  oLockED4 := EDCLock():Novo( (::ED4:cAlias)->&(IndexKey(::ED4:nOrd)) )
                  ::ED4:Destrava(oLockED4)
               EndIf

            EndIf

         Case cFunction == "EMBARQUE_EXP"

            If cAction == "ALTERA_ATO"
               If ED3->( DBSetOrder(2), DBSeek(cFilED3+WorkIP->EE9_ATOCON+WorkIP->EE9_SEQED3) )
                  oLockED3 := EDCLock():Novo( (::ED3:cAlias)->&(IndexKey(::ED3:nOrd)) )
                  ::ED3:Destrava(oLockED3)
                  If lTemEDD  .And.  EDD->( DBSetOrder(1), DBSeek(cFilEDD+ED3->ED3_AC) )
                     oLockEDD := EDCLock():Novo( EDD->(EDD_FILIAL+EDD_AC) )
                     ::EDD:Destrava(oLockEDD,ALL_REG)
                  EndIf
               EndIf
            EndIf
            
      EndCase

   End Sequence

   RestOrd(aOrd,.T.)

Return lRet

//*************************************************************************************************************//
// Autor:    PLB - Pedro Baroni
// Data:     23/11/06
// Classe:   EDCMultiUser
// Método:   Fim()
// Objetivo: Finalizar um objeto EDCMultiUser e destravar todos os registros.
// Retorno:  Tipo   -> Objeto
//           Descr. -> Novo objeto
//*************************************************************************************************************//
Method Fim() Class EDCMultiUser

   MSUnLockAll()
   ::Novo()

Return

//*************************************************************************************************************//
// Autor:      PLB - Pedro Baroni
// Data:       23/11/06
// Classe:     EDCTable
// Método:     Novo(cAlias,nOrd,oPai)
// Parametros: cAlias -> Alias da tabela a ter seus registro reservados.
//             nOrd   -> Ordem do Indice da tabela.
//             oPai   -> Objeto do tipo EDCTable que tem relação de Paternidade com o cAlias.
// Objetivo:   Criar um objeto EDCTable.
// Retorno:    Tipo   -> Objeto
//             Descr. -> Novo objeto
//*************************************************************************************************************//
Method Novo(cAlias,nOrd,oPai) Class EDCTable
   
   ::aLock  := {}
   ::cAlias := cAlias
   ::nOrd   := nOrd
   ::oPai   := oPai
   ::nLocks := 0
   
Return

//*************************************************************************************************************//
// Autor:      PLB - Pedro Baroni
// Data:       23/11/06
// Classe:     EDCTable
// Método:     Trava(oLock,lAll)
// Parametros: oLock -> Objeto do tipo EDCLock.
//             lAll  -> Identifica se todos os registros que contenham a chave do oLock devem ser bloqueados.
//             lSoft -> Identifica se o modo de bloqueio dos registros será o SoftLock()
// Objetivo:   Bloquear os registros da tabela do EDCTable e de seu objeto pai (EDCTable:oPai) de acordo com 
//             a chave existente no objeto oLock.
// Retorno:    Tipo   -> Lógico
//             Descr. -> Identifica se foi posivel bloquear os registros da chave do oLock
//*************************************************************************************************************//
Method Trava(oLock,lAll,lSoft) Class EDCTable

 Local lRet   := .T.
 Local cAlias := ::cAlias
 Local nOrd   := ::nOrd
 Local cPai   := IIF(::oPai!=NIL,::oPai:cAlias,"")
 Local cFilPai:= ""
 Local cChave := oLock:cChave
 Local bIndex := &("{|| Left("+(cAlias)->( IndexKey(nOrd) )+","+AllTrim(Str(Len(cChave)))+")}")
 Local aOrd   := {}
 Local bTrava := {|| }

 Default lAll  := .F.
 Default lSoft := .T.

   If lSoft
      bTrava := { || SoftLock(cAlias) }
   Else
      bTrava := { || IIF((cAlias)->( DBRLock() ),SoftLock(cAlias),.F.) }
   EndIf

   aOrd := SaveOrd({cAlias})

   (cAlias)->( DBSetOrder(nOrd) )

   If !Empty(cPai)

      If lMultiFil
         cFilPai := Left(cChave,2)
      Else
         cFilPai := xFilial(cPai)
      EndIf

      If (cAlias)->( DBSeek(cChave) )

         Do Case
            Case cPai == "SW6"
               oLockSW6 := EDCLock():Novo(cFilPai+SW8->W8_HAWB)
               lRet     := ::oPai:Trava(oLockSW6)

            Case cPai == "EEC"
               oLockEEC := EDCLock():Novo(cFilPai+EE9->EE9_PREEMB)
               lRet     := ::oPai:Trava(oLockEEC)

         EndCase

      EndIf

   EndIf

   If lRet

      If (cAlias)->( DBSeek(cChave) ) .AND. !(cAlias)->( IsLocked() ) //AAF 03/12/08 - Verifica se já está travado.
         AAdd(::aLock,oLock)
         If lAll
            Do While (cAlias)->( !EoF()  .And.  Eval(bIndex) == cChave )
               
               If ::nLocks + 1 < LIMITE_LOCKS
                  If !Eval(bTrava)
                     ::Destrava(oLock,lAll)
                     lRet := .F.
                     Exit
                  EndIf
                  ::nLocks++ //AAF 03/12/2008
               Else
                  //Atingiu o numero máximo de LOCKS. Não travar mais registros.
                  EXIT
               EndIf
               
               (cAlias)->( DBSkip() )
            EndDo
         Else
            If ::nLocks + 1 < LIMITE_LOCKS //AAF 03/12/2008
               If !Eval(bTrava)
                  ::Destrava(oLock,lAll)
                  lRet := .F.
               Else
                  ::nLocks++ //AAF 03/12/2008
               EndIf
            EndIf
         EndIf
      EndIf

   EndIf

   RestOrd(aOrd,.T.)

Return lRet

//*************************************************************************************************************//
// Autor:      PLB - Pedro Baroni
// Data:       23/11/06
// Classe:     EDCTable
// Método:     Destrava(oLock,lAll)
// Parametros: oLock -> Objeto do tipo EDCLock.
//             lAll  -> Identifica se todos os registros que contenham a chave do oLock devem ser desbloqueados.
// Objetivo:   Desbloquear os registros da tabela do EDCTable e de seu objeto pai (EDCTable:oPai) de acordo com 
//             a chave existente no objeto oLock.
// Retorno:    Tipo   -> Lógico
//             Descr. -> Identifica se foi posivel desbloquear os registros da chave do oLock
//*************************************************************************************************************//
Method Destrava(oLock,lAll) Class EDCTable

 Local cAlias  := ::cAlias
 Local nOrd    := ::nOrd
 Local cChave := oLock:cChave
 Local bIndex := &("{|| Left("+(cAlias)->( IndexKey(nOrd) )+","+AllTrim(Str(Len(cChave)))+")}")
 Local nPos    := 0
 Local nPosPai := 0
 Local aOrd   := {}

 Default lAll := .F.

   aOrd := SaveOrd({cAlias})
 
   nPosPai := ::BuscaPai(oLock)
   If nPosPai > 0  .And.  ::FilhoUnico(oLock,nPosPai)
      ::oPai:Destrava(::oPai:aLock[nPosPai])
   EndIf

   (cAlias)->( DBSetOrder(nOrd) )

   nPos := ::BuscaLock(oLock)
   If nPos > 0
      ADel(::aLock,nPos)
      ASize(::aLock,Len(::aLock)-1)
   EndIf

   If (cAlias)->( DBSeek(cChave) )  .And.  ::BuscaLock(oLock) == 0
      If lAll
         Do While (cAlias)->( !EoF()  .And.  Eval(bIndex) == cChave )
            If (cAlias)->(IsLocked())
               (cAlias)->( MSUnLock() )
               ::nLocks-- //AAF 03/12/2008
            EndIf
            
            (cAlias)->( DBSkip() )
         EndDo
      ElseIf (cAlias)->(IsLocked())
         (cAlias)->( MSUnLock() )
         ::nLocks-- //AAF 03/12/2008
      EndIf
   EndIf

   RestOrd(aOrd,.T.)

Return


//*************************************************************************************************************//
// Autor:      PLB - Pedro Baroni
// Data:       23/11/06
// Classe:     EDCTable
// Método:     Atualiza()
// Objetivo:   Travar todos os registros relacionados às chaves das Tabelas existentes no objeto
//*************************************************************************************************************//
Method Atualiza() Class EDCTable

 Local ni := 1
 Local cAlias := ::cAlias
 Local nOrd   := ::nOrd
 Local bChave := { || ::aLock[ni]:cChave }

   (cAlias)->( DBSetOrder(nOrd) )
   For ni := 1  to  Len(::aLock)
      If (cAlias)->( DBSeek(Eval(bChave)) )
         SoftLock(cAlias)
      EndIf
   Next ni

Return


//*************************************************************************************************************//
// Autor:      PLB - Pedro Baroni
// Data:       23/11/06
// Classe:     EDCTable
// Método:     BuscaPai(oLock)
// Parametros: oLock -> Objeto do tipo EDCLock.
// Objetivo:   Verificar se os registros da chave do objeto oLock possuem registros bloqueados na tabela-pai
// Retorno:    Tipo   -> Numérico
//             Descr. -> Caso encontre registro-pai bloqueado retorna a posição do objeto-pai(tipo EDCLock)
//                       no array de objetos bloqueados(aLock) na tabela-pai(EDCTable).
//*************************************************************************************************************//
Method BuscaPai(oLock) Class EDCTable

 Local nPos := 0
 
   If ::oPai != NIL
      nPos := AScan( ::oPai:aLock,{ |x| x:cChave == Left(oLock:cChave,Len(x:cChave)) } )
   EndIf
 
Return nPos


//*************************************************************************************************************//
// Autor:      PLB - Pedro Baroni
// Data:       23/11/06
// Classe:     EDCTable
// Método:     BuscaLock(oLock)
// Parametros: oLock -> Objeto do tipo EDCLock.
// Objetivo:   Verificar se o objeto já existe no objeto EDCTable
// Retorno:    Tipo   -> Numérico
//             Descr. -> Caso encontre o objeto, retorna a posição dele no array de bloqueados(aLock) 
//                       do objeto EDCTable.
//*************************************************************************************************************//
Method BuscaLock(oLock) Class EDCTable

 Local nPos := 0
 
   If oLock != NIL
      nPos := AScan(::aLock,{ |x| x:cChave == oLock:cChave })
   EndIf
 
Return nPos


//*************************************************************************************************************//
// Autor:      PLB - Pedro Baroni
// Data:       23/11/06
// Classe:     EDCTable
// Método:     FilhoUnico(oLock,nPosPai)
// Parametros: oLock   -> Objeto do tipo EDCLock.
//             nPosPai -> Posição do objeto-pai.
// Objetivo:   Verificar se o objeto é o único a possuir o objeto-pai bloqueado.
// Retorno:    Tipo   -> Logico
//             Descr. -> Identifica se o objetivo foi alcançado.
//*************************************************************************************************************//
Method FilhoUnico(oLock,nPosPai) Class EDCTable

 Local lRet := .T.

   cChavePai := ::oPai:aLock[nPosPai]:cChave

   lRet := AScan(::aLock,{ |x| Left(x:cChave,Len(cChavePai)) == cChavePai  .And.  x:cChave != oLock:cChave }) == 0

Return lRet

//*************************************************************************************************************//
// Autor:    PLB - Pedro Baroni
// Data:     23/11/06
// Classe:   EDCLock
// Método:   Novo()
// Objetivo: Criar um objeto EDCLock.
// Retorno:  Tipo   -> Objeto
//           Descr. -> Novo objeto
//*************************************************************************************************************//
Method Novo(cChave) Class EDCLock

   ::cChave     := cChave

Return

//***********************************************//
//Função......: AC401STR()
//Programador.: Alessandro Alves Ferreira - AAF
//Objetivo....: Retornar a String STR para utilização no EDCAC400 que não tem mais capacidade para declaração de STR's
//Observação..: Para Strings acima do STR0310 do EDCAC400               
//Data........: 16/08/06
//***********************************************//
Function AC401STR(nStr)
//***********************************************//
Local cStr

Do Case
   Case nStr == 0001 ; cStr := STR0001 //"Histórico"
   Case nStr == 0002 ; cStr := STR0002 //"Nao existe conversão entre a Unidade do Produto"
   Case nStr == 0003 ; cStr := STR0003 //"e a Unidade de Venda"
   Case nStr == 0004 ; cStr := STR0004 //"Atualize o cadastro de conversão de unidades de medida."
   Case nStr == 0005 ; cStr := STR0005 //"Nao existe conversão entre a Unidade Original de Venda"
   Case nStr == 0006 ; cStr := STR0006 //"e a nova Unidade de Venda"
   Case nStr == 0007 ; cStr := STR0007 //"Nao existe conversão entre a Unidade do Item"
   Case nStr == 0008 ; cStr := STR0008 //"e a Unidade de Compra"
   Case nStr == 0009 ; cStr := STR0009 //"Alteração não pode ser realizada pois o Ato Concessório já está encerrado."
   Case nStr == 0010 ; cStr := STR0010 //"Alteração não pode ser relizada em Ato Concessório com NCM Genérica."
   Case nStr == 0011 ; cStr := STR0011 //"Alteração não pode ser relizada pois o Ato Concessório está vencido."
   Case nStr == 0012 ; cStr := STR0012 //"Não há saldo de quantidade restante para a troca de NCM"
   Case nStr == 0013 ; cStr := STR0013 //"Não há saldo de valor restante para a troca de NCM, deseja continuar?"
   Case nStr == 0014 ; cStr := STR0014 //"NCM Atual"
   Case nStr == 0015 ; cStr := STR0015 //"Nova NCM"
   Case nStr == 0016 ; cStr := STR0016 //"Confirma alteração da NCM "
   Case nStr == 0017 ; cStr := STR0017 //" para NCM "
   Case nStr == 0018 ; cStr := STR0018 //" na Sequencia "
   Case nStr == 0019 ; cStr := STR0019 //"Não existem registros de histórico do Pedido de Drawback "
   Case nStr == 0020 ; cStr := STR0020 //"Visualização de Histórico"
   Case nStr == 0021 ; cStr := STR0021 //"Alt. NCM"
   Case nStr == 0022 ; cStr := STR0022 //"O item possui Valor Comercial a Perda, preencha o campo Percentual de Perda."
   Case nStr == 0023 ; cStr := STR0023 //"Comparando Estruturas..."
   Case nStr == 0024 ; cStr := STR0024 //"O Produto possui itens alternativos e foram encontradas divergências no Cadastro de Estruturas:"
   Case nStr == 0025 ; cStr := STR0025 //"Deseja continuar com a operação?"
   Case nStr == 0026 ; cStr := STR0026 //"Este Item Importado não é compatível com a Estrutura do Produto Alternativo ou a Estrutura do Produto principal diverge do Pedido."
   Case nStr == 0028 ; cStr := STR0028 //"A Dedução de Percentual de Perda não é permitida. O Percentual Aprovado deve ser o mesmo do Percentual de Perda."
End Case

Return cStr
//***********************************************//
//Função......: AC400CalcPer()
//Programador.: André Luiz dos Santos - ALS
//Objetivo....: Retornar o percentual da razão entre o valor total de subprodutos 
//              ou resíduos não exportados que possuem algum valor comercial e o 
//              valor total de produtos importados.
//Data........: 10/12/07
//***********************************************//
Function AC401CalcPer(cAlias,cPed)
//If !Empty(WorkED2->ED2_MARCA) 
   Local nRet := 0, nSomaVALEMB := 0, nSomaVALCAL :=0 , nRecno := "", cFilED := "",  nVALCAL :=0
   Default cPed:= ED0->ED0_PD  //TRP-21/05/08   
   
   If cAlias == NIL .AND. Select("WorkED2") > 0
      cAlias := "WorkED2"
   else
      cAlias := "ED2"
   EndIf  
   
    nRecno := (cAlias)->(Recno()) 
    cFilED := xFilial(cAlias) 
   
   if cAlias == "WorkED2"
       (cAlias)->(dbGoTop())
       Do While ! (cAlias)->(EOF()) 
          if  (cAlias)->ED2_VLCOPE == "S" .and. !Empty((cAlias)->ED2_MARCA)     
             nSomaVALEMB +=  (cAlias)->ED2_VALEMB
             nSomaVALCAL +=  (cAlias)->ED2_VALCAL     
          endif 
          (cAlias)->(dbSkip())
       EndDo
    else
       (cAlias)->(dbSetOrder(1))
       
       if (cAlias)->(dbSeek(cFilED+cPed))
          Do While ! (cAlias)->(EOF()) .and. (cAlias)->ED2_FILIAL==cFilED .and. (cAlias)->ED2_PD==cPed
             if  (cAlias)->ED2_VLCOPE == "S" .and. !Empty((cAlias)->ED2_MARCA)     
                nSomaVALEMB +=  (cAlias)->ED2_VALEMB                
                
                If (cAlias)->ED2_PERCAP > 0  
                   If (cAlias)->ED2_PERCPE > (cAlias)->ED2_PERCAP
                      nVALCAL := (cAlias)->ED2_VALEMB - (((cAlias)->ED2_PERCPE - (cAlias)->ED2_PERCAP) * (cAlias)->ED2_VALEMB)/100  
                   Else
                      nVALCAL := (cAlias)->ED2_VALEMB
                   EndIf                            
                Else
                   If (cAlias)->ED2_PERCPE > 0                      
                      nVALCAL := (cAlias)->ED2_VALEMB - ((cAlias)->ED2_PERCPE * (cAlias)->ED2_VALEMB)/100  
                    Else
                      nVALCAL := (cAlias)->ED2_VALEMB
                    EndIf                
                Endif
               
               nSomaVALCAL += nVALCAL     
             endif 
             
             (cAlias)->(dbSkip())           
          EndDo    
      endif   
    endif
    
    If nSomaVALCAL > 0 .And. cAlias == "ED2" //MCF - 19/10/2017 - Tratamento para enviar valor da moeda e não porcentagem para o Siscomex
	   nRet := nSomaVALEMB - nSomaVALCAL
	ElseIf nSomaVALCAL > 0
      nRet := Round((1 - nSomaVALCAL/nSomaVALEMB)*100,2)   
   endif

   (cAlias)->(DbGoTo(nRecno))
return nRet

Method New(Filial,Pedido,TablesOld,TablesNew) class EDCAditivo
   
Default TablesOld := {{"ED0",{|| dbSetOrder(1), dbSeek(::Filial+::Pedido) }},;
                      {"ED3",{|| dbGoTo(WorkED3->ED3_RECNO)}},;
                      {"ED4",{|| dbGoTo(WorkED4->ED4_RECNO)}} }

Default TablesNew := {{"M"      ,              ,             ,           },;
                      {"WorkED3",{|| dbGoTop()},{|| dbSkip()},{|| EoF()}},;
                      {"WorkED4",{|| dbGoTop()},{|| dbSkip()},{|| EoF()}} }
   
   ::Filial       := Filial
   ::Pedido       := Pedido
   ::TablesOld    := TablesOld
   ::TablesNew    := TablesNew
   ::FieldChanged := {}
   
Return

Method ChangeCheck() class EDCAditivo
Local i, j
Local nPos
Local cAlias, cCampo, uValueOld, uValueNew, cAnexo, cPicture, cTotal, cAliasOld, cAliasNew

For i := 1 To Len(::TablesOld)
   
   // Posiciona a Tabela nova
   If !Empty(::TablesNew[i][2])
      (::TablesNew[i][1])->( Eval(::TablesNew[i][2]) )
   EndIf
   
   // Posiciona a Tabela antiga
   If !Empty(::TablesOld[i][2])
      (::TablesOld[i][1])->( Eval(::TablesOld[i][2]) )
   EndIf
   
   Do While .T.

      If (::TablesOld[i][1])->( !EoF() ) .AND. If(::TablesNew[i][1] <> "M", (::TablesNew[i][1])->( !EoF() ), .T.)
      
         For j := 1 TO (::TablesOld[i][1])->( FCount() )
          
            cAliasOld := ::TablesOld[i][1]
            cAliasNew := ::TablesNew[i][1]
            cCampo    := (cAliasOld)->( FieldName(j) )
            nPos      := 0
       
            Do While (nPos := aScan(CAMPOS_ADITIVO,{|X| cCampo $ X[1] .OR. If(!Empty(X[2]),cCampo $ x[2],.F.)},nPos+1)) > 0
               
               cCampoAdi := If(Empty(CAMPOS_ADITIVO[nPos][2]),CAMPOS_ADITIVO[nPos][1],CAMPOS_ADITIVO[nPos][2])
               
               If aScan(::FieldChanged,{|X| X[3] == CAMPOS_ADITIVO[nPos][1]}) == 0
               
                  uValueOld := &(::TablesOld[i][1]+"->("+cCampoAdi+")")
                  uValueNew := &(::TablesNew[i][1]+"->("+cCampoAdi+")")
            
                  /*
                  If (::TablesOld[i])->( nPos := FieldPos(::TablesOld[i]+"_ANEXO") ) > 0
                     cAnexo := (::TablesOld[i])->(FieldGet(nPos))
                  Else
                     cAnexo := ""
                  EndIf
                  */
            
                  If ValType(uValueOld) == ValType(uValueNew) .AND. uValueOld <> uValueNew
                   
                     If ValType(uValueOld) == "N"
                        cPicture  := "@E 999,999,999,999,999"+If(AVSX3(cCampo,4)#0,"."+Replicate("9",AVSX3(cCampo,4)),"")
                        uValueOld := TransForm(uValueOld,cPicture)
                        uValueNew := TransForm(uValueNew,cPicture)
                     EndIf
                     
                     nRecOld := (cAliasOld)->(RecNo())
                     nRecNew := If (cAliasNew <> "M", (cAliasNew)->(RecNo()),)
                  
                     If nRecNew > 0
                        aAdd(::FieldChanged,{cAliasOld, cAliasNew, CAMPOS_ADITIVO[nPos][1], uValueOld, uValueNew, nRecOld, nRecNew })
                     EndIf
                  EndIf
               EndIf
            End Do
         Next j
      
      ElseIf (::TablesNew[i][1])->( !EoF() )
         
         //Inclusão
         
      EndIf
      
      //Pula para o próximo registro
      If !Empty(::TablesNew[i][3])
         (::TablesNew[i][1])->( Eval(::TablesNew[i][3]) )
      EndIf
      
      //Posiciona tabela antiga
      If !Empty(::TablesOld[i][2])
         (::TablesOld[i][1])->( Eval(::TablesOld[i][2]) )
      EndIf
      
      //Condição do laço
      If Empty(::TablesNew[i][4]) .OR. (::TablesNew[i][1])->( Eval(::TablesNew[i][4]) )
         EXIT
      EndIf
   EndDo

Next i

//Calcula Totais
For i:= 1 To Len(::FieldChanged)
   If Left(::FieldChanged[i][3],3) == "TOT"
      
      cAliasOld := ::FieldChanged[i][1]
      cAliasNew := ::FieldChanged[i][2]
      cTotal    := ::FieldChanged[i][3]
      nRegOld   := ::FieldChanged[i][6]
      nRegNew   := ::FieldChanged[i][7]
      
      ::FieldChanged[i][4] := ::TotVal(cAliasOld, cTotal, nRegOld)
      ::FieldChanged[i][5] := ::TotVal(cAliasNew, cTotal, nRegNew)
      
   EndIf
Next i

::FieldChanged := aSort(::FieldChanged,,,{|X,Y| x[1]+x[3] < y[1]+y[3]})

Return

Method TotVal(cAlias, cCampo, nReg) Class EDCAditivo

Local uValCpo:= 0
Local cOrd   := (cAlias)->(IndexOrd())
Local nRec   := (cAlias)->(RecNo())
Local lBase  := cAlias == "ED4" .OR. cAlias == "ED3"
Local i
Local cAnexo
Local cPictQtde := "@E 999,999,999,999,999"+If(AVSX3("ED1_QTD",4)#0,"."+Replicate("9",AVSX3("ED1_QTD",4)),"")
Local cPictFob  := "@E 9,999,999,999,999"+If(AVSX3("ED3_VAL_CO",4)#0,"."+Replicate("9",AVSX3("ED3_VAL_CO",4)),"")
Local cPictPeTot:= "@E 99,999,999,999"+If(AVSX3("ED1_PESO",4)#0,"."+Replicate("9",5),"")

(cAlias)->(dbGoTo(nReg))
If lBase
   cAnexo := (cAlias)->( &(cAlias+"_ANEXO") )
Else
   cAnexo := (cAlias)->( &(Right(cAlias,3)+"_ANEXO") )
EndIf

If lBase
   ED4->(dbSetOrder(1))
   ED4->(dbSeek(::Filial+::Pedido))
   bChaveED4 := {|| ED4->ED4_PD == ::Pedido }
Else
   WorkED4->(dbGoTop())
   bChaveED4 := {|| .T. }
EndIf

If lBase
   ED3->(dbSetOrder(1))
   ED3->(dbSeek(::Filial+::Pedido))
   bChaveED3 := {|| ED3->ED3_PD == ::Pedido }
Else
   WorkED3->(dbGoTop())
   bChaveED3 := {|| .T. }
EndIf

Do Case
   Case cCampo == "TOT_VAL_IMP_PD" .OR. cCampo == "TOT_VALEMB_IMP_PD"   //Campo 12 do Pedido //Campo 15 do Pedido
       
       Do While (cAlias)->( !EoF() .AND. Eval(bChaveED4) )
          
          If ED0->ED0_DEDUZP == "1" .AND. (cAlias)->ED4_QTD<>(cAlias)->ED4_QTDCAL
             uValCpo += (cAlias)->ED4_VALCAL
          Else
             uValCpo += (cAlias)->ED4_VALEMB
          EndIf
          
          (cAlias)->(dbSkip())
       EndDo

       uValCpo := Transf(uValCpo,cPictFob)       
   Case cCampo == "TOT_PESO_IMP_PD"      //Campo 13 do Pedido
   
       Do While (cAlias)->( !EoF() .AND. Eval(bChaveED4) )          
          uValCpo += (cAlias)->ED4_PESO
          
          (cAlias)->(dbSkip())
       EndDo
       
       uValCpo := Transf(uValCpo,cPictPeTot)   
   Case cCampo == "TOT_QTD_IMP_PD"       //Campo 14 do Pedido
       aAneQtdTot := {}
       
       Do While (cAlias)->( !EoF() .AND. Eval(bChaveED4) )          
          If ED0->ED0_DEDUZP == "1" .AND. (cAlias)->ED4_QTD<>(cAlias)->ED4_QTDCAL
             nCoef := (cAlias)->ED4_QTDCAL / (cAlias)->ED4_QTD
          Else
             nCoef := 1
          EndIf
       
          If (nPos:=aScan(aAneQtdTot,{|x| x[1]==(cAlias)->ED4_UMNCM})) == 0
             aAdd(aAneQtdTot,{(cAlias)->ED4_UMNCM,(cAlias)->ED4_QTDNCM*nCoef})
          Else
             aAneQtdTot[nPos,2] += (cAlias)->ED4_QTDNCM * nCoef
          EndIf
          
          (cAlias)->(dbSkip())
       EndDo
       
       uValCpo := ""
       If Len(aAneQtdTot) <= 6
          For i:=1 to Len(aAneQtdTot)
             cUnAne:= aAneQtdTot[i,1]
             If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"UNIDADE_MEDIDA_IMPRESSAO"),)
             
             uValCpo += Alltrim(Transf(aAneQtdTot[i,2],cPictQtde))+"-"+cUnAne+"; "
          Next i
       EndIf
         
   Case cCampo == "TOT_VALEMBEXT_IMP_PD" //Campo 16 do Pedido
       Do While (cAlias)->( !EoF() .AND. Eval(bChaveED4) )
          
          If ED0->ED0_DEDUZP == "1" .AND. (cAlias)->ED4_QTD<>(cAlias)->ED4_QTDCAL
             uValCpo += (cAlias)->ED4_VALCAL
          Else
             uValCpo += (cAlias)->ED4_VALEMB
          EndIf
          
          (cAlias)->(dbSkip())
       EndDo
       
       SYF->( dbSetOrder(1) )
       SYF->( dbSeek( xFilial("SYF")+EasyGParam("MV_SIMB2",,"US$") ) )

       cDolar   := AllTrim(SYF->YF_DESC_SI)
       cDolares := AllTrim(SYF->YF_DESC_PL)
       
       uValCpo := "("+AllTrim(StrTran(EXTENSO(uValCpo,.F.),"REAIS",If(uValCpo<2,cDolar,cDolares)))+")"
   
   Case cCampo == "TOT_VAL_EXP_PD" .OR. cCampo == "TOT_VALEMB_EXP_PD" //Campo 24 do Pedido //Campo 27 do Pedido
       
       Do While (cAlias)->( !EoF() .AND. Eval(bChaveED3) )
          uValCpo += ED3->ED3_VAL_EM
          
          (cAlias)->(dbSkip())
       EndDo
       
       uValCpo := Transf(uValCpo,cPictFob)
   Case cCampo == "TOT_PESO_EXP_PD"      //Campo 25 do Pedido
       Do While (cAlias)->( !EoF() .AND. Eval(bChaveED3) )
          uValCpo += ED3->ED3_PESO
          
          (cAlias)->(dbSkip())
       EndDo
       
       uValCpo := Transf(uValCpo,cPictPeTot)
   Case cCampo == "TOT_QTD_EXP_PD"       //Campo 26 do Pedido
       aAneQtdTot := {}
       
       Do While (cAlias)->( !EoF() .AND. Eval(bChaveED3) )
          If (nPos:=aScan(aAneQtdTot,{|x| x[1]==ED3->ED3_UMNCM})) == 0
             aAdd(aAneQtdTot,{ED3->ED3_UMNCM,ED3->ED3_QTDNCM})
          Else
             aAneQtdTot[nPos,2] += ED3->ED3_QTDNCM
          EndIf
          
          (cAlias)->(dbSkip())
       EndDo
       
       uValCpo := ""
       If Len(aAneQtdTot) <= 6   
          For i:=1 to Len(aAneQtdTot)
             cUnAne:= aAneQtdTot[i,1]
             If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"UNIDADE_MEDIDA_IMPRESSAO"),)
             
             uValCpo += Alltrim(Transf(aAneQtdTot[i,2],cPictQtde))+"-"+cUnAne+"; "
          Next i
       EndIf
       
   Case cCampo == "TOT_VALEMBEXT_EXP_PD" //Campo 28 do Pedido
       Do While (cAlias)->( !EoF() .AND. Eval(bChaveED3) )
          uValCpo += (cAlias)->ED3_VAL_EM
          
          (cAlias)->(dbSkip())
       EndDo
       
       SYF->( dbSetOrder(1) )
       SYF->( dbSeek( xFilial("SYF")+EasyGParam("MV_SIMB2",,"US$") ) )

       cDolar   := AllTrim(SYF->YF_DESC_SI)
       cDolares := AllTrim(SYF->YF_DESC_PL)
       
       uValCpo := "("+AllTrim(StrTran(EXTENSO(uValCpo,.F.),"REAIS",If(uValCpo<2,cDolar,cDolares)))+")"
   
   Case cCampo == "TOT_PESO_ANEIMP_PG"   //Campo 11 do Anexo Importação do Pedido
       Do While (cAlias)->( !EoF() .AND. Eval(bChaveED4) )
          If (cAlias)->ED4_ANEXO == cAnexo
             uValCpo += (cAlias)->ED4_PESO
          EndIf
          
          (cAlias)->(dbSkip())
       EndDo
       
       uValCpo := Transf(uValCpo,cPictPeTot)
   Case cCampo == "TOT_QTD_ANEIMP_PG"    //Campo 12 do Anexo Importação do Pedido
       aAneQtdTot := {}
       
       Do While (cAlias)->( !EoF() .AND. Eval(bChaveED4) )          
          
          If (cAlias)->ED4_ANEXO == cAnexo
             If ED0->ED0_DEDUZP == "1" .AND. (cAlias)->ED4_QTD<>(cAlias)->ED4_QTDCAL
                nCoef := (cAlias)->ED4_QTDCAL / (cAlias)->ED4_QTD
             Else
                nCoef := 1
             EndIf
       
             If (nPos:=aScan(aAneQtdTot,{|x| x[1]==(cAlias)->ED4_UMNCM})) == 0
                aAdd(aAneQtdTot,{(cAlias)->ED4_UMNCM,(cAlias)->ED4_QTDNCM*nCoef})
             Else
                aAneQtdTot[nPos,2] += (cAlias)->ED4_QTDNCM * nCoef
             EndIf
          EndIf
          
          (cAlias)->(dbSkip())
       EndDo
       
       uValCpo := ""
       If Len(aAneQtdTot) <= 6
          For i:=1 to Len(aAneQtdTot)
             cUnAne:= aAneQtdTot[i,1]
             If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"UNIDADE_MEDIDA_IMPRESSAO"),)
             
             uValCpo += Alltrim(Transf(aAneQtdTot[i,2],cPictQtde))+"-"+cUnAne+"; "
          Next i
       EndIf
   Case cCampo == "TOT_VALEMB_ANEIMP_PG" //Campo 13 do Anexo Importação do Pedido
       Do While (cAlias)->( !EoF() .AND. Eval(bChaveED4) )
          
          If (cAlias)->ED4_ANEXO == cAnexo
             If ED0->ED0_DEDUZP == "1" .AND. (cAlias)->ED4_QTD<>(cAlias)->ED4_QTDCAL
                uValCpo += (cAlias)->ED4_VALCAL
             Else
                uValCpo += (cAlias)->ED4_VALEMB
             EndIf
          EndIf
          
          (cAlias)->(dbSkip())
       EndDo
       
       uValCpo := Transf(uValCpo,cPictFob)
   Case cCampo == "TOT_PESO_ANEEXP_PG"   //Campo 11 do Anexo Exportação do Pedido
       Do While (cAlias)->( !EoF() .AND. Eval(bChaveED3) )
          If (cAlias)->ED3_ANEXO == cAnexo
             uValCpo += (cAlias)->ED3_PESO
          EndIf
          
          (cAlias)->(dbSkip())
       EndDo
       
       uValCpo := Transf(uValCpo,cPictPeTot)
   Case cCampo == "TOT_QTD_ANEEXP_PG"    //Campo 12 do Anexo Exportação do Pedido
       aAneQtdTot := {}
       
       Do While (cAlias)->( !EoF() .AND. Eval(bChaveED3) )
          If (cAlias)->ED3_ANEXO
             If (nPos:=aScan(aAneQtdTot,{|x| x[1]==ED3->ED3_UMNCM})) == 0
                aAdd(aAneQtdTot,{ED3->ED3_UMNCM,ED3->ED3_QTDNCM})
             Else
                aAneQtdTot[nPos,2] += ED3->ED3_QTDNCM
             EndIf
          EndIf
          
          (cAlias)->(dbSkip())
       EndDo
       
       uValCpo := ""
       If Len(aAneQtdTot) <= 6
          For i:=1 to Len(aAneQtdTot)
             cUnAne:= aAneQtdTot[i,1]
             If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"UNIDADE_MEDIDA_IMPRESSAO"),)
             
             uValCpo += Alltrim(Transf(aAneQtdTot[i,2],cPictQtde))+"-"+cUnAne+"; "
          Next i
       EndIf
   Case cCampo == "TOT_VALEMB_ANEEXP_PG" //Campo 13 do Anexo Exportação do Pedido
       Do While (cAlias)->( !EoF() .AND. Eval(bChaveED3) )
          If (cAlias)->ED3_ANEXO == cAnexo
             uValCpo += (cAlias)->ED3_VAL_EM
          EndIf
          
          (cAlias)->(dbSkip())
       EndDo
       
       uValCpo := Transf(uValCpo,cPictFob)
End Case

Return uValCpo

Method GeraAditivos() Class EDCAditivo
Local i, cAliasOld, cAliasNew, cCampo, uValorOld, uValorNew, nRecOld, nRecNew
Local cDe, cPara, nPos, cTexto, cValor, nLeftAt, nRightAt, cCampoDe, cCampoPara
Local nNumAditivo, cNumAditivo, cMacro

//Calcula Totais
For i:= 1 To Len(::FieldChanged)
   
   cAliasOld := ::FieldChanged[i][1]
   cAliasNew := ::FieldChanged[i][2]
   cCampo    := ::FieldChanged[i][3]
   uValorOld := ::FieldChanged[i][4]
   uvalorNew := ::FieldChanged[i][5]
   nRecOld   := ::FieldChanged[i][6]
   nRecNew   := ::FieldChanged[i][7]
   
   (cAliasOld)->(dbGoTo(nRecOld))
   
   If cAliasNew <> "M"
      (cAliasNew)->(dbGoTo(nRecNew))
   EndIf
   
   If (i-1)%13 == 0
      RecLock("ED5",.T.)
      ED5->ED5_FILIAL := ::Filial
      ED5->ED5_PD     := ::Pedido
      ED5->ED5_AC     := M->ED0_AC
      ED5->ED5_DT_REG := dDataBase
            
      If cAliasOld == "ED0"
         ED5->ED5_OPCOES := "01"
      Else
         ED5->ED5_OPCOES := "99"
         If cAliasOld == "ED3"
            ED5->ED5_IM_EX  := "E"
            ED5->ED5_SEQSIS := ED3->ED3_SEQSIS
            ED5->ED5_ANEXO  := ED3->ED3_ANEXO
            ED5->ED5_TIPO   := "E"
         ElseIf cAliasOld == "ED4"
            ED5->ED5_IM_EX  := "I"
            ED5->ED5_SEQSIS := ED4->ED4_SEQSIS
            ED5->ED5_ANEXO  := ED4->ED4_ANEXO
            ED5->ED5_TIPO   := "I"
         Endif
      EndIf
   EndIf
   
   nPos := aScan(CAMPOS_ADITIVO,{|X| X[1] == cCampo})
   
   cDe   := CAMPOS_ADITIVO[nPos][3]
   cPara := CAMPOS_ADITIVO[nPos][3]
   
   While (nLeftAt := At("(#",cDe)) > 0
      If (nRightAt := nLeftAt+At("#)",SubStr(cDe,nLeftAt))) > 0
         cTexto := SubStr(cDe,nLeftAt,(nRightAt-nLeftAt+1))
         cMacro := SubStr(cTexto,3,Len(cTexto)-4)
         
         If cTexto == "(#VALOR#)"
            cValor := uValorOld
         Else         
            cValor := (cAliasOld)->( &(cMacro) )
         EndIf
         
         If ValType(cValor) == "N"
            If (cAliasOld)->(FieldPos(cMacro)) > 0
               cValor := Transform(cValor,AvSx3(cMacro,AV_PICTURE))
            Else
               cValor := Str(cValor)
            EndIf
         ElseIf ValType(cValor) <> "C"
            cValor := ""
         EndIf
         cValor := AllTrim(cValor)
         
         cDe := (cAliasOld)->( StrTran(cDe,cTexto,cValor) )
      Else
         EXIT
      EndIf
   EndDo
   
   While (nLeftAt := At("(#",cPara)) > 0
      If (nRightAt := nLeftAt + At("#)",SubStr(cPara,nLeftAt))) > 0
         cTexto := SubStr(cPara,nLeftAt,(nRightAt-nLeftAt+1))
         cMacro := SubStr(cTexto,3,Len(cTexto)-4)
         
         If cTexto == "(#VALOR#)"
            cValor := uValorNew
         Else
            cValor :=(cAliasNew)->( &(cMacro) )
         EndIf
         
         If ValType(cValor) == "N"
            If (cAliasOld)->(FieldPos(cMacro)) > 0
               cValor := Transform(cValor,AvSx3(cMacro,AV_PICTURE))
            Else
               cValor := Str(cValor)
            EndIf
         ElseIf ValType(cValor) <> "C"
            cValor := ""
         EndIf
         cValor := AllTrim(cValor)
         
         cPara := (cAliasNew)->( StrTran(cPara,cTexto,cValor) )
      Else
         EXIT
      EndIf
   EndDo
   
   If (i-1)%13 == 0
      ED5->ED5_DE    := cDe
      ED5->ED5_PARA  := cPara
   Else
      cCampoDe   :="ED5->ED5_DE"+Strzero((i-1)%13,2)
      cCampoPara :="ED5->ED5_PARA"+Strzero((i-1)%13,2)
      
      &cCampoDe  := cDe
      &cCampoPara:= cPara
   EndIf
Next i

ED5->(MsUnlockAll())

Return
