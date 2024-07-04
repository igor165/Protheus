#INCLUDE "LOJA075.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 

Static lUsePayHub := .F. //Variável que controla se o ambiente está atualizado para poder utilizar o Payment Hub / Totvs Pagamento Digital.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LOJA075  º Autor ³Vendas Clientes     º Data ³  08/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de codigos de retorno do TEF para cada bandeira   º±±
±±º          ³ (cartao de credito ou debito) ou Rede Autorizadora         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LOJA075()
Local aCodRet 		:= {}

Private cCadastro 	:= OemToAnsi(STR0001) //"Códigos de Retorno TEF"
Private aRotina 	:= {}

lUsePayHub 	:= ExistFunc("LjUsePayHub") .And. LjUsePayHub()

DbSelectArea("MDE")
MDE->(DbSetOrder(1)) //MDE_FILIAL+MDE_CODIGO
MDE->(DbGoTop())
If MDE->(Eof())
	//Inclui na tabela MDE os retornos do Sitef
	aCodRet := LjRetSitef()
	LJIncMDE(aCodRet,"1")

	//Inclui na tabela MDE os retornos de Pagamentos Digitais
	aCodRet := LjRetPgDig()
	LJIncMDE(aCodRet)
Else
	////Se existir o campo novo, ajusta dados da tabela MDE
	//Se ambiente atualizado para uso do Payment Hub
	If lUsePayHub
		LjAjustMDE()
	EndIf
EndIf

DbSelectArea("MDE")
aRotina := MenuDef()
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('MDE')
oBrowse:SetDescription(OemToAnsi(STR0001)) //"Códigos de Retorno TEF"
oBrowse:Activate()	

Return Nil

//-------------------------------------------------------------------
/* {Protheus.doc} MenuDef
Menu Funcional

@author Vendas & CRM
@since 02/08/2012
@version 11
@return  aRotina - Array com as opcoes de menu

*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRotina        := {}

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"                                          OPERATION 0                                                                                                     ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.LOJA075"     OPERATION MODEL_OPERATION_VIEW         ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.LOJA075"     OPERATION MODEL_OPERATION_INSERT      ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.LOJA075"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.LOJA075"     OPERATION MODEL_OPERATION_DELETE     ACCESS 0 //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/* {Protheus.doc} ModelDef
Definicao do Modelo de dados

@author Vendas & CRM
@since 02/08/2012
@version 11
@return  oModel - Retorna o model com todo o conteudo dos campos preenchido

*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructMDE 	:= FWFormStruct(1,"MDE") 	// Estrutura da tabela MDE
Local oModel 		:= Nil						// Objeto com o modelo de dados

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA075",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("LOJA075_MDE", Nil/*cOwner*/, oStructMDE ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:GetModel("LOJA075_MDE"):SetDescription(STR0001) //"Códigos de Retorno TEF"

Return oModel

//-------------------------------------------------------------------
/* {Protheus.doc} ViewDef
Definicao da Interface do programa.

@author		Vendas & CRM
@version	11
@since 		02/08/2012
@return		oView - Retorna o objeto que representa a interface do programa

*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView  		:= Nil						// Objeto da interface
Local oModel  		:= FWLoadModel("LOJA075")	// Objeto com o modelo de dados
Local oStructMDE 	:= FWFormStruct(2,"MDE")	// Estrutura da tabela SBA

//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)   
oView:EnableControlBar(.T.)  
oView:AddField( "LOJA075_MDE" , oStructMDE )
oView:CreateHorizontalBox( "HEADER" , 100 )
oView:SetOwnerView( "LOJA075_MDE" , "HEADER" )
                
Return oView

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Loja075Valid
Validação da amarração entre Administradora Financeira x Código de Retorno TEF.

@type       Function
@author     Varejo
@since      08/10/2010
@version    11

@return lRet, Lógico, Retorna se a validação foi atendida ou não.
/*/
//-------------------------------------------------------------------------------------
Function Loja075Valid()
Local lRet := .T.

dbSelectArea("MDE")
MDE->(dbSetOrder(1))
If MDE->(dbSeek(xFilial("MDE")+M->AE_ADMCART )) .And. M->AE_TIPO <> MDE->MDE_TIPO
	MsgAlert(STR0007) //"Esse código de retorno não é do mesmo tipo dessa administradora financeira."
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LJIncMDE
Popula tabela MDE.

@type       Function
@author     Varejo
@since      15/04/2013
@version    11

@param aCodRet, Array, Array com a lista de Códigos de Retorno do TEF.

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------
Static Function LJIncMDE( aCodRet )
Local nCont		:= 0  
Local nSaveSx8 	:= GetSx8Len()

INCLUI := .T.

//Carga inicial na tabela MDE
DbSelectArea("MDE")
For nCont := 1 To Len(aCodRet)
	MDE->(RecLock("MDE",.T.))
	MDE->MDE_FILIAL	:= xFilial("MDE")
	MDE->MDE_CODIGO	:= CriaVar("MDE_CODIGO")	
	MDE->MDE_CODSIT	:= aCodRet[nCont,1]
	MDE->MDE_DESC	:= aCodRet[nCont,3]
	MDE->MDE_TIPO	:= aCodRet[nCont,2]
	MDE->(MsUnlock())
Next nCont

While (GetSX8Len() > nSaveSx8)
	ConfirmSx8()
End
                
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjAjustMDE
Ajusta dados da tabela MDE.

@type       Function
@author     Varejo
@since      02/02/2016
@version    11

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------
Static Function LjAjustMDE()
Local aArea 	 := GetArea()
Local aAreaMDE 	 := MDE->(GetArea())
Local lIncAdyen	 := .F. // Controla se deve incluir os retornos da Adyen na tabela MDE 
Local lIncPgDig	 := .F.

//Payment Hub - Verifica se deve incluir os retornos de Pagamentos Digitais na tabela MDE 
lIncPgDig := lUsePayHub .And. ( Empty( GetAdvFVal("MDE", "MDE_CODIGO", xFilial("MDE") + "PD", 3, "", .T.) ) .OR. Empty( GetAdvFVal("MDE", "MDE_CODIGO", xFilial("MDE") + "PX", 3, "", .T.) ) )

If lIncPgDig
	aCodRet := LjRetPgDig()
	LJIncMDE(aCodRet)
EndIf

If lIncAdyen
	aCodRet := LjRetAdyen()
	LJIncMDE(aCodRet)
EndIf

RestArea(aAreaMDE)
RestArea(aArea)

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjRetSitef
Retorna a relação de Códigos de Retorno do SITEF: Bandeiras e Redes Autorizadoras

@type       Function
@author     Alberto Deviciente
@since      06/08/2020
@version    12.1.27

@return aCodRet, Array, Array com a relação de Códigos de Retorno do SITEF.
/*/
//-------------------------------------------------------------------------------------
Static Function LjRetSitef()
Local aCodRet := {}

//--------------------------------------------
//Códigos de Retorno das Bandeiras do Tipo CC
//--------------------------------------------
//             Cod.SiTef, "CC",  Descricao
aAdd( aCodRet, { '00000', 'CC', 'OUTRO'                                    } )
aAdd( aCodRet, { '00001', 'CC', 'VISA'                                     } )
aAdd( aCodRet, { '00002', 'CC', 'MASTERCARD'                               } )
aAdd( aCodRet, { '00003', 'CC', 'DINERS'                                   } )
aAdd( aCodRet, { '00004', 'CC', 'AMEX'                                     } )
aAdd( aCodRet, { '00005', 'CC', 'SOLLO'                                    } )
aAdd( aCodRet, { '00006', 'CC', 'SIDECARD'                                 } )
aAdd( aCodRet, { '00007', 'CC', 'PRIVATE LABEL'                            } )
aAdd( aCodRet, { '00008', 'CC', 'REDESHOP'                                 } )
aAdd( aCodRet, { '00009', 'CC', 'PAO DE ACUCAR'                            } )
aAdd( aCodRet, { '00010', 'CC', 'FININVEST'                                } )
aAdd( aCodRet, { '00011', 'CC', 'JCB'                                      } )
aAdd( aCodRet, { '00012', 'CC', 'HIPERCARD'                                } )
aAdd( aCodRet, { '00013', 'CC', 'AURA'                                     } )
aAdd( aCodRet, { '00014', 'CC', 'LOSANGO'                                  } )
aAdd( aCodRet, { '00015', 'CC', 'SOROCRED'                                 } )
aAdd( aCodRet, { '00030', 'CC', 'CABAL'                                    } )
aAdd( aCodRet, { '00031', 'CC', 'ELO'                                      } )
aAdd( aCodRet, { '00033', 'CC', 'POLICARD'                                 } )
aAdd( aCodRet, { '00035', 'CC', 'BANESCARD'                                } )
aAdd( aCodRet, { '00038', 'CC', 'CETELEM'                                  } )
aAdd( aCodRet, { '00041', 'CC', 'SICREDI'                                  } )
aAdd( aCodRet, { '00043', 'CC', 'COOPERCRED'                               } )
aAdd( aCodRet, { '00045', 'CC', 'A VISTA'                                  } )
aAdd( aCodRet, { '00057', 'CC', 'CREDISYSTEM'                              } )
aAdd( aCodRet, { '00058', 'CC', 'BANPARA'                                  } )
aAdd( aCodRet, { '00060', 'CC', 'AMAZONCARD'                               } )
aAdd( aCodRet, { '00061', 'CC', 'YAMADA'                                   } )
aAdd( aCodRet, { '00062', 'CC', 'GOIASCARD'                                } )
aAdd( aCodRet, { '00063', 'CC', 'CREDPAR'                                  } )
aAdd( aCodRet, { '00064', 'CC', 'BOTICARIO'                                } )
aAdd( aCodRet, { '00065', 'CC', 'ASCARD'                                   } )
aAdd( aCodRet, { '00066', 'CC', 'JETPAR'                                   } )
aAdd( aCodRet, { '00067', 'CC', 'MAXXCARD'                                 } )
aAdd( aCodRet, { '00068', 'CC', 'GARANTIDO'                                } )
aAdd( aCodRet, { '00069', 'CC', 'AMAZON PRIME'                             } )
aAdd( aCodRet, { '00070', 'CC', 'CREDZ'                                    } )
aAdd( aCodRet, { '00071', 'CC', 'CREDISHOP'                                } )

//--------------------------------------------
//Códigos de Retorno das Bandeiras do Tipo CD
//--------------------------------------------
//             Cod.SiTef, "CC",  Descricao
aAdd( aCodRet, { '00000', 'CD', 'DEBITO GENERICO'                          } )
aAdd( aCodRet, { '00001', 'CD', 'VOUCHER GENERICO'                         } )
aAdd( aCodRet, { '00003', 'CD', 'GIFT PRE-PAGO'                            } )
aAdd( aCodRet, { '10001', 'CD', 'TICKET'                                   } )
aAdd( aCodRet, { '10002', 'CD', 'VISAVALE'                                 } )
aAdd( aCodRet, { '10003', 'CD', 'SODEXO'                                   } )
aAdd( aCodRet, { '10004', 'CD', 'NUTRICASH'                                } )
aAdd( aCodRet, { '10005', 'CD', 'GREENCARD'                                } )
aAdd( aCodRet, { '10006', 'CD', 'PLANVALE'                                 } )
aAdd( aCodRet, { '10007', 'CD', 'BANQUET'                                  } )
aAdd( aCodRet, { '10008', 'CD', 'VEROCHEQUE'                               } )
aAdd( aCodRet, { '10009', 'CD', 'SAPORE'                                   } )
aAdd( aCodRet, { '10010', 'CD', 'BNB CLUBE'                                } )
aAdd( aCodRet, { '10011', 'CD', 'VALECARD'                                 } )
aAdd( aCodRet, { '10012', 'CD', 'CABAL'                                    } )
aAdd( aCodRet, { '10013', 'CD', 'ELO'                                      } )
aAdd( aCodRet, { '10014', 'CD', 'DISCOVERY'                                } )
aAdd( aCodRet, { '10015', 'CD', 'GOODCARD'                                 } )
aAdd( aCodRet, { '10016', 'CD', 'POLICARD'                                 } )
aAdd( aCodRet, { '10017', 'CD', 'CARDSYSTEM'                               } )
aAdd( aCodRet, { '10018', 'CD', 'BONUS CBA'                                } )
aAdd( aCodRet, { '10019', 'CD', 'ALELO'                                    } )
aAdd( aCodRet, { '10020', 'CD', 'BANESCARD'                                } )
aAdd( aCodRet, { '10021', 'CD', 'ALELO (REFEICAO)'                         } )
aAdd( aCodRet, { '10022', 'CD', 'ALELO (ALIMENTACAO)'                      } )
aAdd( aCodRet, { '10023', 'CD', 'ALELO (CULTURA)'                          } )
aAdd( aCodRet, { '10024', 'CD', 'TICKET (REFEICAO)'                        } )
aAdd( aCodRet, { '10025', 'CD', 'TICKET (ALIMENTACAO)'                     } )
aAdd( aCodRet, { '10026', 'CD', 'TICKET (PARCEIRO)'                        } )
aAdd( aCodRet, { '10027', 'CD', 'TICKET (CULTURA)'                         } )
aAdd( aCodRet, { '10028', 'CD', 'SODEXO (REFEICAO)'                        } )
aAdd( aCodRet, { '10029', 'CD', 'SODEXO (ALIMENTACAO)'                     } )
aAdd( aCodRet, { '10030', 'CD', 'SODEXO (GIFT)'                            } )
aAdd( aCodRet, { '10031', 'CD', 'SODEXO (PREMIUM)'                         } )
aAdd( aCodRet, { '10032', 'CD', 'SODEXO (CULTURA)'                         } )
aAdd( aCodRet, { '10033', 'CD', 'SODEXO (COMBUSTIVEL)'                     } )
aAdd( aCodRet, { '10051', 'CD', 'PLANVALE (CULTURA)'                       } )
aAdd( aCodRet, { '10053', 'CD', 'NUTRICASH (CULTURA)'                      } )
aAdd( aCodRet, { '10054', 'CD', 'TICKET (COMBUSTIVEL)'                     } )
aAdd( aCodRet, { '10055', 'CD', 'VALECARD (CULTURA)'                       } )
aAdd( aCodRet, { '20001', 'CD', 'MAESTRO'                                  } )
aAdd( aCodRet, { '20002', 'CD', 'VISA ELECTRON'                            } )
aAdd( aCodRet, { '20003', 'CD', 'CABAL'                                    } )
aAdd( aCodRet, { '20012', 'CD', 'CABAL'                                    } )
aAdd( aCodRet, { '20013', 'CD', 'ELO'                                      } )
aAdd( aCodRet, { '20032', 'CD', 'ELO'                                      } )
aAdd( aCodRet, { '20034', 'CD', 'POLICARD'                                 } )
aAdd( aCodRet, { '20036', 'CD', 'BANESCARD'                                } )
aAdd( aCodRet, { '10037', 'CD', 'SOROCRED'                                 } )
aAdd( aCodRet, { '20037', 'CD', 'HIPERCARD'                                } )
aAdd( aCodRet, { '10039', 'CD', 'VALEMULTI'                                } )
aAdd( aCodRet, { '10040', 'CD', 'VALEFROTA'                                } )
aAdd( aCodRet, { '20042', 'CD', 'SICREDI'                                  } )
aAdd( aCodRet, { '10044', 'CD', 'COOPERCRED'                               } )
aAdd( aCodRet, { '10046', 'CD', 'VALE FACIL'                               } )
aAdd( aCodRet, { '10047', 'CD', 'VR (REFEICAO)'                            } )
aAdd( aCodRet, { '10048', 'CD', 'VR (ALIMENTACAO)'                         } )
aAdd( aCodRet, { '10049', 'CD', 'VR (COMBUSTIVEL)'                         } )
aAdd( aCodRet, { '10050', 'CD', 'VR (CULTURA)'                             } )
aAdd( aCodRet, { '10052', 'CD', 'BANRISUL (CULTURA)'                       } )
aAdd( aCodRet, { '20059', 'CD', 'BANPARA'                                  } )
aAdd( aCodRet, { '10070', 'CD', 'VR (BENEFICIO)'                           } )
aAdd( aCodRet, { '10071', 'CD', 'PLANVALE (BENEFICIO)'                     } )
aAdd( aCodRet, { '20071', 'CD', 'SOROCRED'                                 } )
aAdd( aCodRet, { '10072', 'CD', 'PLANVALE (ALIMENTACAO)'                   } )
aAdd( aCodRet, { '10073', 'CD', 'PLANVALE (REFEICAO)'                      } )
aAdd( aCodRet, { '10074', 'CD', 'PLANVALE (COMBUSTIVEL)'                   } )
aAdd( aCodRet, { '10075', 'CD', 'PLANVALE (FARMACIA)'                      } )

//----------------------------------------------------
//Códigos de Retorno da Rede Autorizadora (Adquirente)
//----------------------------------------------------
//             Cod.SiTef, "RD",  Descricao
aAdd( aCodRet, { '00000', 'RD', 'OUTRA'                                    } )
aAdd( aCodRet, { '00001', 'RD', 'TECBAN'                                   } )
aAdd( aCodRet, { '00002', 'RD', 'ITAU'                                     } )
aAdd( aCodRet, { '00003', 'RD', 'BRADESCO'                                 } )
aAdd( aCodRet, { '00004', 'RD', 'VISANET - ESPECIFICACAO 200001'           } )
aAdd( aCodRet, { '00005', 'RD', 'REDECARD'                                 } )
aAdd( aCodRet, { '00006', 'RD', 'AMEX'                                     } )
aAdd( aCodRet, { '00007', 'RD', 'SOLLO'                                    } )
aAdd( aCodRet, { '00008', 'RD', 'E CAPTURE'                                } )
aAdd( aCodRet, { '00009', 'RD', 'SERASA'                                   } )
aAdd( aCodRet, { '00010', 'RD', 'SPC BRASIL'                               } )
aAdd( aCodRet, { '00011', 'RD', 'SERASA DETALHADO'                         } )
aAdd( aCodRet, { '00012', 'RD', 'TELEDATA'                                 } )
aAdd( aCodRet, { '00013', 'RD', 'ACSP'                                     } )
aAdd( aCodRet, { '00014', 'RD', 'ACSP DETALHADO'                           } )
aAdd( aCodRet, { '00015', 'RD', 'TECBIZ'                                   } )
aAdd( aCodRet, { '00016', 'RD', 'CDL DF'                                   } )
aAdd( aCodRet, { '00017', 'RD', 'REPOM'                                    } )
aAdd( aCodRet, { '00018', 'RD', 'STANDBY'                                  } )
aAdd( aCodRet, { '00019', 'RD', 'EDMCARD'                                  } )
aAdd( aCodRet, { '00020', 'RD', 'CREDICESTA'                               } )
aAdd( aCodRet, { '00021', 'RD', 'BANRISUL'                                 } )
aAdd( aCodRet, { '00022', 'RD', 'ACC CARD'                                 } )
aAdd( aCodRet, { '00023', 'RD', 'CLUBCARD'                                 } )
aAdd( aCodRet, { '00024', 'RD', 'ACPR'                                     } )
aAdd( aCodRet, { '00025', 'RD', 'VIDALINK'                                 } )
aAdd( aCodRet, { '00026', 'RD', 'CCC_WEB'                                  } )
aAdd( aCodRet, { '00027', 'RD', 'EDIGUAY'                                  } )
aAdd( aCodRet, { '00028', 'RD', 'CARREFOUR'                                } )
aAdd( aCodRet, { '00029', 'RD', 'SOFTWAY'                                  } )
aAdd( aCodRet, { '00030', 'RD', 'MULTICHEQUE'                              } )
aAdd( aCodRet, { '00031', 'RD', 'TICKET COMBUSTIVEL'                       } )
aAdd( aCodRet, { '00032', 'RD', 'YAMADA'                                   } )
aAdd( aCodRet, { '00033', 'RD', 'CITIBANK'                                 } )
aAdd( aCodRet, { '00034', 'RD', 'INFOCARD'                                 } )
aAdd( aCodRet, { '00035', 'RD', 'BESC'                                     } )
aAdd( aCodRet, { '00036', 'RD', 'EMS'                                      } )
aAdd( aCodRet, { '00037', 'RD', 'CHEQUE CASH'                              } )
aAdd( aCodRet, { '00038', 'RD', 'CENTRAL CARD'                             } )
aAdd( aCodRet, { '00039', 'RD', 'DROGARAIA'                                } )
aAdd( aCodRet, { '00040', 'RD', 'OUTRO SERVICO'                            } )
aAdd( aCodRet, { '00041', 'RD', 'ACCOR'                                    } )
aAdd( aCodRet, { '00042', 'RD', 'EPAY GIFT'                                } )
aAdd( aCodRet, { '00043', 'RD', 'PARATI'                                   } )
aAdd( aCodRet, { '00044', 'RD', 'TOKORO'                                   } )
aAdd( aCodRet, { '00045', 'RD', 'COOPERCRED'                               } )
aAdd( aCodRet, { '00046', 'RD', 'SERVCEL'                                  } )
aAdd( aCodRet, { '00047', 'RD', 'SOROCRED'                                 } )
aAdd( aCodRet, { '00048', 'RD', 'VITAL'                                    } )
aAdd( aCodRet, { '00049', 'RD', 'SAX FINANCEIRA'                           } )
aAdd( aCodRet, { '00050', 'RD', 'FORMOSA'                                  } )
aAdd( aCodRet, { '00051', 'RD', 'HIPERCARD'                                } )
aAdd( aCodRet, { '00052', 'RD', 'TRICARD'                                  } )
aAdd( aCodRet, { '00053', 'RD', 'CHECK OK'                                 } )
aAdd( aCodRet, { '00054', 'RD', 'POLICARD'                                 } )
aAdd( aCodRet, { '00055', 'RD', 'CETELEM CARREFOUR'                        } )
aAdd( aCodRet, { '00056', 'RD', 'LEADER'                                   } )
aAdd( aCodRet, { '00057', 'RD', 'CONSORCIO CREDICARD VENEZUELA'            } )
aAdd( aCodRet, { '00058', 'RD', 'GAZINCRED'                                } )
aAdd( aCodRet, { '00059', 'RD', 'TELENET'                                  } )
aAdd( aCodRet, { '00060', 'RD', 'CHEQUE PRE'                               } )
aAdd( aCodRet, { '00061', 'RD', 'BRASIL CARD'                              } )
aAdd( aCodRet, { '00062', 'RD', 'EPHARMA'                                  } )
aAdd( aCodRet, { '00063', 'RD', 'TOTAL'                                    } )
aAdd( aCodRet, { '00064', 'RD', 'CONSORCIO AMEX VENEZUELA'                 } )
aAdd( aCodRet, { '00065', 'RD', 'GAX'                                      } )
aAdd( aCodRet, { '00066', 'RD', 'PERALTA'                                  } )
aAdd( aCodRet, { '00067', 'RD', 'SERVIDOR PAGAMENTO'                       } )
aAdd( aCodRet, { '00068', 'RD', 'BANESE'                                   } )
aAdd( aCodRet, { '00069', 'RD', 'RESOMAQ'                                  } )
aAdd( aCodRet, { '00070', 'RD', 'SYSDATA'                                  } )
aAdd( aCodRet, { '00071', 'RD', 'CDL POA'                                  } )
aAdd( aCodRet, { '00072', 'RD', 'BIGCARD'                                  } )
aAdd( aCodRet, { '00073', 'RD', 'DTRANSFER'                                } )
aAdd( aCodRet, { '00074', 'RD', 'VIAVAREJO'                                } )
aAdd( aCodRet, { '00075', 'RD', 'CHECK EXPRESS'                            } )
aAdd( aCodRet, { '00076', 'RD', 'GIVEX'                                    } )
aAdd( aCodRet, { '00077', 'RD', 'VALECARD'                                 } )
aAdd( aCodRet, { '00078', 'RD', 'PORTAL CARD'                              } )
aAdd( aCodRet, { '00079', 'RD', 'BANPARA'                                  } )
aAdd( aCodRet, { '00080', 'RD', 'SOFTNEX'                                  } )
aAdd( aCodRet, { '00081', 'RD', 'SUPERCARD'                                } )
aAdd( aCodRet, { '00082', 'RD', 'GETNET'                                   } )
aAdd( aCodRet, { '00083', 'RD', 'PREVSAUDE'                                } )
aAdd( aCodRet, { '00084', 'RD', 'BANCO POTTENCIAL'                         } )
aAdd( aCodRet, { '00085', 'RD', 'SOPHUS'                                   } )
aAdd( aCodRet, { '00086', 'RD', 'MARISA 2'                                 } )
aAdd( aCodRet, { '00087', 'RD', 'MAXICRED'                                 } )
aAdd( aCodRet, { '00088', 'RD', 'BLACKHAWK'                                } )
aAdd( aCodRet, { '00089', 'RD', 'EXPANSIVA'                                } )
aAdd( aCodRet, { '00090', 'RD', 'SAS NT'                                   } )
aAdd( aCodRet, { '00091', 'RD', 'LEADER 2'                                 } )
aAdd( aCodRet, { '00092', 'RD', 'SOMAR'                                    } )
aAdd( aCodRet, { '00093', 'RD', 'CETELEM AURA'                             } )
aAdd( aCodRet, { '00094', 'RD', 'CABAL'                                    } )
aAdd( aCodRet, { '00095', 'RD', 'CREDSYSTEM'                               } )
aAdd( aCodRet, { '00096', 'RD', 'BANCO PROVINCIAL'                         } )
aAdd( aCodRet, { '00097', 'RD', 'CARTESYS'                                 } )
aAdd( aCodRet, { '00098', 'RD', 'CISA'                                     } )
aAdd( aCodRet, { '00099', 'RD', 'TRNCENTRE'                                } )
aAdd( aCodRet, { '00100', 'RD', 'ACPR D'                                   } )
aAdd( aCodRet, { '00101', 'RD', 'CARDCO'                                   } )
aAdd( aCodRet, { '00102', 'RD', 'CHECK CHECK'                              } )
aAdd( aCodRet, { '00103', 'RD', 'CADASA'                                   } )
aAdd( aCodRet, { '00104', 'RD', 'PRIVATE BRADESCO'                         } )
aAdd( aCodRet, { '00105', 'RD', 'CREDMAIS'                                 } )
aAdd( aCodRet, { '00106', 'RD', 'GWCEL'                                    } )
aAdd( aCodRet, { '00107', 'RD', 'CHECK EXPRESS 2'                          } )
aAdd( aCodRet, { '00108', 'RD', 'GETNET PBM'                               } )
aAdd( aCodRet, { '00109', 'RD', 'USECRED'                                  } )
aAdd( aCodRet, { '00110', 'RD', 'SERV VOUCHER'                             } )
aAdd( aCodRet, { '00111', 'RD', 'TREDENEXX'                                } )
aAdd( aCodRet, { '00112', 'RD', 'BONUS PRESENTE CARREFOUR'                 } )
aAdd( aCodRet, { '00113', 'RD', 'CREDISHOP'                                } )
aAdd( aCodRet, { '00114', 'RD', 'ESTAPAR'                                  } )
aAdd( aCodRet, { '00115', 'RD', 'BANCO IBI'                                } )
aAdd( aCodRet, { '00116', 'RD', 'WORKERCARD'                               } )
aAdd( aCodRet, { '00117', 'RD', 'TELECHEQUE'                               } )
aAdd( aCodRet, { '00118', 'RD', 'OBOE'                                     } )
aAdd( aCodRet, { '00119', 'RD', 'PROTEGE'                                  } )
aAdd( aCodRet, { '00120', 'RD', 'SERASA CARDS'                             } )
aAdd( aCodRet, { '00121', 'RD', 'HOTCARD'                                  } )
aAdd( aCodRet, { '00122', 'RD', 'BANCO PANAMERICANO'                       } )
aAdd( aCodRet, { '00123', 'RD', 'BANCO MERCANTIL'                          } )
aAdd( aCodRet, { '00124', 'RD', 'SIGACRED'                                 } )
aAdd( aCodRet, { '00125', 'RD', 'VISANET - ESPECIFICACAO 4.1'              } )
aAdd( aCodRet, { '00126', 'RD', 'SPTRANS'                                  } )
aAdd( aCodRet, { '00127', 'RD', 'PRESENTE MARISA'                          } )
aAdd( aCodRet, { '00128', 'RD', 'COOPLIFE'                                 } )
aAdd( aCodRet, { '00129', 'RD', 'BOD'                                      } )
aAdd( aCodRet, { '00130', 'RD', 'G CARD'                                   } )
aAdd( aCodRet, { '00131', 'RD', 'TCREDIT'                                  } )
aAdd( aCodRet, { '00132', 'RD', 'SISCRED'                                  } )
aAdd( aCodRet, { '00133', 'RD', 'FOXWINCARDS'                              } )
aAdd( aCodRet, { '00134', 'RD', 'CONVCARD'                                 } )
aAdd( aCodRet, { '00135', 'RD', 'VOUCHER'                                  } )
aAdd( aCodRet, { '00136', 'RD', 'EXPAND CARDS'                             } )
aAdd( aCodRet, { '00137', 'RD', 'ULTRAGAZ'                                 } )
aAdd( aCodRet, { '00138', 'RD', 'QUALICARD'                                } )
aAdd( aCodRet, { '00139', 'RD', 'HSBC UK'                                  } )
aAdd( aCodRet, { '00140', 'RD', 'WAPPA'                                    } )
aAdd( aCodRet, { '00141', 'RD', 'SQCF'                                     } )
aAdd( aCodRet, { '00142', 'RD', 'INTELLISYS'                               } )
aAdd( aCodRet, { '00143', 'RD', 'BOD DEBITO'                               } )
aAdd( aCodRet, { '00144', 'RD', 'ACCREDITO'                                } )
aAdd( aCodRet, { '00145', 'RD', 'COMPROCARD'                               } )
aAdd( aCodRet, { '00146', 'RD', 'ORGCARD'                                  } )
aAdd( aCodRet, { '00147', 'RD', 'MINASCRED'                                } )
aAdd( aCodRet, { '00148', 'RD', 'FARMACIA POPULAR'                         } )
aAdd( aCodRet, { '00149', 'RD', 'FIDELIDADE MAIS'                          } )
aAdd( aCodRet, { '00150', 'RD', 'ITAU SHOPLINE'                            } )
aAdd( aCodRet, { '00151', 'RD', 'CDL RIO'                                  } )
aAdd( aCodRet, { '00152', 'RD', 'FORTCARD'                                 } )
aAdd( aCodRet, { '00153', 'RD', 'PAGGO'                                    } )
aAdd( aCodRet, { '00154', 'RD', 'SMARTNET'                                 } )
aAdd( aCodRet, { '00155', 'RD', 'INTERFARMACIA'                            } )
aAdd( aCodRet, { '00156', 'RD', 'VALECON'                                  } )
aAdd( aCodRet, { '00157', 'RD', 'CARTAO EVANGELICO'                        } )
aAdd( aCodRet, { '00158', 'RD', 'VEGASCARD'                                } )
aAdd( aCodRet, { '00159', 'RD', 'SCCARD'                                   } )
aAdd( aCodRet, { '00160', 'RD', 'ORBITALL'                                 } )
aAdd( aCodRet, { '00161', 'RD', 'ICARDS'                                   } )
aAdd( aCodRet, { '00162', 'RD', 'FACILCARD'                                } )
aAdd( aCodRet, { '00163', 'RD', 'FIDELIZE'                                 } )
aAdd( aCodRet, { '00164', 'RD', 'FINAMAX'                                  } )
aAdd( aCodRet, { '00165', 'RD', 'BANCO GE'                                 } )
aAdd( aCodRet, { '00166', 'RD', 'UNIK'                                     } )
aAdd( aCodRet, { '00167', 'RD', 'TIVIT'                                    } )
aAdd( aCodRet, { '00168', 'RD', 'VALIDATA'                                 } )
aAdd( aCodRet, { '00169', 'RD', 'BANESCARD'                                } )
aAdd( aCodRet, { '00170', 'RD', 'CSU CARREFOUR'                            } )
aAdd( aCodRet, { '00171', 'RD', 'VALESHOP'                                 } )
aAdd( aCodRet, { '00172', 'RD', 'SOMAR CARD'                               } )
aAdd( aCodRet, { '00173', 'RD', 'OMNION'                                   } )
aAdd( aCodRet, { '00174', 'RD', 'CONDOR'                                   } )
aAdd( aCodRet, { '00175', 'RD', 'STANDBYDUP'                               } )
aAdd( aCodRet, { '00176', 'RD', 'BPAG BOLDCRON'                            } )
aAdd( aCodRet, { '00177', 'RD', 'MARISA SAX SYSIN'                         } )
aAdd( aCodRet, { '00178', 'RD', 'STARFICHE'                                } )
aAdd( aCodRet, { '00179', 'RD', 'ACE SEGUROS'                              } )
aAdd( aCodRet, { '00180', 'RD', 'TOP CARD'                                 } )
aAdd( aCodRet, { '00181', 'RD', 'GETNET LAC'                               } )
aAdd( aCodRet, { '00182', 'RD', 'UP SIGHT'                                 } )
aAdd( aCodRet, { '00183', 'RD', 'MAR'                                      } )
aAdd( aCodRet, { '00184', 'RD', 'FUNCIONAL CARD'                           } )
aAdd( aCodRet, { '00185', 'RD', 'PHARMA SYSTEM'                            } )
aAdd( aCodRet, { '00186', 'RD', 'NEUS'                                     } )
aAdd( aCodRet, { '00187', 'RD', 'SICREDI'                                  } )
aAdd( aCodRet, { '00188', 'RD', 'ESCALENA'                                 } )
aAdd( aCodRet, { '00189', 'RD', 'N SERVICOS'                               } )
aAdd( aCodRet, { '00190', 'RD', 'CSF CARREFOUR'                            } )
aAdd( aCodRet, { '00191', 'RD', 'ATP'                                      } )
aAdd( aCodRet, { '00192', 'RD', 'AVST'                                     } )
aAdd( aCodRet, { '00193', 'RD', 'ALGORIX'                                  } )
aAdd( aCodRet, { '00194', 'RD', 'AMEX EMV'                                 } )
aAdd( aCodRet, { '00195', 'RD', 'COMPREMAX'                                } )
aAdd( aCodRet, { '00196', 'RD', 'LIBERCARD'                                } )
aAdd( aCodRet, { '00197', 'RD', 'SEICON'                                   } )
aAdd( aCodRet, { '00198', 'RD', 'SERASA AUTORIZ CREDITO'                   } )
aAdd( aCodRet, { '00199', 'RD', 'SMARTN'                                   } )
aAdd( aCodRet, { '00200', 'RD', 'PLATCO'                                   } )
aAdd( aCodRet, { '00201', 'RD', 'SMARTNET EMV'                             } )
aAdd( aCodRet, { '00202', 'RD', 'PROSA MEXICO'                             } )
aAdd( aCodRet, { '00203', 'RD', 'PEELA'                                    } )
aAdd( aCodRet, { '00204', 'RD', 'NUTRIK'                                   } )
aAdd( aCodRet, { '00205', 'RD', 'GOLDENFARMA PBM'                          } )
aAdd( aCodRet, { '00206', 'RD', 'GLOBAL PAYMENTS'                          } )
aAdd( aCodRet, { '00207', 'RD', 'ELAVON'                                   } )
aAdd( aCodRet, { '00208', 'RD', 'CTF'                                      } )
aAdd( aCodRet, { '00209', 'RD', 'BANESTIK'                                 } )
aAdd( aCodRet, { '00210', 'RD', 'VISA ARG'                                 } )
aAdd( aCodRet, { '00211', 'RD', 'AMEX ARG'                                 } )
aAdd( aCodRet, { '00212', 'RD', 'POSNET ARG'                               } )
aAdd( aCodRet, { '00213', 'RD', 'AMEX MEXICO'                              } )
aAdd( aCodRet, { '00214', 'RD', 'ELETROZEMA'                               } )
aAdd( aCodRet, { '00215', 'RD', 'BARIGUI'                                  } )
aAdd( aCodRet, { '00216', 'RD', 'SIMEC'                                    } )
aAdd( aCodRet, { '00217', 'RD', 'SGF'                                      } )
aAdd( aCodRet, { '00218', 'RD', 'HUG'                                      } )
aAdd( aCodRet, { '00219', 'RD', 'CARTAO METTACARD'                         } )
aAdd( aCodRet, { '00220', 'RD', 'DDTOTAL'                                  } )
aAdd( aCodRet, { '00221', 'RD', 'CARTAO QUALIDADE'                         } )
aAdd( aCodRet, { '00222', 'RD', 'REDECONV'                                 } )
aAdd( aCodRet, { '00223', 'RD', 'NUTRICARD'                                } )
aAdd( aCodRet, { '00224', 'RD', 'DOTZ'                                     } )
aAdd( aCodRet, { '00225', 'RD', 'PREMIACOES RAIZEN'                        } )
aAdd( aCodRet, { '00226', 'RD', 'TROCO SOLIDARIO'                          } )
aAdd( aCodRet, { '00227', 'RD', 'AMBEV SOCIO TORCEDOR'                     } )
aAdd( aCodRet, { '00228', 'RD', 'SEMPRE'                                   } )
aAdd( aCodRet, { '00229', 'RD', 'FIRST DATA'                               } )
aAdd( aCodRet, { '00230', 'RD', 'COCIPA'                                   } )
aAdd( aCodRet, { '00231', 'RD', 'IBI MEXICO'                               } )
aAdd( aCodRet, { '00232', 'RD', 'SIANET'                                   } )
aAdd( aCodRet, { '00233', 'RD', 'SGCARDS'                                  } )
aAdd( aCodRet, { '00234', 'RD', 'CIAGROUP'                                 } )
aAdd( aCodRet, { '00235', 'RD', 'FILLIP'                                   } )
aAdd( aCodRet, { '00236', 'RD', 'CONDUCTOR'                                } )
aAdd( aCodRet, { '00237', 'RD', 'LTM RAIZEN'                               } )
aAdd( aCodRet, { '00238', 'RD', 'INCOMM'                                   } )
aAdd( aCodRet, { '00239', 'RD', 'VISA PASS FIRST'                          } )
aAdd( aCodRet, { '00240', 'RD', 'CENCOSUD'                                 } )
aAdd( aCodRet, { '00241', 'RD', 'HIPERLIFE'                                } )
aAdd( aCodRet, { '00242', 'RD', 'SITPOS'                                   } )
aAdd( aCodRet, { '00243', 'RD', 'AGT'                                      } )
aAdd( aCodRet, { '00244', 'RD', 'MIRA'                                     } )
aAdd( aCodRet, { '00245', 'RD', 'AMBEV 2 SOCIO TORCEDOR'                   } )
aAdd( aCodRet, { '00246', 'RD', 'JGV'                                      } )
aAdd( aCodRet, { '00247', 'RD', 'CREDSAT'                                  } )
aAdd( aCodRet, { '00248', 'RD', 'BRAZILIAN CARD'                           } )
aAdd( aCodRet, { '00249', 'RD', 'RIACHUELO'                                } )
aAdd( aCodRet, { '00250', 'RD', 'ITS RAIZEN'                               } )
aAdd( aCodRet, { '00251', 'RD', 'SIMCRED'                                  } )
aAdd( aCodRet, { '00252', 'RD', 'BANCRED CARD'                             } )
aAdd( aCodRet, { '00253', 'RD', 'CONEKTA'                                  } )
aAdd( aCodRet, { '00254', 'RD', 'SOFTCARD'                                 } )
aAdd( aCodRet, { '00255', 'RD', 'ECOPAG'                                   } )
aAdd( aCodRet, { '00256', 'RD', 'C&A AUTOMACAO IBI'                        } )
aAdd( aCodRet, { '00257', 'RD', 'C&A PARCERIAS BRADESCARD'                 } )
aAdd( aCodRet, { '00258', 'RD', 'OGLOBA'                                   } )
aAdd( aCodRet, { '00259', 'RD', 'BANESE VOUCHER'                           } )
aAdd( aCodRet, { '00260', 'RD', 'RAPP'                                     } )
aAdd( aCodRet, { '00261', 'RD', 'MONITORA POS'                             } )
aAdd( aCodRet, { '00262', 'RD', 'SOLLUS'                                   } )
aAdd( aCodRet, { '00263', 'RD', 'FITCARD'                                  } )
aAdd( aCodRet, { '00264', 'RD', 'ADIANTI'                                  } )
aAdd( aCodRet, { '00265', 'RD', 'STONE'                                    } )
aAdd( aCodRet, { '00266', 'RD', 'DMCARD'                                   } )
aAdd( aCodRet, { '00267', 'RD', 'ICATU 2'                                  } )
aAdd( aCodRet, { '00268', 'RD', 'FARMASEG'                                 } )
aAdd( aCodRet, { '00269', 'RD', 'BIZ'                                      } )
aAdd( aCodRet, { '00270', 'RD', 'SEMPARAR RAIZEN'                          } )
aAdd( aCodRet, { '00272', 'RD', 'PBM GLOBAL'                               } )
aAdd( aCodRet, { '00273', 'RD', 'PAYSMART'                                 } )
aAdd( aCodRet, { '00275', 'RD', 'ONEBOX'                                   } )
aAdd( aCodRet, { '00276', 'RD', 'CARTO'                                    } )
aAdd( aCodRet, { '00277', 'RD', 'WAYUP'                                    } )

Return aCodRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjRetAdyen
Retorna a relação de Códigos de Retorno de Bandeiras da Adyen.

@type       Function
@author     Alberto Deviciente
@since      06/08/2020
@version    12.1.27

@return aCodRet, Array, Array com a relação de Códigos de Retorno da Adyen.
/*/
//-------------------------------------------------------------------------------------
Static Function LjRetAdyen()
Local aCodRet := {}

//------------------------------------------------------------------------------------------------------------------------------------
//Os retornos abaixo estão listados no endereço do portal da Adyen: https://docs.adyen.com/development-resources/paymentmethodvariant
//------------------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------
//Códigos de Retorno das Bandeiras do Tipo CC
//--------------------------------------------
//             		Cod. Retorno Adyen				, "CC",  Descricao
aAdd( aCodRet, { 'mc'    							, 'CC', 'Mastercard card (not classified)'      	} )
aAdd( aCodRet, { 'mccredit'    						, 'CC', 'Mastercard credit card (not classified)'	} )
aAdd( aCodRet, { 'mcstandardcredit'    				, 'CC', 'Mastercard standard credit card'      		} )
aAdd( aCodRet, { 'mcpremiumcredit'    				, 'CC', 'Mastercard premium credit card'      		} )
aAdd( aCodRet, { 'mcsuperpremiumcredit'    			, 'CC', 'Mastercard super premium credit card'      } )
aAdd( aCodRet, { 'mccommercialcredit'    			, 'CC', 'Mastercard commercial credit card'      	} )
aAdd( aCodRet, { 'mccommercialpremiumcredit'    	, 'CC', 'Mastercard commercial premium credit card'	} )
aAdd( aCodRet, { 'mccorporatecredit'    			, 'CC', 'Mastercard corporate credit card'      	} )
aAdd( aCodRet, { 'mcpurchasingcredit'    			, 'CC', 'Mastercard purchasing credit card'      	} )
aAdd( aCodRet, { 'mcfleetcredit'    				, 'CC', 'Mastercard fleet credit card'      		} )
aAdd( aCodRet, { 'visa'    							, 'CC', 'Visa card (not classified)'      			} )
aAdd( aCodRet, { 'visacredit'    					, 'CC', 'Visa credit card (not classified)'      	} )
aAdd( aCodRet, { 'visastandardcredit'    			, 'CC', 'Visa standard credit card'     	 		} )
aAdd( aCodRet, { 'visapremiumcredit'    			, 'CC', 'Visa premium credit card'     		 		} )
aAdd( aCodRet, { 'visasuperpremiumcredit'    		, 'CC', 'Visa super premium credit card'      		} )
aAdd( aCodRet, { 'visacommercialcredit'    			, 'CC', 'Visa commercial credit card'      			} )
aAdd( aCodRet, { 'visacommercialpremiumcredit'    	, 'CC', 'Visa commercial premium credit card'      	} )
aAdd( aCodRet, { 'visacommercialsuperpremiumcredit'	, 'CC', 'Visa commercial super premium credit card'	} )
aAdd( aCodRet, { 'visacorporatecredit'    			, 'CC', 'Visa corporate credit card'      			} )
aAdd( aCodRet, { 'visapurchasingcredit'    			, 'CC', 'Visa purchasing credit card'     	 		} )
aAdd( aCodRet, { 'visafleetcredit'    				, 'CC', 'Visa fleet credit card'      				} )
aAdd( aCodRet, { 'amex'    							, 'CC', 'Amex card'      							} )
aAdd( aCodRet, { 'diners'    						, 'CC', 'Diners card'     		 					} )


//--------------------------------------------
//Códigos de Retorno das Bandeiras do Tipo CD
//--------------------------------------------
//             		Cod. Retorno Adyen				, "CD",  Descricao
aAdd( aCodRet, { 'mc'    							, 'CD', 'Mastercard card (not classified)'      	} )
aAdd( aCodRet, { 'mcdebit'    						, 'CD', 'Mastercard debit card (not classified)'	} )
aAdd( aCodRet, { 'mcstandarddebit'    				, 'CD', 'Mastercard standard debit card'      		} )
aAdd( aCodRet, { 'mcpremiumdebit'    				, 'CD', 'Mastercard premium debit card'      		} )
aAdd( aCodRet, { 'mcsuperpremiumdebit'    			, 'CD', 'Mastercard super premium debit card'      	} )
aAdd( aCodRet, { 'mccommercialdebit'    			, 'CD', 'Mastercard commercial debit card'      	} )
aAdd( aCodRet, { 'mccommercialpremiumdebit'    		, 'CD', 'Mastercard commercial premium debit card'	} )
aAdd( aCodRet, { 'mccorporatedebit'    				, 'CD', 'Mastercard corporate debit card'      		} )
aAdd( aCodRet, { 'mcpurchasingdebit'    			, 'CD', 'Mastercard purchasing debit card'      	} )
aAdd( aCodRet, { 'mcfleetdebit'    					, 'CD', 'Mastercard fleet debit card'      			} )
aAdd( aCodRet, { 'maestro'    						, 'CD', 'Maestro card'     			 				} )
aAdd( aCodRet, { 'visa'    							, 'CD', 'Visa card (not classified)'     			} )
aAdd( aCodRet, { 'visadebit'    					, 'CD', 'Visa debit card (not classified)'      	} )
aAdd( aCodRet, { 'visastandarddebit'    			, 'CD', 'Visa standard debit card'      			} )
aAdd( aCodRet, { 'visapremiumdebit'    				, 'CD', 'Visa premium debit card'      				} )
aAdd( aCodRet, { 'visasuperpremiumdebit'    		, 'CD', 'Visa super premium debit card'      		} )
aAdd( aCodRet, { 'visacommercialdebit'    			, 'CD', 'Visa commercial debit card'     		 	} )
aAdd( aCodRet, { 'visacommercialpremiumdebit'    	, 'CD', 'Visa commercial premium debit card'      	} )
aAdd( aCodRet, { 'visacommercialsuperpremiumdebit'	, 'CD', 'Visa commercial super premium debit card'	} )
aAdd( aCodRet, { 'visacorporatedebit'    			, 'CD', 'Visa corporate debit card'      			} )
aAdd( aCodRet, { 'visapurchasingdebit'    			, 'CD', 'Visa purchasing debit card'      			} )
aAdd( aCodRet, { 'visafleetdebit'    				, 'CD', 'Visa fleet debit card'     		 		} )
aAdd( aCodRet, { 'electron'    						, 'CD', 'Visa electron card'      					} )

Return aCodRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjRetPgDig
Retorna a relação de Códigos de Retorno das carteiras de Pagamentos Digitais.

@type       Function
@author     Alberto Deviciente
@since      19/11/2020
@version    12.1.27

@return aCodRet, Array, Array com a relação de Códigos de Retorno das carteiras de Pagamentos Digitais.
/*/
//-------------------------------------------------------------------------------------
Static Function LjRetPgDig()
Local aCodRet := {}

//--------------------------------------------------------
//Códigos de Retorno das carteiras de Pagamentos Digitais
//--------------------------------------------------------
//             	Cod. Retorno	, "PD",  Descricao
aAdd( aCodRet, { 'mercadopago'		, 'PD', 'Mercado Pago' 	} )
aAdd( aCodRet, { 'picpay'			, 'PD', 'PicPay' 		} )
aAdd( aCodRet, { 'pagseguro'		, 'PD', 'PagSeguro'		} )
aAdd( aCodRet, { 'ame'				, 'PD', 'Ame' 			} )
aAdd( aCodRet, { 'shipay-pagador'	, 'PX', 'Pix' 			} )
aAdd( aCodRet, { 'shipay-pagador'	, 'PD', 'shipay-pagador'} )
aAdd( aCodRet, { 'cielo'			, 'PD', 'Cielo' 		} )

Return aCodRet