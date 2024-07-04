#INCLUDE "Protheus.ch"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "WSFluigJuridico.ch"

User Function _YYYYYXX ; Return  // "dummy" function - Internal Use

/*/
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+--------------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ WSFluigJuridico ¦ Autor ¦Antonio C Ferreira¦ Data ¦ 12/jun/15 ¦¦¦
¦¦+----------+---------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Métodos WS do Jurídico para integração com o FLUIG.           ¦¦¦
¦¦+----------+---------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo TOTVS S/A.                                          ¦¦¦
¦¦+----------+---------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
/*/


// _______________________________________________________________________________________
//	  Inicio - Glaicon Cesar
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

// _______________________________________________________________________________________
//	  Definicao da estrutura basica de codigo e descricao
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	// Glaicon - Campos Customizados
	WSSTRUCT StruCustom
		WSDATA	cCampo	 AS string
		WSDATA	cValor	 AS String
	ENDWSSTRUCT

// _______________________________________________________________________________________
//	  Definicao da estrutura basica de codigo e descricao
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	WSStruct StruDados
		WSData Codigo 		As String
		WSData Descricao	As String
	EndWSStruct

 // _______________________________________________________________________________________
 //	  Definicao da estrutura para lista de dados
 // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

	WSStruct StruLista
		WsData  Dados  As Array of StruDados
	EndWSStruct

// _______________________________________________________________________________________
//	  Definicao da estrutura para empresa
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	WSStruct StruEmpresa
		WSData Codigo        As String	//Cliente + Loja
		WSData RazaoSocial   As String
		WSData NomeFantasia  As String
		WSData CNPJ          As String
	EndWSStruct

// _______________________________________________________________________________________
//	  Definicao da estrutura para partes contrarias
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	WSStruct StruPartCont
		WSData Codigo        As String
		WSData RazaoSocial   As String
		WSData CNPJ          As String
	EndWSStruct

// _______________________________________________________________________________________
//	  Definicao da estrutura para geracao do assunto juridico consultivo
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	WSStruct StruAssunto
		WSData EmailSolicitante       As String
		WSData Solicitacao            As String
		WSData DataFw                 As String
		WSData Empresa                As String  //Cliente+Loja
		WSData Escritorio             As String
		WSData Area                   As String
		WSData Solicitante            As String
		WSData TipoAssuntoJuridico    As String
		WSData TipoSolicitacao        As String
		WSData Advogado               As String
		WSData DescricaoSolicitacao   As String
		WSData Observacoes            As String
		WSData StepDestino            As String
		WSData CampoRetorno           As String
		WSData StepDestinoFalha       As String
	EndWSStruct

// _______________________________________________________________________________________
//	  Definicao da estrutura para geracao do novo Followup
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	WSStruct StruFollowup
		WSData DataFw               As String
		WSData Solicitacao			As String //Id da Solicitacao
		WSData Descricao            As String
		WSData CodAssuntoJuridico	As String
		WSData Origem               As String //define se é Consultivo ou Contrato
		WSData CodOrigem            As String //código usado. Consultivo - Tipo Solicitacao, Contrato - Tipo Contrato
		WSData StepDestino          As String
		WSData CampoRetorno         As String
		WSData StepDestinoFalha     As String
		WSData Solicitante          As String
		WSData Escritorio           As String
	EndWSStruct

// _______________________________________________________________________________________
//	  Definicao da estrutura para geracao do assunto juridico de contrato
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	WSStruct StruContratoAssunto
		WSData Solicitacao            As String
		WSData DataInclusao           As String
		WSData Escritorio             As String
		WSData Area                   As String
		WSData TipoContrato           As String
		WSData RenovacaoAuto          As String
		WSData Solicitante            As String
		WSData TipoAssuntoJuridico    As String
		WSData Advogado               As String
		WSData DescricaoSolicitacao   As String
		WSData Observacoes            As String
		WSData ValorContrato          As String
		WSData VigenciaInicio         As String
		WSData VigenciaFim            As String
		WSData Condicao               As String
		WSData NomeParteC             As String
		WSData TipoPessoaParteC       As String
		WSData CGCParteC              As String
		WSData EnderecoParteC         As String
		WSData BairroParteC           As String
		WSData EstadoParteC           As String
		WSData MunicipioParteC        As String
		WSData CEPParteC              As String
		WSData PoloAtivo              As String
		WSData EntPoloAtivo           As String
		WSData PoloPassivo            As String
		WSData EntPoloPassivo         As String
		WSData EmailSolicitante       As String
		WSData StepDestinoConc        As String
		WSData StepDestinoCanc        As String
		WSData CampoRetorno           As String
		WSDATA CampoCustomizados      AS Array of StruCustom OPTIONAL
	EndWSStruct

// ___________________________________________________________________________________________________
//	  Definicao da estrutura para ecerramento/cancelamento dos assuntos juridicos consultivo/contratos
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	WSStruct StruEncerra
		WSData TipoAssuntoJuridico    As String
		WSData AssuntoJuridico        As String
		WSData Status                 As String // 1=Concluido / 2=Cancelado
		WSData Observacoes            As String
		WSData EmailUsuarioEncerra    As String
		WSData Escritorio             As String
	EndWSStruct

// _______________________________________________________________________________________
//	  Definicao da estrutura para retorno do assunto juridico
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	WSStruct StruRetornoAssunto
		WSData NumeroConsulta     As String  //Codigo Assunto Juridico
		WSData CodigoJuridico     As String  //Cliente-Loja-Caso
		WSData FluxoAprovacao     As String  //Indica se o parâmetro de aprovação está habilitado
		WSData CodigoFollowup     As String  //Código do follow-up gerado na inclusão do assunto juridico
		WSData PastaCaso    	  As String  //Indica o id da pasta do caso no Fluig
	EndWSStruct

// _______________________________________________________________________________________
//	  Definicao da estrutura para atualizar as informações do processo consultivo
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	WSStruct StruAtualizaConsultivo
		WSData Escritorio         As String
		WSData CodigoCajuri       As String
		WSData Solicitacao        As String
		WSData Observacoes        As String
	EndWSStruct

	// _______________________________________________________________________________________
	//   Definicao da estrutura para atualizar as informações do contrato
	// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	WSStruct StruAtualizaContrato
		WSData RenovacaoAuto      As String
		WSData Escritorio         As String
		WSData Cajuri             As String
		WSData DescSolicitacao    As String
		WSData Observacao         As String
		WSData PoloAtivo          As String
		WSData PoloPassivo        As String
		WSData EntPoloPassivo     As String
		WSData EntPoloAtivo       As String
		WSData ValorContrato      As String
		WSData VigenciaInicio     As String
		WSData VigenciaFim        As String
		WSData CondPagamento      As String
		WSData NomeParteC         As String
		WSData CPFParteC          As String
		WSData EnderecoParteC     As String
		WSData BairroParteC       As String
		WSData UFParteC           As String
		WSData CEPParteC          As String
		WSData TipoParteC         As String
		WSData MunicParteC        As String
		WSDATA CampoCustomizados  AS Array Of StruCustom  OPTIONAL
	EndWSStruct

// ____________________________________________________________________________
/*
{Protheus.doc} WSFluigJuridico
Métodos WS do Jurídico para integração com o FLUIG.

@class   WSFluigJuridico
@author  Antonio Carlos Ferreira
@version 1.0
@since   12/06/2015
@return  sem retorno
@sample
		...
	   Local oObj  := WSFluigJuridico():New()

	   WsChgURL( @oObj, "WSFluigJuridico.APW" )
	   ...
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

WsService WSFluigJuridico Description STR0001 NameSpace "com.totvs.sigajuri.wsfluigjuridico"  //"Serviço para métodos WS do Jurídico para integração com o FLUIG"

 // ____________________________________________________________________________
 //   Propriedades de Entrada e Saída
 // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	WSDATA FollowUp                AS String
	WSDATA Status	               AS String
	WSDATA TiposAssuntosJuridicos  AS StruLista
	WSDATA TiposFollowUp           AS StruLista
	WSDATA TiposSolicitacao        AS StruLista
	WSDATA AreasJuridicas          AS StruLista
	WSDATA Escritorios             AS StruLista
	WSDATA ObsExecutor             AS String
	WSDATA Arquivos                AS String
	WSDATA Empresas                AS Array of StruEmpresa
	WSDATA Fornecedores            AS Array of StruEmpresa
	WSDATA PartesContrarias        AS Array of StruPartCont
	WSDATA AssuntoJuridico         AS StruAssunto
	WSDATA oEncerramento           AS StruEncerra
	WSDATA NumeroConsulta          AS String
	WSDATA TiposContratos          AS StruLista
	WSDATA ContratoAssuntoJuridico AS StruContratoAssunto
	WSDATA RetornoAssunto          AS StruRetornoAssunto
	WSDATA Ok                      AS Boolean
	WSDATA CodAssuntoJuridico      AS String
	WSDATA CodTipoContrato         AS String
	WSDATA IdMinuta                AS String
	WSDATA oFollowup               AS StruFollowup
	WSDATA CodFollowUp             AS String
	WSDATA cFiltro                 AS String OPTIONAL
	WSDATA Filial                  AS String
	WSDATA CampoAprovador		   AS String
	WSDATA EmailAprovador		   AS String
	WSDATA Escritorio              AS String
	WSDATA FilialAtu               AS String
	WSDATA AtualizaConsultivo      AS StruAtualizaConsultivo
	WSDATA AtualizaContrato        AS StruAtualizaContrato
	WSDATA MailExecutor            AS String
	WSDATA CodTipoImpressao        AS String
	WSDATA cCPF                    AS String
	WSDATA cEmail                  AS String
 // ____________________________________________________________________________
 //   Métodos
 // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	WSMETHOD MTStatusFollowUp                DESCRIPTION STR0002  //"Método para obter o status do Follow-UP."
	WSMETHOD MTAssuntosJuridicos             DESCRIPTION STR0003  //"Metodo para obter os Assuntos Juridicos."
	WSMETHOD MTTiposFollowUp                 DESCRIPTION STR0004  //"Metodo para obter os Tipos Follow-UPs."
	WSMETHOD MTAreasJuridicas                DESCRIPTION STR0005  //"Metodo para obter as Areas Jurídicas."
	WSMETHOD MTEscritorios                   DESCRIPTION STR0006  //"Metodo para obter Escritórios Jurídicos."
	WSMETHOD MTTiposContratos                DESCRIPTION STR0007  //"Metodo para obter os Tipos de Contratos."
	WSMETHOD MTEmpresas                      DESCRIPTION STR0008  //"Metodo para obter as Empresas."
	WSMETHOD MTFornecedores                  DESCRIPTION STR0009  //"Metodo para obter as Fornecedores."
	WSMETHOD MTJurSyncFollowUp               DESCRIPTION STR0010  //"Metodo para sincronismo do status da atividade pelo Fluig."
	WSMETHOD MTJurEncerraAssJur              DESCRIPTION STR0024  //"Metodo para encerrar assunto jurídico (cancelamento/encerramento)."
	WSMETHOD MTGeraConsultivo                DESCRIPTION STR0011  //"Metodo para gerar novo Assunto Jurídico."
	WSMETHOD MTGeraContratoAssuntoJuridico   DESCRIPTION STR0012  //"Metodo para gerar novo Assunto Jurídico de Contrato."
	WSMETHOD MTTiposSolicitacao              DESCRIPTION STR0023  //"Metodo para obter os Tipos de Solicitação."
	WSMETHOD MTPartesContrarias              DESCRIPTION STR0025  //"Metodo para obter as partes contrárias."
	WSMETHOD MTGeraMinuta                    DESCRIPTION STR0026  //"Metodo para gerar petições automáticas."
	WSMETHOD MTJurIncFollowUp                DESCRIPTION STR0027  //"Metodo para incluir follow-ups."
	WSMETHOD MTAprovadorSigajuri             DESCRIPTION STR0036  //"Metodo que ira retornar o e-mail do aprovador a partir dos participantes do processo."
	WSMETHOD MTAtualizaConsultivo            DESCRIPTION STR0043  //"Método para atualizar as informações de detalhes e observação do processo"
	WSMETHOD MTAtualizaContrato              DESCRIPTION STR0044  //"Método para atualizar as informações do contrato"
	WSMETHOD MTGetCPF                        DESCRIPTION STR0041  //"Metodo para obter o CPF do responsável a partir do e-mail."
	WSMETHOD MTAtualizaSigla2                DESCRIPTION STR0045  //"Metodo para atualizar a sigla2."

EndWsService

// ____________________________________________________________________________
/*
{Protheus.doc} MTStatusFollowUp
Metodo para obter o status do Follow-UP.

@class   WSFluigJuridico
@param   FollowUp Codigo Follow-up.
@author  Antonio Carlos Ferreira
@version 1.0
@since   12/06/2015
@return  Status Status do Follow-up.
@sample
		...
		oObj:FollowUp	:= cCodigo

		If  !( oObj:MTStatusFollowUp() )
			...
		EndIf
		cStatus := oObj:MTStatusFollowUpResult
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

WSMETHOD 		MTStatusFollowUp ;
	WSRECEIVE 	FollowUp ;
	WSSEND 		Status ;
	WSSERVICE 	WSFluigJuridico

Local lRetorno := .T.

DbSelectArea('NTA')
NTA->( DbSetOrder(1) ) //NTA_FILIAL+NTA_COD
NTA->( dbGoTop())

If !( NTA->( DbSeek(xFilial('NTA')+self:FollowUp) ) )
	SetSoapFault("MTStatusFollowUp",STR0013 + self:FollowUp) //"Codigo não encontrado no cadastro de Follow-up! Codigo: "
	JurConOut(STR0013 + self:FollowUp) //"Codigo não encontrado no cadastro de Follow-up! Codigo: "
	lRetorno := .F.
Else
   self:Status := JurGetDados('NQN',1,xFilial('NQN')+NTA->NTA_CRESUL,'NQN_TIPO')
EndIf

Return(lRetorno)

// ____________________________________________________________________________
/*
{Protheus.doc} MTAssuntosJuridicos
Metodo para obter os Assuntos Juridicos.

@class   WSFluigJuridico
@param   TiposAssuntosJuridicos Lista de Tipos de Assuntos Juridicos.
@author  Antonio Carlos Ferreira
@version 1.0
@since   12/06/2015
@return  Status Status do Follow-up.
@sample
		...
		If  !( oObj:MTAssuntosJuridicos() )
			...
		EndIf
		aAssuntos := oObj:MTAssuntosJuridicosResult
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

WSMETHOD 		MTAssuntosJuridicos ;
	WSRECEIVE 	NULLPARAM ;
	WSSEND 		TiposAssuntosJuridicos ;
	WSSERVICE 	WSFluigJuridico

Local lRetorno := .T.

self:TiposAssuntosJuridicos:Dados := {}

DbSelectArea('NYB')
NYB->( DbSetOrder(1) )	//NYB_FILIAL+NYB_COD

NYB->( DbGoTop() )

Do While !NYB->( Eof() )

	AAdd(self:TiposAssuntosJuridicos:Dados, WSClassNew("StruDados"))

	aTail(self:TiposAssuntosJuridicos:Dados):Codigo    := NYB->NYB_COD
	aTail(self:TiposAssuntosJuridicos:Dados):Descricao := NYB->NYB_DESC

	NYB->( DbSkip() )
EndDo

If Len(self:TiposAssuntosJuridicos:Dados) <= 0
	SetSoapFault("MTAssuntosJuridicos", STR0014) //"Nenhum registro foi encontrado!"
	JurConOut(STR0014) 							 //"Nenhum registro foi encontrado!"
	lRetorno := .F.
EndIf

Return(lRetorno)

// ____________________________________________________________________________
/*
{Protheus.doc} MTTiposFollowUp
Metodo para obter os Tipos Follow-UPs.

@class   WSFluigJuridico
@param   NULLPARAM Nao exige parametro de entrada.
@author  Antonio Carlos Ferreira
@version 1.0
@since   12/06/2015
@return  TiposFollowUp Estrutura matriz com o código e descrição dos tipos de follow-up.
@sample
		...
		If  !( oObj:MTTiposFollowUp() )
			...
		EndIf
		aTipos := oObj:MTTiposFollowUpResult
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

WSMETHOD 		MTTiposFollowUp ;
	WSRECEIVE 	NULLPARAM ;
	WSSEND 		TiposFollowUp ;
	WSSERVICE 	WSFluigJuridico

Local lRetorno := .T.

self:TiposFollowUp:Dados := {}

DbSelectArea('NQS')
NQS->( DbSetOrder(1) )	//NQS_FILIAL+NQS_COD
NQS->( DbGoTop() )

Do While !NQS->( Eof() )

	AAdd(self:TiposFollowUp:Dados, WSClassNew("StruDados"))

	aTail(self:TiposFollowUp:Dados):Codigo    := NQS->NQS_COD
	aTail(self:TiposFollowUp:Dados):Descricao := NQS->NQS_DESC

	NQS->( DbSkip() )
EndDo

If Len(self:TiposFollowUp:Dados) <= 0
	SetSoapFault("MTTiposFollowUp", STR0014) //"Nenhum registro foi encontrado!"
	JurConOut(STR0014) 						 //"Nenhum registro foi encontrado!"
	lRetorno := .F.
EndIf

Return(lRetorno)


// ____________________________________________________________________________
/*
{Protheus.doc} MTAreasJuridicas
Metodo para obter as Areas Jurídicas.

@class   WSFluigJuridico
@param   NULLPARAM Nao exige parametro de entrada.
@author  Antonio Carlos Ferreira
@version 1.0
@since   08/07/2015
@return  AreasJuridicas Estrutura matriz com o código e descrição das areas jurídicas.
@sample
		...
		If  !( oObj:MTAreaJuridica() )
			...
		EndIf
		aAreas := oObj:MTAreaJuridicaResult
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

WSMETHOD 		MTAreasJuridicas ;
	WSRECEIVE 	NULLPARAM ;
	WSSEND 		AreasJuridicas ;
	WSSERVICE 	WSFluigJuridico

Local lRetorno := .T.
Local lFluig   := .T.

self:AreasJuridicas:Dados := {}

DbSelectArea('NRB')
DbSetOrder(2) //NRB_FILIAL+NRB_DESC

DbGoTop()

Do  While !( Eof() )

	if (NRB->NRB_ATIVO == "1")
		lFluig := .T.

		If ColumnPos("NRB_FLUIG") > 1
			if (NRB->NRB_FLUIG == "2")
				lFluig := .F.
			Endif
		Endif

		if lFluig
			AAdd(self:AreasJuridicas:Dados, WSClassNew("StruDados"))

			aTail(self:AreasJuridicas:Dados):Codigo    := NRB->NRB_COD
			aTail(self:AreasJuridicas:Dados):Descricao := NRB->NRB_DESC
		Endif
	Endif

	DbSkip()
EndDo

If  (Len(self:AreasJuridicas:Dados) <= 0)
	SetSoapFault("MTAreasJuridicas", STR0014) //"Nenhum registro foi encontrado!"
	JurConOut(STR0014) //"Nenhum registro foi encontrado!"
	lRetorno := .F.
EndIf

Return(lRetorno)


// ____________________________________________________________________________
/*
{Protheus.doc} MTEscritorios
Metodo para obter Escritórios Jurídicos.

@class   WSFluigJuridico
@param   NULLPARAM Nao exige parametro de entrada.
@author  Antonio Carlos Ferreira
@version 1.0
@since   08/07/2015
@return  Escritorios Estrutura matriz com o código e descrição dos escritorios.
@sample
		...
		If  !( oObj:MTEscritorios() )
			...
		EndIf
		aEscritorios := oObj:MTMTEscritoriosResult
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

WSMETHOD 		MTEscritorios ;
	WSRECEIVE 	NULLPARAM ;
	WSSEND 		Escritorios ;
	WSSERVICE 	WSFluigJuridico

Local lRetorno := .T.

self:Escritorios:Dados := {}

DbSelectArea('NS7')
NS7->( DbSetOrder(1) )		//NS7_FILIAL+NS7_COD
NS7->( DbGoTop() )

Do While !NS7->( Eof() )

	AAdd(self:Escritorios:Dados, WSClassNew("StruDados"))

	aTail(self:Escritorios:Dados):Codigo    := NS7->NS7_COD
	aTail(self:Escritorios:Dados):Descricao := NS7->NS7_NOME

	NS7->( DbSkip() )
EndDo

If Len( self:Escritorios:Dados ) <= 0
	SetSoapFault("MTEscritorios", STR0014) //"Nenhum registro foi encontrado!"
	JurConOut(STR0014) //"Nenhum registro foi encontrado!"
	lRetorno := .F.
EndIf

Return(lRetorno)


// ____________________________________________________________________________
/*
{Protheus.doc} MTTiposContratos
Metodo para obter os Tipos de Contratos.

@class   WSFluigJuridico
@param   NULLPARAM Nao exige parametro de entrada.
@author  Antonio Carlos Ferreira
@version 1.0
@since   21/07/2015
@return  TiposContratos Estrutura matriz com o código e descrição dos tipos de contratos.
@sample
		...
		If  !( oObj:MTTiposContratos() )
			...
		EndIf
		aTipos := oObj:MTTiposContratosResult
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

WSMETHOD 		MTTiposContratos ;
	WSRECEIVE 	NULLPARAM ;
	WSSEND 		TiposContratos ;
	WSSERVICE 	WSFluigJuridico

Local lRetorno := .T.

self:TiposContratos:Dados := {}

DbSelectArea('NY0')
NY0->( DbSetOrder(2) )	//NY0_FILIAL+NY0_DESC
NY0->( DbGoTop() )

Do While !NY0->( Eof() )

	AAdd(self:TiposContratos:Dados, WSClassNew("StruDados"))

	aTail(self:TiposContratos:Dados):Codigo    := NY0->NY0_COD
	aTail(self:TiposContratos:Dados):Descricao := NY0->NY0_DESC

	NY0->( DbSkip() )
EndDo

If Len(self:TiposContratos:Dados) <= 0
	SetSoapFault("MTTiposContratos", STR0014) //"Nenhum registro foi encontrado!"
	JurConOut(STR0014) 						  //"Nenhum registro foi encontrado!"
	lRetorno := .F.
EndIf

Return(lRetorno)

// ____________________________________________________________________________
/*
{Protheus.doc} MTTiposSolicitacao
Metodo para obter os Tipos de Solicitação.

@class   WSFluigJuridico
@param   NULLPARAM Nao exige parametro de entrada.
@author  Jorge Luis Branco Martins Junior
@version 1.0
@since   12/06/2015
@return  TiposSolicitacao Estrutura matriz com o código e descrição dos tipos de solicitação.
@sample
		...
		If  !( oObj:MTTiposSolicitacao() )
			...
		EndIf
		aTipos := oObj:MTTiposSolicitacaoResult
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

WSMETHOD MTTiposSolicitacao ;
	WSRECEIVE NULLPARAM ;
	WSSEND    TiposSolicitacao ;
	WSSERVICE WSFluigJuridico

Local lRetorno := .T.

self:TiposSolicitacao:Dados := {}

DbSelectArea('NYA')
DbSetOrder(1) //NYA_FILIAL+NYA_COD

DbGoTop()

Do While !( Eof() )

	AAdd(self:TiposSolicitacao:Dados, WSClassNew("StruDados"))

	aTail(self:TiposSolicitacao:Dados):Codigo    := NYA->NYA_COD
	aTail(self:TiposSolicitacao:Dados):Descricao := NYA->NYA_DESC

	DbSkip()
EndDo

If (Len(self:TiposSolicitacao:Dados) <= 0)
	SetSoapFault("MTTiposSolicitacao", STR0014) //"Nenhum registro foi encontrado!"
	JurConOut(STR0014) //"Nenhum registro foi encontrado!"
	lRetorno := .F.
EndIf

Return(lRetorno)

// ____________________________________________________________________________
/*
{Protheus.doc} MTPartesContrarias
Metodo para obter as Partes Contrarias.

@class   WSFluigJuridico
@param   NULLPARAM Nao exige parametro de entrada.
@author  Jorge Luis Branco Martins Junior
@version 1.0
@since   11/09/2015
@return  PartesContrarias Estrutura matriz com o código, razao social e cnpj das Partes Contrarias.
@sample
		...
		If  !( oObj:MTPartesContrarias() )
			...
		EndIf
		aEmpresas := oObj:MTPartesContrariasResult
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

WSMETHOD 		MTPartesContrarias ;
	WSRECEIVE 	cFiltro, Escritorio ;
	WSSEND 		PartesContrarias ;
	WSSERVICE 	WSFluigJuridico

Local lRetorno := .T.
Local aArea    := GetArea()
Local cTrab
Local cQuery   := ''
Local nQtdMax := 100
Local nCt := 0

	self:PartesContrarias := {}

	//Atualiza a filial do ambiente para a filial do escritorio ou do parâmetro
	If !AbreFilial(Escritorio)
		lRetorno := .F.
		Break
	EndIf

	cQuery := "SELECT NZ2_COD,NZ2_NOME, NZ2_CGC"
	cQuery += "  FROM " + RetSqlName( "NZ2" )
	cQuery += " WHERE NZ2_FILIAL = '" + xFilial( "NZ2" ) + "' "

	if (!Empty(self:cFiltro))
		cQuery += " AND (LOWER(NZ2_NOME) LIKE '%" + Lower(self:cFiltro) + "%' OR LOWER(NZ2_CGC) LIKE '%" + Lower(self:cFiltro) + "%')"
	Endif

	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY NZ2_NOME"

	cQuery := changeQuery(cQuery)

	cTrab  := GetNextAlias()

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cTrab, .T., .F. )

	While !(cTrab)->( EOF() ) .And. nCt <= nQtdMax

		AAdd(self:PartesContrarias, WSClassNew("StruEmpresa"))

		aTail(self:PartesContrarias):Codigo      := (cTrab)->NZ2_COD
		aTail(self:PartesContrarias):RazaoSocial := (cTrab)->NZ2_NOME
		aTail(self:PartesContrarias):CNPJ        := (cTrab)->NZ2_CGC

		nCt := nCt + 1

		(cTrab)->( dbSkip() )

	End

	(cTrab)->( dbCloseArea() )

	restArea(aArea)

	If  (Len(self:PartesContrarias) <= 0)
		SetSoapFault("MTPartesContrarias", STR0014) //"Nenhum registro foi encontrado!"
		JurConOut(STR0014) //"Nenhum registro foi encontrado!"
		lRetorno := .F.
	EndIf

Return(lRetorno)

// ____________________________________________________________________________
/*
{Protheus.doc} MTEmpresas
Metodo para obter as Empresas.

@class   WSFluigJuridico
@param   NULLPARAM Nao exige parametro de entrada.
@author  Antonio Carlos Ferreira
@version 1.0
@since   08/07/2015
@return  Empresas Estrutura matriz com o código, razao social e cnpj das empresas.
@sample
		...
		If  !( oObj:MTEmpresas() )
			...
		EndIf
		aEmpresas := oObj:MTEmpresasResult
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
WSMETHOD 		MTEmpresas ;
	WSRECEIVE 	cFiltro, Escritorio ;
	WSSEND 		Empresas ;
	WSSERVICE 	WSFluigJuridico

	Local lRetorno := .T.
	Local aArea    := GetArea()
	Local cQuery   := ''
	Local nQtdMax  := 100
	Local nCt      := 0
	Local cTrab
	Local cFiltro  := self:cFiltro

	self:Empresas := {}

	//Atualiza a filial do ambiente para a filial do escritorio ou do parâmetro
	If !AbreFilial(Escritorio)
		lRetorno := .F.
		Break
	EndIf

	cQuery := "SELECT A1_COD, A1_LOJA, A1_NOME, A1_NREDUZ, A1_CGC"
	cQuery += 	" FROM " + RetSqlName( "SA1" )
	cQuery += " WHERE A1_FILIAL = '" + xFilial( "SA1" ) + "' "

	If !Empty(cFiltro)
		cFiltro := AllTrim( Lower(cFiltro) )
		cQuery	+= " AND ( LOWER(A1_NOME) LIKE '%" + cFiltro + "%' OR LOWER(A1_NREDUZ) LIKE '%" + cFiltro + "%' OR LOWER(A1_CGC) LIKE '%" + cFiltro + "%' )"
	EndIf

	cQuery += 	" AND D_E_L_E_T_ = ' ' "
	cQuery += 	" AND A1_MSBLQL = '2' "
	cQuery += " ORDER BY A1_NOME, A1_NREDUZ"

	cQuery := ChangeQuery(cQuery)

	cTrab  := GetNextAlias()

	dbUseArea( .T., 'TOPCONN', TcGenQry( , , cQuery), cTrab, .T., .F.)

	While !(cTrab)->( Eof() ) .And. nCt <= nQtdMax

		Aadd(self:Empresas, WSClassNew("StruEmpresa"))

		aTail(self:Empresas):Codigo       := (cTrab)->A1_COD + (cTrab)->A1_LOJA
		aTail(self:Empresas):RazaoSocial  := (cTrab)->A1_NOME
		aTail(self:Empresas):NomeFantasia := (cTrab)->A1_NREDUZ
		aTail(self:Empresas):CNPJ         := (cTrab)->A1_CGC

		nCt := nCt + 1

		(cTrab)->( DbSkip() )
	End
	(cTrab)->( DbCloseArea() )

	RestArea(aArea)

	If Len(self:Empresas) <= 0
		JurConOut(STR0014)	//"Nenhum registro foi encontrado!"
	EndIf

Return(lRetorno)


// ____________________________________________________________________________
/*
{Protheus.doc} MTFornecedores
Metodo para obter as Fornecedores.

@class   WSFluigJuridico
@param   NULLPARAM Nao exige parametro de entrada.
@author  Antonio Carlos Ferreira
@version 1.0
@since   27/07/2015
@return  Fornecedores Estrutura matriz com o código, razao social e cnpj dos Fornecedores.
@sample
		...
		If  !( oObj:MTFornecedores() )
			...
		EndIf
		aEmpresas := oObj:MTFornecedoresResult
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

WSMETHOD 		MTFornecedores ;
	WSRECEIVE 	cFiltro, Escritorio ;
	WSSEND 		Fornecedores ;
	WSSERVICE 	WSFluigJuridico

	Local lRetorno := .T.
	Local aArea    := GetArea()
	Local cTrab
	Local cQuery   := ''
	Local nQtdMax  := 100
	Local nCt 	   := 0
	Local cFiltro  := self:cFiltro

	self:Fornecedores := {}

	//Atualiza a filial do ambiente para a filial do escritorio ou do parâmetro
	If !AbreFilial(Escritorio)
		lRetorno := .F.
		Break
	EndIf

	cQuery := "SELECT A2_COD, A2_LOJA, A2_NOME, A2_NREDUZ, A2_CGC"
	cQuery += 	" FROM " + RetSqlName( "SA2" )
	cQuery += " WHERE A2_FILIAL = '" + xFilial( "SA2" ) + "' "

	If !Empty(cFiltro)
			cFiltro := AllTrim( Lower(cFiltro) )
		cQuery += " AND (LOWER(A2_NOME) LIKE '%" + cFiltro + "%' OR LOWER(A2_NREDUZ) LIKE '%" + cFiltro + "%' OR LOWER(A2_CGC) LIKE '%" + cFiltro + "%')"
	EndIf

	cQuery += 	" AND D_E_L_E_T_ = ' ' "
	cQuery += 	" AND A2_MSBLQL = '2' "
	cQuery += " ORDER BY A2_NOME, A2_NREDUZ"

	cQuery := ChangeQuery(cQuery)

	cTrab  := GetNextAlias()

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery), cTrab, .T., .F.)

	While !(cTrab)->( Eof() ) .And. nCt <= nQtdMax

		AAdd(self:Fornecedores, WSClassNew("StruEmpresa"))

		aTail(self:Fornecedores):Codigo       := (cTrab)->A2_COD+(cTrab)->A2_LOJA
		aTail(self:Fornecedores):RazaoSocial  := (cTrab)->A2_NOME
		aTail(self:Fornecedores):NomeFantasia := (cTrab)->A2_NREDUZ
		aTail(self:Fornecedores):CNPJ         := (cTrab)->A2_CGC

		nCt := nCt + 1

		(cTrab)->( dbSkip() )
	End

	(cTrab)->( dbCloseArea() )

	RestArea(aArea)

	If Len(self:Fornecedores) <= 0
		JurConOut(STR0014)		//"Nenhum registro foi encontrado!"
	EndIf

Return(lRetorno)

// ____________________________________________________________________________
/*
{Protheus.doc} MTJurSyncFollowUp
Metodo para sincronismo do status da atividade pelo Fluig.

@class   WSFluigJuridico
@param   FollowUp Codigo Follow-up.
@author  Antonio Carlos Ferreira
@version 1.0
@since   12/06/2015
@return  Status Status do Follow-up.
@sample
		...
		oObj:FollowUp	:= cCodigo

		If  !( oObj:MTStatusFollowUp() )
			...
		EndIf
		cStatus := oObj:MTStatusFollowUpResult
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
WSMETHOD 		MTJurSyncFollowUp ;
	WSRECEIVE 	FollowUp, Status, ObsExecutor, Arquivos, Filial, MailExecutor ;
	WSSEND 		Ok ;
	WSSERVICE 	WSFluigJuridico

Local lRetorno   := .T.
Local oModel     := nil
Local oMMaster   := nil
Local cStatus    := ''
Local cResultado := ''    //Grava o código do NQN_COD conforme o Status passado pelo Fluig
Local cUserFluig := ''
Local cPart      := ''
Local aRetNSZ	 := {}
Local lEncerrado := .F.
Local cMailExec  := ''

Private cTipoAsJ := ''
Public c162TipoAs:= ''

Begin Sequence

	If !Empty( Self:MailExecutor)
		cMailExec := Self:MailExecutor
	EndIf

	//Atualiza a filial do ambiente para a filial do escritorio ou do parâmetro
	If !AbreFilial( , self:Filial)
		lRetorno := .F.
		Break
	EndIf

	DbSelectArea('NTA')
	NTA->( DbSetOrder(1) ) //NTA_FILIAL+NTA_COD

	If  Empty( self:FollowUp ) .Or. Empty( self:Status )
		SetSoapFault("MTJurSyncFollowUp", STR0015) //"Parâmetros obrigatórios faltando, favor verificar!"
		JurConOut(STR0015) //"Parâmetros obrigatórios faltando, favor verificar!"
		lRetorno := .F.
		Break
	EndIf

	If !NTA->( DbSeek(xFilial('NTA')+self:FollowUp) )
		SetSoapFault("MTJurSyncFollowUp", STR0013 + self:FollowUp) //"Código não encontrado no cadastro de Follow-up! Código: "
		JurConOut(STR0013 + self:FollowUp) //"Código não encontrado no cadastro de Follow-up! Código: "
		lRetorno := .F.
		Break
	Elseif JurGetDados("NSZ",1,xFilial("NSZ") + NTA->NTA_CAJURI, "NSZ_SITUAC") == "2"
		lEncerrado := .T.
	Else
		aRetNSZ    := JurGetDados("NSZ", 1, xFilial("NSZ") + NTA->NTA_CAJURI, {"NSZ_TIPOAS","NSZ_CPART1"})
		cTipoAsJ   := aRetNSZ[1]
		c162TipoAs := aRetNSZ[1]
		cPart      := aRetNSZ[2]

		If !Empty(cMailExec)
			cUserFluig := getUserId(cMailExec)
			If Len(cUserFluig) > 0
				cUserFluig := cUserFluig[1]
			EndIf
		Else
			cUserFluig := JurGetDados("RD0",1,xFilial("RD0") + cPart, "RD0_USER")
		EndIf

		__cUserId := AllTrim(cUserFluig) //Seta o cod usuário
		//Obtem o status atual no registro, mesmo que seja o status já gravado irá proceder normalmente.
		cStatus := Posicione('NQN',1,xFilial('NQN')+NTA->NTA_CRESUL,'NQN_TIPO')

		DbSelectArea('NQN')
		NQN->( DbSetOrder(3) )	//NQN_FILIAL + NQN_TIPO

		If !NQN->( DbSeek( xFilial("NQN") + self:Status) )
			SetSoapFault("MTJurSyncFollowUp", STR0016) //"Status não encontrado no cadastro de Resultado Follow-up!"
			JurConOut(STR0016) //"Status não encontrado no cadastro de Resultado Follow-up!"
			lRetorno := .F.
			Break
		EndIf

	   	INCLUI 	   := .F.
		ALTERA 	   := .T.
		cResultado := NQN->NQN_COD  //Obtem o codigo a ser alterado no follow-up.

		oModel := FWLoadModel('JURA106')
		oModel:SetOperation(4)
		oModel:Activate()

		oMMaster := oModel:GetModel( 'NTAMASTER' )
		lRetorno := oMMaster:SetValue('NTA_CRESUL', cResultado)  //Grava a mudança de Status

		If lRetorno

			If  !( Empty(self:ObsExecutor) )
				lRetorno := oMMaster:SetValue('NTA__OBSER', self:ObsExecutor)  	//Salva a observação do executor no Fluig no campo virtual
			Else
				JurConOut(STR0029)	//"Observação do executor, não preenchida no Fluig!"
			EndIf

			If lRetorno .And. !oModel:VldData()
				SetSoapFault("MTJurSyncFollowUp", STR0017 + self:FollowUp) 		//"Problema na validação do follow-up! Codigo: "
				lRetorno := .F.
			EndIf

			If lRetorno .And. !oModel:CommitData()
				SetSoapFault("MTJurSyncFollowUp", STR0018 + self:FollowUp) 		//"Problema no commit do follow-up! Codigo: "
				lRetorno := .F.
			EndIf

			//Inclui justificativa para alteração de processo encerrado
			If lRetorno .And. lEncerrado
				lRetorno := J166GrvJus(oMMaster:SetValue("NTA_CAJURI"), , JGetParTpa(cTipoAsJ, "MV_JAJUENC", ""), I18n(STR0040, {self:FollowUp}) )	//"Alteração de follow-up (#1) via Fluig."
			EndIf
		EndIf

		If !lRetorno
			JurMsgErro(STR0017 + self:FollowUp) //"Problema na validação do follow-up! Codigo: "
		Else
			fGravaNUM(self:FollowUp, self:Arquivos)
		EndIf

		oModel:DeActivate()
		oModel:Destroy()
	EndIf

End Sequence

self:Ok := lRetorno

Return(lRetorno)

//-------------------------------------------------------------------
/*
{Protheus.doc} MTAtualizaConsultivo
Metodo que ira atualizar os campos NSZ_OBSERV e NSZ_DETALH quando
alterados via Fluig.

@class   WSFluigJuridico
@param   AtualizaConsultivo
@version 1.0
@since   26/06/2019
@return  True or False

	WSStruct StruAtualizaConsultivo
		WSData Escritorio         As String
		WSData CodigoCajuri       As String
		WSData Solicitacao        As String
		WSData Observacoes        As String
	EndWSStruct
*/
//-------------------------------------------------------------------
WSMETHOD MTAtualizaConsultivo;
	WSRECEIVE AtualizaConsultivo;
	WSSEND    Ok;
	WSSERVICE WSFluigJuridico

	Local cSoli        := self:AtualizaConsultivo:CODIGOCAJURI
	Local cDescSol     := self:AtualizaConsultivo:SOLICITACAO
	Local cObs         := self:AtualizaConsultivo:OBSERVACOES
	Local oModel       := Nil
	Local lRetorno     := .T.

	Private cTipoAsj   := ""
	Public c162TipoAs  := ''

	//Atualiza a filial do ambiente para a filial do escritorio ou do parâmetro
	If !AbreFilial(self:AtualizaConsultivo:ESCRITORIO)
		lRetorno := .F.
		Break
	EndIf

	DbSelectArea("NSZ")
	NSZ->(DbSetOrder(1)) //NSZ_FILIAL+NSZ_COD

	If dbSeek(xFilial("NSZ") + cSoli)
		c162TipoAs := NSZ->NSZ_TIPOAS
		cTipoAsJ   := NSZ->NSZ_TIPOAS

		oModel := FWLoadModel("JURA095")
		oModel:SetOperation( 4 ) //Alteração
		oModel:Activate()

		oModel:SetValue("NSZMASTER","NSZ_DETALH", cDescSol)
		oModel:SetValue("NSZMASTER","NSZ_OBSERV", cObs)
	Endif

	If !( oModel:VldData() ) .Or. !( oModel:CommitData() )
		cRet := STR0020 + CRLF  // "Erro: "
		cRet += STR0021 + oModel:aErrorMessage[4] + CRLF + ; // "Campo: "
				STR0022 + oModel:aErrorMessage[5] + CRLF + ; // "Razao: "
				CRLF + oModel:aErrorMessage[6] + CRLF

		SetSoapFault("MTAtualizaConsultivo", cRet)
		JurConOut(cRet)
		lRetorno := .F.
		Break
	EndIf

	oModel:DeActivate()

self:Ok := lRetorno

Return(lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} fGravaNUM
Grava os arquivos registrados no workflow do Fluig

@param 	cFollowUp  Codigo do FollowUp
@param cArquivos  Id dos arquivos registrados no FollowUp do Fluig
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Antonio C Ferreira
@since 27/08/15
@version 1.0
/*/
//-------------------------------------------------------------------
STATIC Function fGravaNUM(cFollowUp, cArquivos)

Local nA          := 0
Local nB          := 0
Local lRetorno    := .T.
Local aArquivos   := &('{"' + StrTran(cArquivos,';','","') + '"}')
Local cUsuario    := GetMV('MV_ECMUSER',,'')
Local cSenha      := GetMV('MV_ECMPSW',,'')
Local cEmpresa    := GetMV('MV_ECMEMP',,'0')
Local cSolicitId  := ''

Local aValores    := {}
Local aCardData   := {}
Local aSubs       := {}
Local xRet        := ""
Local cMensagem   := ""
Local cTag        := ""
Local cNomeArq    := ""
Local cErro       := ""
Local cAviso      := ""

Begin Sequence

	If  Empty(cArquivos)
		Break
	EndIf

  //Solicitante
	cSolicitId := JColId(cUsuario,cSenha,cEmpresa,cUsuario)

	aadd( aSubs, {'"', "'"})
	aadd( aSubs, {" xmlns='http://ws.workflow.ecm.technology.totvs.com/'", ""})

	aadd(aValores, {"username"          , cUsuario        })
	aadd(aValores, {"password"          , cSenha          })
	aadd(aValores, {"companyId"         , cEmpresa        })
	aadd(aValores, {"documentId"        , ""              })
	aadd(aValores, {"colleagueId"       , cSolicitId      })

	For nA := 1 to Len(aArquivos)

		if (aArquivos[nA] != "0")
			aValores[4][2] := aArquivos[nA] //valor do documentId

			If  !( JA106TWSDL("ECMDocumentService", "getActiveDocument", aValores, aCardData, aSubs, @xRet, @cMensagem))
				Break
			EndIf

		  //Obtem somente a Tag do XML de retorno
			cTag := '</item>'
			nB   := At(StrTran(cTag,"/",""),xRet)
			xRet := SubStr(xRet, nB, Len(xRet))
			nB   := At(cTag,xRet) + Len(cTag) - 1
			xRet := Left(xRet, nB)

		  //Gera o objeto do Result Tag
			oXml := XmlParser( xRet, "_", @cErro, @cAviso )

			If  Empty(oXml)
				cMensagem := JMsgErrFlg(oXml)
				Break
			EndIf

			cNomeArq := oXml:_Item:_phisicalFile:TEXT

			//Grava a NUM
			RecLock( 'NUM', .T. )  // Trava registro

			NUM->NUM_FILIAL := xFilial( 'NUM' )
			NUM->NUM_COD    := GetSXENum("NUM","NUM_COD")
			NUM->NUM_FILENT := xFilial("NTA")
			NUM->NUM_ENTIDA := "NTA"
			NUM->NUM_CENTID := cFollowUp
			NUM->NUM_DOC    := aArquivos[nA]+";"+oXml:_Item:_version:TEXT
			NUM->NUM_NUMERO := ""
			NUM->NUM_DESC   := cNomeArq
			NUM->NUM_EXTEN  := ""

			MsUnlock()     // Destrava registro
			ConfirmSX8()
		EndIf
	Next nA

End Sequence

If  !( Empty(cMensagem) )
	ConOut('WSFluigJuridico: fGravaNUM: ' + STR0020 + cMensagem) //"Erro: "
EndIf


Return(lRetorno)




// ____________________________________________________________________________
/*
{Protheus.doc} MTGeraConsultivo
Metodo para gerar novo Assunto Jurídico.

@class   WSFluigJuridico
@param   NULLPARAM Nao exige parametro de entrada.
@author  Antonio Carlos Ferreira
@version 1.0
@since   08/07/2015
@return  AreasJuridicas Estrutura matriz com o código e descrição das areas jurídicas.
@sample
		...
		If  !( oObj:MTAreaJuridica() )
			...
		EndIf
		aAreas := oObj:MTAreaJuridicaResult
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

WSMETHOD MTGeraConsultivo ;
	WSRECEIVE AssuntoJuridico ;
	WSSEND    RetornoAssunto ;
	WSSERVICE WSFluigJuridico

Local oModel      := nil
Local oModel106   := nil
Local lRetorno    := .T.
Local cCliente    := ''
Local cLoja       := ''
Local cTipoFw     := ''
Local cCajuri     := ''
Local cCliLojCas  := ''
Local cRet        := ''
Local cSigla      := ''
Local cUsuInc     := ''
Local aDadosUser  := getUserId(self:AssuntoJuridico:EmailSolicitante)
Local cdFlwup     := ''
Local cPastaCaso  := ""
Local cResp       := ""
Local lPoolResp   := .F.
Private cTipoAsJ  := ''
Public c162TipoAs := ''

/*
	AssuntoJuridico
		WSData EmailSolicitante       As String
		WSData Solicitacao            As String
		WSData DataFw                 As String
		WSData Empresa                As String  //Cliente+Loja
		WSData Escritorio             As String
		WSData Area                   As String
		WSData Solicitante            As String
		WSData TipoAssuntoJuridico    As String
		WSData TipoSolicitacao        As String
		WSData Advogado               As String
		WSData DescricaoSolicitacao   As String
		WSData Observacoes            As String
		WSData StepDestino            As String
		WSData CampoRetorno           As String

	RetornoAssunto
		WSData NumeroConsulta         As String  //Codigo Assunto Juridico
		WSData CodigoJuridico         As String  //Cliente-Loja-Caso
		WSData FluxoAprovacao         As String
*/

Begin Sequence

	//--------------------------- ASSUNTO JURIDICO CONSULTIVO ---------------------------------------------------

	//Atualiza a filial do ambiente para a filial do escritorio ou do parâmetro
	If !AbreFilial(self:AssuntoJuridico:Escritorio)
		lRetorno := .F.
		Break
	EndIf

	cResp := self:AssuntoJuridico:Advogado

	If '@' $ cResp
		cSigla := AllTrim(JurGetDados("RD0", 7, xFilial("RD0")+ALLTRIM(UPPER(self:AssuntoJuridico:Advogado)), "RD0_SIGLA"))
	Else
		cSigla := GtByRspApl(StrTran(StrTran(cResp,'Pool:Group:',''),'_',' '))

		//-- Realiza nova busca considerando o caractere '_'
		If Empty(cSigla)
			cSigla := GtByRspApl(StrTran(cResp,'Pool:Group:',''))
		EndIf

		If !Empty(cSigla)
			lPoolResp := .T.
		EndIf
	EndIf

	cTipoAsJ   := self:AssuntoJuridico:TipoAssuntoJuridico
	c162TipoAs := cTipoAsJ
	__cUserId  := aDadosUser[1]
	cUsuInc    := Left(aDadosUser[2], TamSx3("NSZ_USUINC")[1])

	oModel := FWLoadModel("JURA095")
	oModel:SetOperation( 3 )  //Inclusao
	oModel:Activate()

	//Desmembra Empresa em Cliente e Loja
	cCliente := self:AssuntoJuridico:Empresa
	cCliente := If(Empty(cCliente), '', cCliente)
	cLoja    := Right(cCliente,TamSX3('A1_LOJA')[1])
	cCliente := Left(cCliente,TamSX3('A1_COD')[1])

	oModel:SetValue( "NSZMASTER","NSZ_CCLIEN", cCliente)
	oModel:SetValue( "NSZMASTER","NSZ_LCLIEN", cLoja)
	oModel:SetValue( "NSZMASTER","NSZ_CODWF" , self:AssuntoJuridico:Solicitacao)
	oModel:SetValue( "NSZMASTER","NSZ_TIPOAS", cTipoAsJ)
	oModel:SetValue( "NSZMASTER","NSZ_DTINCL", Date())
	oModel:SetValue( "NSZMASTER","NSZ_USUINC", cUsuInc)
	oModel:SetValue( "NSZMASTER","NSZ_CESCRI", self:AssuntoJuridico:Escritorio)
	oModel:SetValue( "NSZMASTER","NSZ_CAREAJ", self:AssuntoJuridico:Area)
	oModel:SetValue( "NSZMASTER","NSZ_SOLICI", self:AssuntoJuridico:Solicitante)
	oModel:SetValue( "NSZMASTER","NSZ_SIGLA1", cSigla)
	oModel:SetValue( "NSZMASTER","NSZ_DTENTR", Date())
	oModel:SetValue( "NSZMASTER","NSZ_DETALH", self:AssuntoJuridico:DescricaoSolicitacao)
	oModel:SetValue( "NSZMASTER","NSZ_OBSERV", self:AssuntoJuridico:Observacoes)
	oModel:SetValue( "NSZMASTER","NSZ_CTPSOL", self:AssuntoJuridico:TipoSolicitacao)

	If !( oModel:VldData() ) .Or. !( oModel:CommitData() )
		//cRet := "Cod: " + cCod + " - " + STR0020 + CRLF  // "Erro: "
		cRet := STR0020 + CRLF  // "Erro: "
		cRet += STR0021 + oModel:aErrorMessage[4] + CRLF + ; // "Campo: "
				STR0022 + oModel:aErrorMessage[5] + CRLF + ; // "Razao: "
				CRLF + oModel:aErrorMessage[6] + CRLF

		SetSoapFault("MTGeraConsultivo", cRet)
		JurConOut(cRet)
		lRetorno := .F.
		Break
	EndIf

	cCajuri    := oModel:GetValue("NSZMASTER","NSZ_COD")
	cCliLojCas := oModel:GetValue("NSZMASTER","NSZ_CCLIEN") + "-" + oModel:GetValue("NSZMASTER","NSZ_LCLIEN") + "-" + oModel:GetValue("NSZMASTER","NSZ_NUMCAS")

	oModel:DeActivate()

	//--------------------------- FOLLOW-UP ---------------------------------------------------

	cTipoFw := JurGetDados("NYA", 1, xFilial("NYA")+self:AssuntoJuridico:TipoSolicitacao, "NYA_TIPOFW")

	If lRetorno .And. !Empty(cTipoFw) .And. !lPoolResp

		oModel106 := FWLoadModel("JURA106")
		oModel106:SetOperation( 3 )  //Inclusao
		oModel106:Activate()

		oModel106:SetValue( "NTAMASTER", "NTA_DTINC" , Date())
		oModel106:SetValue( "NTAMASTER", "NTA_CTIPO" , cTipoFw)
		oModel106:SetValue( "NTAMASTER", "NTA_DESC"  , self:AssuntoJuridico:DescricaoSolicitacao)
		oModel106:SetValue( "NTAMASTER", "NTA_DTFLWP", CToD(self:AssuntoJuridico:DataFw))
		oModel106:SetValue( "NTAMASTER", "NTA_USUINC", cUsuInc)

		oModel106:SetValue( "NTEDETAIL", "NTE_SIGLA" , cSigla)

		//Movimento ao concluir o follow-up
		oModel106:SetValue( "NZMDETAIL", "NZM_CODWF" , self:AssuntoJuridico:Solicitacao)
		oModel106:SetValue( "NZMDETAIL", "NZM_CSTEP" , self:AssuntoJuridico:StepDestino)
		oModel106:SetValue( "NZMDETAIL", "NZM_CAMPO" , self:AssuntoJuridico:CampoRetorno)
		oModel106:SetValue( "NZMDETAIL", "NZM_STATUS", "2")

		oModel106:GetModel( "NZMDETAIL" ):AddLine()
		//Movimento ao cancelar o follow-up
		oModel106:SetValue( "NZMDETAIL", "NZM_CODWF" , self:AssuntoJuridico:Solicitacao)
		oModel106:SetValue( "NZMDETAIL", "NZM_CSTEP" , self:AssuntoJuridico:StepDestinoFalha)
		oModel106:SetValue( "NZMDETAIL", "NZM_CAMPO" , self:AssuntoJuridico:CampoRetorno)
		oModel106:SetValue( "NZMDETAIL", "NZM_STATUS", "3")

		If !( oModel106:VldData() ) .Or. !( oModel106:CommitData() )
			//cRet += "Cod: " + cCod + " - " + STR0020 + CRLF  // "Erro: "
			cRet := STR0020 + CRLF  // "Erro: "
			cRet += STR0021 + oModel106:aErrorMessage[4] + CRLF + ; // "Campo: "
					STR0022 + oModel106:aErrorMessage[5] + CRLF + ; // "Razao: "
					CRLF + oModel106:aErrorMessage[6] + CRLF

			SetSoapFault("MTGeraConsultivo", cRet)
			JurConOut(cRet)
			lRetorno := .F.
			Break
		EndIf

		cdFlwup := oModel106:GetValue("NTAMASTER","NTA_COD")

		oModel106:DeActivate()

	EndIf

	//--------------------------- RETORNO ---------------------------------------------------

	If lRetorno

		cPastaCaso := JurGetDados("NZ7", 1, xFilial("NZ7") + StrTran(cCliLojCas, "-", ""), "NZ7_LINK")
		cPastaCaso := AllTrim( Left(cPastaCaso, At(";", cPastaCaso) - 1) )

		self:RetornoAssunto:NumeroConsulta := cCajuri
		self:RetornoAssunto:CodigoJuridico := cCliLojCas
		self:RetornoAssunto:FluxoAprovacao := IIF( (SuperGetMV('MV_JFLUIGA',,'2') == '1' .And. !Empty(cTipoFw)), 'true', 'false')
		self:RetornoAssunto:CodigoFollowup := cdFlwup
		self:RetornoAssunto:PastaCaso	   := cPastaCaso
	EndIf

End Sequence

Return(lRetorno)

// ____________________________________________________________________________
/*
{Protheus.doc} MTGeraContratoAssuntoJuridico
Metodo para gerar novo Assunto Jurídico de Contrato.

@class   WSFluigJuridico
@param   NULLPARAM Nao exige parametro de entrada.
@author  Antonio Carlos Ferreira
@version 1.0
@since   08/07/2015
@return  AreasJuridicas Estrutura matriz com o código e descrição das areas jurídicas.
@sample
		...
		If  !( oObj:MTAreaJuridica() )
			...
		EndIf
		aAreas := oObj:MTAreaJuridicaResult
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
WSMETHOD MTGeraContratoAssuntoJuridico ;
	WSRECEIVE ContratoAssuntoJuridico;
	WSSEND    RetornoAssunto ;
	WSSERVICE WSFluigJuridico

Local oModel     := nil
Local oModelNT9  := nil
Local oModel106  := nil
Local oModel184  := nil // Partes Contrárias
Local lRetorno   := .T.
Local cCliente   := ''
Local cLoja      := ''
Local cRet       := ''
Local cTipoFw    := ''
Local cCajuri    := ''
Local cCliLojCas := ''
Local cSigla     := ''
Local cUsuInc    := ''
Local cPoloAtivo := ''
Local cEntPoloA  := ''
Local cPoloPassi := ''
Local cEntPoloP  := ''
Local cTipoP     := ''
Local cCGC       := ''
Local cRenova    := ''
Local aDadosUser := getUserId(self:ContratoAssuntoJuridico:EmailSolicitante)
Local cdFlwup 	:= ''
Local cPastaCaso := ""
Local lPoolResp  := .F.
Local cResp      := ""

Local cTipoC	 := ""
Local cCampo	 := ""
Local xValor	 := ""
Local nl		 := 0

Public c162TipoAs := ''

Begin Sequence

	//--------------------------- ASSUNTO JURIDICO ---------------------------------------------------

	//Atualiza a filial do ambiente para a filial do escritorio ou do parâmetro
	If !AbreFilial(self:ContratoAssuntoJuridico:Escritorio)
		lRetorno := .F.
		Break
	EndIf

	cResp := self:ContratoAssuntoJuridico:Advogado

	If "@" $ cResp
		cSigla := AllTrim(JurGetDados("RD0", 7, xFilial("RD0")+ALLTRIM(UPPER(self:ContratoAssuntoJuridico:Advogado)), "RD0_SIGLA"))
	Else
		cSigla := GtByRspApl(StrTran(StrTran(cResp,'Pool:Group:',''),'_',' '))

		//-- Realiza nova busca considerando o caractere '_'
		If Empty(cSigla)
			cSigla := GtByRspApl(StrTran(cResp,'Pool:Group:',''))
		EndIf

		If !Empty(cSigla)
			lPoolResp := .T.
		EndIf
	EndIf

	cTipoAsJ 	:= self:ContratoAssuntoJuridico:TipoAssuntoJuridico
	c162TipoAs 	:= cTipoAsJ
	__cUserId 	:= aDadosUser[1]
	cUsuInc   	:= Left(aDadosUser[2], TamSx3("NSZ_USUINC")[1])

	cPoloAtivo := self:ContratoAssuntoJuridico:PoloAtivo
	cEntPoloA  := self:ContratoAssuntoJuridico:EntPoloAtivo
	cPoloPassi := self:ContratoAssuntoJuridico:PoloPassivo
	cEntPoloP  := self:ContratoAssuntoJuridico:EntPoloPassivo

	If Empty(AllTrim(cPoloAtivo)) .Or. Empty(AllTrim(cPoloPassi))

		cTipoP := self:ContratoAssuntoJuridico:TipoPessoaParteC
		cCGC   := self:ContratoAssuntoJuridico:CGCParteC

		If cTipoP == '1'
			If Empty(AllTrim(cCGC))
				cCGC := '00000000000'
			EndIf
		ElseIf cTipoP == '2'
			If Empty(AllTrim(cCGC))
				cCGC := '00000000000000'
			EndIf
		EndIf

		oModel184 := FWLoadModel("JURA184") // Partes Contrárias
		oModel184:SetOperation( 3 )  //Inclusao
		oModel184:Activate()

		oModel184:SetValue( "NZ2MASTER","NZ2_NOME"  , self:ContratoAssuntoJuridico:NomeParteC)
		oModel184:SetValue( "NZ2MASTER","NZ2_TIPOP" , cTipoP)
		oModel184:SetValue( "NZ2MASTER","NZ2_CGC"   , cCGC)
		oModel184:SetValue( "NZ2MASTER","NZ2_ESTADO", self:ContratoAssuntoJuridico:EstadoParteC)
		oModel184:SetValue( "NZ2MASTER","NZ2_CMUNIC", JurGetDados( "CC2", 4, xFilial("CC2") + UPPER(self:ContratoAssuntoJuridico:EstadoParteC) + UPPER(self:ContratoAssuntoJuridico:MunicipioParteC), "CC2_CODMUN") )
		oModel184:SetValue( "NZ2MASTER","NZ2_CEP"   , self:ContratoAssuntoJuridico:CEPParteC)
		oModel184:SetValue( "NZ2MASTER","NZ2_ENDE"  , self:ContratoAssuntoJuridico:EnderecoParteC)
		oModel184:SetValue( "NZ2MASTER","NZ2_BAIRRO", self:ContratoAssuntoJuridico:BairroParteC)

		If !( oModel184:VldData()) .Or. !( oModel184:CommitData())
			cRet := STR0020 + CRLF  // "Erro: "
			cRet += STR0021 + oModel184:aErrorMessage[4] + CRLF + ; // "Campo: "
					STR0022 + oModel184:aErrorMessage[5] + CRLF + ; // "Razao: "
					CRLF + oModel184:aErrorMessage[6] + CRLF

			SetSoapFault("MTGeraContratoAssuntoJuridico", cRet)
			JurConOut(cRet)
			lRetorno := .F.
			Break
		EndIf

		If Empty(AllTrim(cPoloAtivo))
			cEntPoloA  := 'NZ2'
			cPoloAtivo := oModel184:GetValue( "NZ2MASTER","NZ2_COD" )
		Else
			cEntPoloP  := 'NZ2'
			cPoloPassi := oModel184:GetValue( "NZ2MASTER","NZ2_COD" )
		EndIf

		oModel184:DeActivate()

	EndIf

	oModel := FWLoadModel("JURA095")
	oModel:SetOperation( 3 )  //Inclusao
	oModel:Activate()

	//Desmembra o Envolvido em Cliente e Loja
	If cEntPoloA == 'SA1'
		cCliente := cPoloAtivo
	ElseIf cEntPoloP == 'SA1'
		cCliente := cPoloPassi
	EndIf

	cCliente := If(Empty(cCliente), '', cCliente)
	cLoja    := Right(cCliente,TamSX3('A1_LOJA')[1])
	cCliente := Left(cCliente,TamSX3('A1_COD')[1])

	If Empty(AllTrim(self:ContratoAssuntoJuridico:RenovacaoAuto))
		cRenova := '2'
	Else
		cRenova := AllTrim(self:ContratoAssuntoJuridico:RenovacaoAuto)
	EndIf

	oModel:SetValue( "NSZMASTER","NSZ_CCLIEN", cCliente)
	oModel:SetValue( "NSZMASTER","NSZ_LCLIEN", cLoja)
	oModel:SetValue( "NSZMASTER","NSZ_CODWF" , self:ContratoAssuntoJuridico:Solicitacao)
	oModel:SetValue( "NSZMASTER","NSZ_TIPOAS", cTipoAsJ)
	oModel:SetValue( "NSZMASTER","NSZ_DTINCL", Date())
	oModel:SetValue( "NSZMASTER","NSZ_USUINC", cUsuInc)
	oModel:SetValue( "NSZMASTER","NSZ_CESCRI", self:ContratoAssuntoJuridico:Escritorio)
	oModel:SetValue( "NSZMASTER","NSZ_CAREAJ", self:ContratoAssuntoJuridico:Area)
	oModel:SetValue( "NSZMASTER","NSZ_SOLICI", self:ContratoAssuntoJuridico:Solicitante)
	oModel:SetValue( "NSZMASTER","NSZ_SIGLA1", cSigla)
	oModel:SetValue( "NSZMASTER","NSZ_DTENTR", Date())
	oModel:SetValue( "NSZMASTER","NSZ_DETALH", self:ContratoAssuntoJuridico:DescricaoSolicitacao)
	oModel:SetValue( "NSZMASTER","NSZ_OBSERV", self:ContratoAssuntoJuridico:Observacoes)
	oModel:SetValue( "NSZMASTER","NSZ_VLCONT", Val(self:ContratoAssuntoJuridico:ValorContrato))
	oModel:SetValue( "NSZMASTER","NSZ_DTINVI", CToD(self:ContratoAssuntoJuridico:VigenciaInicio))
	oModel:SetValue( "NSZMASTER","NSZ_DTTMVI", CToD(self:ContratoAssuntoJuridico:VigenciaFim))
	oModel:SetValue( "NSZMASTER","NSZ_FPGTO" , self:ContratoAssuntoJuridico:Condicao)
	oModel:SetValue( "NSZMASTER","NSZ_CODCON", self:ContratoAssuntoJuridico:TipoContrato)
	oModel:SetValue( "NSZMASTER","NSZ_RENOVA", cRenova)

	//	Glaicon - Campos customizados - Contrato
	If self:ContratoAssuntoJuridico:CampoCustomizados != Nil
		For nl:= 1 to len(self:ContratoAssuntoJuridico:CampoCustomizados)
			cTipoC := SubStr(self:ContratoAssuntoJuridico:CampoCustomizados[nl]:cCampo,1,1)
			If cTipoC == "C"
				cTipoC := SubStr(self:ContratoAssuntoJuridico:CampoCustomizados[nl]:cCampo,2,1)
				cCampo := AllTrim(SubStr(self:ContratoAssuntoJuridico:CampoCustomizados[nl]:cCampo,3,15))
				xValor := CastType(self:ContratoAssuntoJuridico:CampoCustomizados[nl]:cValor, cTipoC)
				if !Empty(xValor) .And. oModel:HasField("NSZMASTER",cCampo)
					oModel:SetValue( "NSZMASTER", cCampo, xValor)
				Endif
			EndIf
		Next
	EndIf

	//--------------------------- ENVOLVIDOS ---------------------------------------------------

	oModelNT9 := oModel:GetModel("NT9DETAIL")

	J105SetDados(cEntPoloA, cPoloAtivo)
	oModelNT9:SetValue("NT9_ENTIDA", cEntPoloA)
	oModelNT9:SetValue("NT9_CODENT", cPoloAtivo)
	oModelNT9:SetValue("NT9_PRINCI", "1") //Sim
	oModelNT9:SetValue("NT9_TIPOEN", "1") //Polo Ativo
	oModelNT9:SetValue("NT9_CTPENV", JurGetDados( "NQA", 2, xFilial("NQA") + "Contratante", "NQA_COD"))

	//	Glaicon - Campos Customizados - Polo Ativo
	If self:ContratoAssuntoJuridico:CampoCustomizados != Nil
		For nl:= 1 to len(self:ContratoAssuntoJuridico:CampoCustomizados)
			cTipoC := SubStr(self:ContratoAssuntoJuridico:CampoCustomizados[nl]:cCampo,1,1)
			If cTipoC == "A"
				cTipoC := SubStr(self:ContratoAssuntoJuridico:CampoCustomizados[nl]:cCampo,2,1)
				cCampo := AllTrim(SubStr(self:ContratoAssuntoJuridico:CampoCustomizados[nl]:cCampo,3,15))
				xValor := CastType(self:ContratoAssuntoJuridico:CampoCustomizados[nl]:cValor, cTipoC)
				if !Empty(xValor) .And. oModelNT9:HasField(cCampo)
					oModelNT9:SetValue( cCampo, xValor)
				Endif
			EndIf
		Next
	EndIf

	oModelNT9:AddLine()

	J105SetDados(cEntPoloP, cPoloPassi)
	oModelNT9:SetValue("NT9_ENTIDA", cEntPoloP)
	oModelNT9:SetValue("NT9_CODENT", cPoloPassi)
	oModelNT9:SetValue("NT9_PRINCI", "1") //Nao
	oModelNT9:SetValue("NT9_TIPOEN", "2") //Polo Passivo
	oModelNT9:SetValue("NT9_CTPENV", JurGetDados( "NQA", 2, xFilial("NQA") + "Contratado", "NQA_COD"))

	//	Glaicon - Campos Customizados - Polo Passivo
	If self:ContratoAssuntoJuridico:CampoCustomizados != Nil
		For nl:= 1 to len(self:ContratoAssuntoJuridico:CampoCustomizados)
			cTipoC := SubStr(self:ContratoAssuntoJuridico:CampoCustomizados[nl]:cCampo,1,1)
			If cTipoC == "P"
				cTipoC := SubStr(self:ContratoAssuntoJuridico:CampoCustomizados[nl]:cCampo,2,1)
				cCampo := AllTrim(SubStr(self:ContratoAssuntoJuridico:CampoCustomizados[nl]:cCampo,3,15))
				xValor := CastType(self:ContratoAssuntoJuridico:CampoCustomizados[nl]:cValor, cTipoC)
				If !Empty(xValor) .And. oModelNT9:HasField(cCampo)
					If oModelNT9:canSetValue(cCampo)
						oModelNT9:SetValue( cCampo, xValor)
					Else
						oModelNT9:LoadValue( cCampo, xValor)
					Endif
				Endif
			EndIf
		Next
	EndIf

	// Ponto de entrada - Cadastro de Contrato.
	// oModel - Modelo da JURA095
	// Self:ContratoAssuntoJuridico - Parte dos campos customizados
	If Existblock( 'JWSFLGCCNT' )
		Execblock('JWSFLGCCNT', .F., .F., {@oModel, Self:ContratoAssuntoJuridico:CampoCustomizados})
	EndIf

	If !( oModel:VldData() ) .Or. !( oModel:CommitData() )
		cRet := STR0020 + CRLF  // "Erro: "
		cRet += STR0021 + oModel:aErrorMessage[4] + CRLF + ; // "Campo: "
				STR0022 + oModel:aErrorMessage[5] + CRLF + ; // "Razao: "
				CRLF + oModel:aErrorMessage[6] + CRLF

		SetSoapFault("MTGeraContratoAssuntoJuridico", cRet)
		JurConOut(cRet)
		lRetorno := .F.
		Break
	EndIf

	cCajuri    := oModel:GetValue( "NSZMASTER","NSZ_COD" )
	cCliLojCas := oModel:GetValue( "NSZMASTER","NSZ_CCLIEN" ) + "-" + oModel:GetValue( "NSZMASTER","NSZ_LCLIEN" ) + "-" + oModel:GetValue( "NSZMASTER","NSZ_NUMCAS" )

	oModel:DeActivate()

	//--------------------------- FOLLOW-UP ---------------------------------------------------

	cTipoFw := JurGetDados("NY0", 1, xFilial("NY0")+self:ContratoAssuntoJuridico:TipoContrato, "NY0_TIPOFW")

	If lRetorno .And. !Empty(cTipoFw) .And. !lPoolResp
		oModel106 := FWLoadModel("JURA106")
		oModel106:SetOperation( 3 )  //Inclusao
		oModel106:Activate()

		oModel106:SetValue( "NTAMASTER", "NTA_DTINC" , Date())
		oModel106:SetValue( "NTAMASTER", "NTA_CTIPO" , cTipoFw)
		oModel106:SetValue( "NTAMASTER", "NTA_DESC"  , self:ContratoAssuntoJuridico:DescricaoSolicitacao)
		oModel106:SetValue( "NTAMASTER", "NTA_DTFLWP", CToD(self:ContratoAssuntoJuridico:DataInclusao))
		oModel106:SetValue( "NTAMASTER", "NTA_USUINC", cUsuInc)

		oModel106:SetValue( "NTEDETAIL", "NTE_SIGLA" , cSigla )

		//Criação das linhas caso tenha ocorrido a conclusão ou cancelamento do follow-up
		If !Empty(AllTrim(self:ContratoAssuntoJuridico:StepDestinoConc))
			oModel106:SetValue( "NZMDETAIL", "NZM_CODWF" , self:ContratoAssuntoJuridico:Solicitacao)
			oModel106:SetValue( "NZMDETAIL", "NZM_CSTEP" , self:ContratoAssuntoJuridico:StepDestinoConc)
			oModel106:SetValue( "NZMDETAIL", "NZM_CAMPO" , self:ContratoAssuntoJuridico:CampoRetorno)
			oModel106:SetValue( "NZMDETAIL", "NZM_STATUS", "2" )
		EndIf

		If !Empty(AllTrim(self:ContratoAssuntoJuridico:StepDestinoCanc))
			If !(oModel106:GetModel("NZMDETAIL"):IsEmpty())
				oModel106:GetModel("NZMDETAIL"):AddLine()
			EndIf
			oModel106:SetValue( "NZMDETAIL", "NZM_CODWF" , self:ContratoAssuntoJuridico:Solicitacao)
			oModel106:SetValue( "NZMDETAIL", "NZM_CSTEP" , self:ContratoAssuntoJuridico:StepDestinoCanc)
			oModel106:SetValue( "NZMDETAIL", "NZM_CAMPO" , self:ContratoAssuntoJuridico:CampoRetorno)
			oModel106:SetValue( "NZMDETAIL", "NZM_STATUS", "3" )
		EndIf

		If !( oModel106:VldData() ) .Or. !( oModel106:CommitData() )
			cRet := STR0020 + CRLF  // "Erro: "
			cRet += STR0021 + oModel106:aErrorMessage[4] + CRLF + ; // "Campo: "
					STR0022 + oModel106:aErrorMessage[5] + CRLF + ; // "Razao: "
					CRLF + oModel106:aErrorMessage[6] + CRLF

			SetSoapFault("MTGeraContratoAssuntoJuridico", cRet)
			JurConOut(cRet)
			lRetorno := .F.
			Break
		EndIf

		cdFlwup := oModel106:GetValue("NTAMASTER","NTA_COD")

		oModel106:DeActivate()

	EndIf

	//--------------------------- RETORNO ---------------------------------------------------

	If lRetorno

		cPastaCaso := JurGetDados("NZ7", 1, xFilial("NZ7") + StrTran(cCliLojCas, "-", ""), "NZ7_LINK")
		cPastaCaso := AllTrim( Left(cPastaCaso, At(";", cPastaCaso) - 1) )

		self:RetornoAssunto:NumeroConsulta := cCajuri
		self:RetornoAssunto:CodigoJuridico := cCliLojCas
		self:RetornoAssunto:FluxoAprovacao := IIF( (SuperGetMV('MV_JFLUIGA',,'2') == '1' .And. !Empty(cTipoFw)), 'true', 'false')
		self:RetornoAssunto:CodigoFollowup := cdFlwup
		self:RetornoAssunto:PastaCaso	   := cPastaCaso
	EndIf

End Sequence

Return(lRetorno)

// ____________________________________________________________________________
/*
{Protheus.doc} MTJurEncerraAssJur
Metodo para encerramento da consulta/contrato após seu término ou após
cancelamento

@class   WSFluigJuridico
@param   oEncerramento Informações para preenchimento de campos do encerramento.
@author  Jorge Luis Branco Martins Junior
@version 1.0
@since   09/09/2015
@return  lRetorno Indica se houve o encerramento do processo

*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

WSMETHOD MTJurEncerraAssJur ;
	WSRECEIVE oEncerramento ;
	WSSEND    Ok ;
	WSSERVICE WSFluigJuridico

Local lRetorno   := .T.
Local oModel     := nil
Local oMMaster   := nil
Local aAux       := {}
Local aAnds      := {}
Local cMotEnc    := ""
Local cStatus    := self:oEncerramento:Status
Local cDetEnc    := self:oEncerramento:Observacoes
Local cCAJuri    := self:oEncerramento:AssuntoJuridico
Local cTpAs      := self:oEncerramento:TipoAssuntoJuridico
Local aDadosUser := getUserId(self:oEncerramento:EmailUsuarioEncerra)
Local cUsuEnc    := Left(aDadosUser[2], TamSX3('NSZ_USUENC')[1])
Local cAto       := SuperGetMv("MV_JATOHIF", , "")

Private cTipoAsj  := ""
Public c162TipoAs := ''

/*
	WSStruct StruEncerra
		WSData TipoAssuntoJuridico    As String
		WSData AssuntoJuridico        As String
		WSData Status                 As String // 1=Concluido / 2=Cancelado
		WSData Observacoes            As String
		WSData EmailUsuarioEncerra    As String
		WSData Escritorio		      As String
	EndWSStruct
*/
Begin Sequence

	//Atualiza a filial do ambiente para a filial do escritorio ou do parâmetro
	If !AbreFilial(self:oEncerramento:Escritorio)
		lRetorno := .F.
		Break
	EndIf

	If cTpAs > '050'
		cTpAs := JurGetDados('NYB', 1, xFilial('NYB') + cTpAs, 'NYB_CORIG')
	EndIf

	DbSelectArea('NSZ')
	NSZ->( DbSetOrder(1) ) //NSZ_FILIAL+NSZ_COD

	If Empty( cCAJuri ) .Or. Empty( cStatus )
		SetSoapFault("MTJurEncerraAssJur", STR0015) //"Parâmetros obrigatórios faltando, favor verificar!"
		JurConOut(STR0015) //"Parâmetros obrigatórios faltando, favor verificar!"
		lRetorno := .F.
		Break
	EndIf

	If !( NSZ->( DbSeek(xFilial('NSZ') + cCAJuri) ) )
		SetSoapFault("MTJurEncerraAssJur", I18n(STR0030, {cCAJuri}))	//"Código não encontrado no cadastro de Assuntos Jurídicos! Código: #1"
		JurConOut(STR0030, {cCAJuri})									//"Código não encontrado no cadastro de Assuntos Jurídicos! Código: #1"
		lRetorno := .F.
		Break
	EndIf

	c162TipoAs := NSZ->NSZ_TIPOAS
	cTipoAsJ   := NSZ->NSZ_TIPOAS

	//Indica se a consulta está sendo encerrada ou cancelada
	If cStatus == "1" //Encerramento
		If cTpAs == "005" //Consultivo
			cMotEnc := JurGetDados('NYA', 1, xFilial('NYA') + NSZ->NSZ_CTPSOL, 'NYA_CMOENC')
		ElseIf cTpAs == "006" //Consultivo
			cMotEnc := JurGetDados('NY0', 1, xFilial('NY0') + NSZ->NSZ_CODCON, 'NY0_CMOENC')
		EndIf
	Else
		If cTpAs == "005" //Consultivo
			cMotEnc := JurGetDados('NYA', 1, xFilial('NYA') + NSZ->NSZ_CTPSOL, 'NYA_CMOCAN')
		ElseIf cTpAs == "006" //Consultivo
			cMotEnc := JurGetDados('NY0', 1, xFilial('NY0') + NSZ->NSZ_CODCON, 'NY0_CMOCAN')
		EndIf
	EndIf

	If (!Empty(cDetEnc) .And. !Empty(cMotEnc))

		__cUserId  := aDadosUser[1]

		//Grava o histórico da tarefa do Fluig
		J95HisFlu(NSZ->NSZ_FILIAL, NSZ->NSZ_COD)

		INCLUI := .F.
		ALTERA := .T.

		oModel := FWLoadModel( 'JURA095' )
		oModel:SetOperation( 4 )
		oModel:Activate()

		oMMaster := oModel:GetModel( 'NSZMASTER' )

		oMMaster:SetValue('NSZ_SITUAC', "2")     //Situação "Encerrado"
		oMMaster:SetValue('NSZ_USUENC', cUsuEnc) //Grava o usuário de encerramento
		oMMaster:SetValue('NSZ_DTENCE', Date())  //Grava a data do encerramento
		oMMaster:SetValue('NSZ_CMOENC', cMotEnc) //Grava o motivo do encerramento
		oMMaster:SetValue('NSZ_DETENC', cDetEnc) //Grava o detalhe do encerramento

		If !( oModel:VldData() )
			SetSoapFault("MTJurEncerraAssJur", I18n(STR0031, {cCAJuri}))		//"Problema na validação do assunto jurídico! Codigo: #1"
			JurConOut(STR0031, {cCAJuri})										//"Problema na validação do assunto jurídico! Codigo: #1"
			lRetorno := .F.
			Break
		EndIf

		If !( oModel:CommitData() )
			SetSoapFault("MTJurEncerraAssJur", I18n(STR0032, {cCAJuri}))	//"Problema no commit do assunto jurídico! Codigo: #1"
			JurConOut(STR0032, {cCAJuri}) 									//"Problema no commit do assunto jurídico! Codigo: #1"
			lRetorno := .F.
			Break
		EndIf

		//Grava um andamento no momento do cancelamento ou da finalização da solicitação de Consultas/Pareceres via fluig
		If Empty(cAto)
			JurMsgErro( I18n(STR0042, {"(MV_JATOHIF)"}) ) //"Parâmetro não preenchido, andamento não será gerado.#1"
		Else
			If (NSZ->NSZ_SITUAC) == "2" .and. cTpAs == "005" //Valida se o processo já foi encerrado e se ele é consultivo
				Aadd(aAux, {"NT4_CAJURI", NSZ->NSZ_COD } )
				Aadd(aAux, {"NT4_DESC"	, cDetEnc      } )   //Grava o detalhe do encerramento do processo na descrição do andamento
				Aadd(aAux, {"NT4_DTANDA", Date()       } )
				Aadd(aAux, {"NT4_CATO"	, cAto         } )

				Aadd(aAnds, aAux)

				//Grava andamentos
				If Len(aAnds) > 0
					lRetorno := J100GrvAnd(aAnds)
				EndIf
			EndIf
		EndIf

		oModel:DeActivate()

	Else
		SetSoapFault("MTJurEncerraAssJur", I18n(STR0035, {cCAJuri})) 	//"Detalhe ou motivo não informados. assunto jurídico! Codigo: #1"
		JurConOut(STR0035, {cCAJuri}) 									//"Detalhe ou motivo não informados. assunto jurídico! Codigo: #1"
		lRetorno := .F.
	Endif

End Sequence

self:Ok := lRetorno

Return(lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} MTGeraMinuta
Metodo para gerar petições automáticas

@class   WSFluigJuridico

@param   CodAssuntoJuridico - Código do assunto juridico (NSZ)
		  CodTipoContrato - Código do tipo de contrato (NY0)

@author  Jorge Luis Branco Martins Junior
@version 1.0
@since   14/09/2015
@return  IdMinuta - ID do documento gerado no FLUIG

/*/
//-------------------------------------------------------------------
WSMETHOD      MTGeraMinuta ;
	WSRECEIVE CodAssuntoJuridico, CodTipoContrato, Escritorio, CodTipoImpressao ;
	WSSEND    IdMinuta ;
	WSSERVICE WSFluigJuridico

Local lRetorno   := .T.
Local cCAJuri    := self:CodAssuntoJuridico
Local cTpCont    := self:CodTipoContrato
Local cTpImpr    := self:CodTipoImpressao
Local cCfgRelat  := ""
Local cPart      := ""
Local cUserFluig := ""

Begin Sequence

	If Empty(cTpImpr)
		cTpImpr := "W"
	EndIf
	//Atualiza a filial do ambiente para a filial do escritorio ou do parâmetro
	If !AbreFilial(self:Escritorio)
		lRetorno := .F.
		Break
	EndIf

	cCfgRelat := JurGetDados("NY0",1,xFilial("NY0") + cTpCont, "NY0_CODREL")
	cPart      := JurGetDados("NSZ",1,xFilial("NSZ") + CodAssuntoJuridico, "NSZ_CPART1")
	cUserFluig := JurGetDados("RD0",1,xFilial("RD0") + cPart, "RD0_USER")

	__cUserId := AllTrim(cUserFluig) //Seta o cod usuário

	DbSelectArea('NSZ')
	NSZ->( DbSetOrder(1) ) //NSZ_FILIAL+NSZ_COD
	NSZ->( dbGoTop())

	If !( NSZ->( DbSeek(xFilial('NSZ') + cCAJuri) ) )
		SetSoapFault("MTGeraMinuta", I18n(STR0033, {cCAJuri}))	//"Código não encontrado no cadastro de Assuntos Jurídicos! Código: #1"
		JurConOut(STR0033, {cCAJuri})							//"Código não encontrado no cadastro de Assuntos Jurídicos! Código: #1"
		lRetorno := .F.
		Break
	EndIf

	If lRetorno
		cLink := JurGetDados("NZ7",1,xFilial("NZ7") + NSZ->NSZ_CCLIEN + NSZ->NSZ_LCLIEN + NSZ->NSZ_NUMCAS, "NZ7_LINK")
		nPos  := At(';', cLink)
		cLink := Left(cLink,nPos-1)
	EndIf

	If lRetorno
		If Empty(AllTrim(cLink)) .Or. Empty(AllTrim(cCfgRelat))
			self:IdMinuta := '0'
			SetSoapFault("MTGeraMinuta", STR0034)	//"Não existe pasta para o caso no FLUIG."
			JurConOut(STR0034)						//"Não existe pasta para o caso no FLUIG."
			lRetorno := .F.
		EndIf
	EndIf

	If lRetorno
		self:IdMinuta := J162StartBG(cCfgRelat,cCAJuri,cLink,/*lFluig*/,/*cFilNsz*/,cTpImpr)
	EndIf

End Sequence

Return(lRetorno)

// ____________________________________________________________________________
/*
{Protheus.doc} MTJurIncFollowUp
Metodo para inclusão de follow-ups no SIGAJURI a partir de alguma ação que
ocorreu no FLUIG.

@class   WSFluigJuridico
@param   FollowUp Codigo Follow-up.
@author  André Spirigoni Pinto
@version 1.0
@since   12/06/2015
@return  Status Status do Follow-up.
@sample

*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

WSMETHOD 		MTJurIncFollowUp ;
	WSRECEIVE 	oFollowup ;
	WSSEND 		CodFollowup ;
	WSSERVICE 	WSFluigJuridico

Local lRetorno   := .T.
Local oModel     := Nil
Local cResultado := ''
Local cTipoFu	 := ''
Local cPart      := ''
Local cUsuInc    := ''
Local cSigla     := ''
Local aDadosUser := {}
Local cErro		 := ""

Begin Sequence

	//Atualiza a filial do ambiente para a filial do escritorio ou do parâmetro
	If !AbreFilial(self:oFollowup:Escritorio)
		lRetorno := .F.
		Break
	EndIf

	If Empty( self:oFollowup:CodAssuntoJuridico ) .Or. Empty( self:oFollowup:Descricao )
		cErro := STR0015								//"Parâmetros obrigatórios faltando, favor verificar!"
		SetSoapFault("MTJurIncFollowUp", cErro)
		JurConOut(cErro)
		lRetorno := .F.
		Break
	EndIf

	//Valida participante obrigatorio NSZ_SIGLA1
	cPart := JurGetDados("NSZ", 1, xFilial("NSZ") + self:oFollowup:CodAssuntoJuridico, "NSZ_CPART1")

	If Empty(cPart)
		cErro := STR0015 + " - NSZ_CPART1: " + cPart	//"Parâmetros obrigatórios faltando, favor verificar!"
		SetSoapFault("MTJurIncFollowUp", cErro)
		JurConOut(cErro)
		lRetorno := .F.
		Break
	EndIf

	//Valida se recebeu o solicitante
	If !Empty(self:oFollowup:Solicitante)
		aDadosUser := getUserId(self:oFollowup:Solicitante)
		__cUserId  := aDadosUser[1]
		cUsuInc	   := aDadosUser[2]
	Else
   		__cUserId  := AllTrim( JurGetDados("RD0",1,xFilial("RD0") + cPart, "RD0_USER") )
   		cUsuInc	   := UsrRetName(__cUserId)
	EndIf

	//Obtem o código do resultado 1=Pendente
	DbSelectArea("NQN")
	NQN->( DbSetOrder(3) )		//NQN_FILIAL+NQN_TIPO

	If NQN->( DbSeek(xFilial("NQN") + "1") )
		cResultado := NQN->NQN_COD
	Else
		SetSoapFault("MTJurIncFollowUp", STR0016)	//"Status não encontrado no cadastro de Resultado Follow-up!"
		JurConOut(STR0016) 							//"Status não encontrado no cadastro de Resultado Follow-up!"
		lRetorno := .F.
		Break
	EndIf

	//Define o tipo do follow-up
	Do Case
		Case self:oFollowup:Origem == "Consultivo"
			cTipoFu := JurGetDados("NYA", 1, xFilial("NYA") + self:oFollowup:CodOrigem, "NYA_TIPOFW")
		Case self:oFollowup:Origem == "Contrato"
			cTipoFu := JurGetDados("NY0", 1, xFilial("NY0") + self:oFollowup:CodOrigem, "NY0_TIPOFW")
	EndCase

	//Usuário de inclusão.
	cUsuInc	:= Left(cUsuInc, TAMSX3("NTA_USUINC")[1])

	//Sigla do usuário
	cSigla	:= AllTrim( JurGetDados("RD0", 1, xFilial("RD0") + cPart, "RD0_SIGLA") )

	oModel := FWLoadModel( 'JURA106' )
	oModel:SetOperation( 3 )
	oModel:Activate()

	oModel:SetValue( "NTAMASTER", "NTA_CRESUL", cResultado)
	oModel:SetValue( "NTAMASTER", "NTA_CAJURI", self:oFollowup:CodAssuntoJuridico)
	oModel:SetValue( "NTAMASTER", "NTA_DTINC" , Date())
	oModel:SetValue( "NTAMASTER", "NTA_CTIPO" , cTipoFu)
	oModel:SetValue( "NTAMASTER", "NTA_DESC"  , self:oFollowup:Descricao)
	oModel:SetValue( "NTAMASTER", "NTA_DTFLWP", CToD(self:oFollowup:DataFw))
	oModel:SetValue( "NTAMASTER", "NTA_USUINC", cUsuInc)

	oModel:SetValue( "NTEDETAIL", "NTE_SIGLA" , cSigla)

	//Movimento ao concluir o follow-up
	oModel:SetValue( "NZMDETAIL", "NZM_CODWF" , self:oFollowup:Solicitacao)
	oModel:SetValue( "NZMDETAIL", "NZM_CSTEP" , self:oFollowup:StepDestino)
	oModel:SetValue( "NZMDETAIL", "NZM_CAMPO" , self:oFollowup:CampoRetorno)
	oModel:SetValue( "NZMDETAIL", "NZM_STATUS", "2")

	//Movimento ao cancelar o follow-up
	oModel:GetModel( "NZMDETAIL" ):AddLine()
	oModel:SetValue( "NZMDETAIL", "NZM_CODWF" , self:oFollowup:Solicitacao)
	oModel:SetValue( "NZMDETAIL", "NZM_CSTEP" , self:oFollowup:StepDestinoFalha)
	oModel:SetValue( "NZMDETAIL", "NZM_CAMPO" , self:oFollowup:CampoRetorno)
	oModel:SetValue( "NZMDETAIL", "NZM_STATUS", "3")

	If !oModel:VldData()
		SetSoapFault("MTJurIncFollowUp", STR0017) 	//"Problema na validação do follow-up! Codigo: "
		JurConOut(STR0017) 							//"Problema na validação do follow-up! Codigo: "
		lRetorno := .F.
		Break
	EndIf

	If !oModel:CommitData()
		SetSoapFault("MTJurIncFollowUp", STR0018) 	//"Problema no commit do follow-up! Codigo: "
		JurConOut(STR0018) 							//"Problema no commit do follow-up! Codigo: "
		lRetorno := .F.
		Break
	EndIf

	If lRetorno
		self:CodFollowup := oModel:GetValue("NTAMASTER", "NTA_COD")
	Else
		self:CodFollowup := "0"
	EndIf

	oModel:DeActivate()

End Sequence

Return lRetorno

// ____________________________________________________________________________
/*
{Protheus.doc} getUserId
Função que retorna o id do usuário do Protheus a partir de um e-mail.

@param   FollowUp Codigo Follow-up.
@author  André Spirigoni Pinto
@version 1.0
@since   18/05/2017
@return  Código do usuário Protheus
@sample
		...
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Static Function getUserId(cEmail)

	Local aArea		 := GetArea()
	Local cQuery   	 := ""
	Local cTrab  	 := GetNextAlias()
	Local cUserFluig := ""
	Local cNomeFluig := ""

	cQuery := "SELECT RD0_USER"
	cQuery += 	" FROM " + RetSqlName("RD0")
	cQuery += " WHERE RD0_FILIAL = '" + xFilial("RD0") + "'"
	cQuery += 	" AND ( LOWER(RD0_EMAIL) = '" + PADR( Lower( Alltrim(cEmail) ), TamSX3("RD0_EMAIL")[1], " ") + "'"	
	cQuery += 	" OR LOWER(RD0_EMAILC) = '" + PADR( Lower( Alltrim(cEmail) ), TamSX3("RD0_EMAILC")[1], " ") + "') "
	cQuery += 	" AND D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), cTrab, .T., .F.)

	If !(cTrab)->( Eof() )
		cUserFluig := AllTrim( (cTrab)->RD0_USER )
		cNomeFluig := AllTrim( UsrRetName(cUserFluig) )
	Else
		cUserFluig := "000000" 		//Codigo do Administrador
		cNomeFluig := AllTrim(cEmail)
		cNomeFluig := Left(cEmail, At("@", cEmail) - 1)
	EndIf

	(cTrab)->( DbCloseArea() )

	RestArea(aArea)

Return {cUserFluig, cNomeFluig}

//-------------------------------------------------------------------
/*/{Protheus.doc} MTAprovadorSigajuri
Metodo que ira retornar o e-mail do aprovador a partir dos participantes do processo.

@class   WSFluigJuridico
@param   Filial - Filial do processo
@param   CodAssuntoJuridico - Código do processo
@param   CampoAprovador - Campo que terá o aprovador retornado
@return  EmailAprovador - Email do aprovador
@author  Rafael Tenorio da Costa
@since   18/10/17
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD MTAprovadorSigajuri 								;
	WSRECEIVE 	Filial, CodAssuntoJuridico, CampoAprovador	;
	WSSEND 		EmailAprovador 								;
	WSSERVICE 	WSFluigJuridico

	Local lRetorno  := .T.
	Local cCodPart  := ""
	Local cEmail	:= ""
	Local cErro		:= ""

	//Atualiza a filial do ambiente para a filial do escritorio ou do parâmetro
	If !AbreFilial( ,self:Filial)
		lRetorno := .F.
	EndIf

	If lRetorno

		cCodPart := JurGetDados("NSZ", 1, self:Filial + self:CodAssuntoJuridico, self:CampoAprovador)

		If Empty(cCodPart)
			cErro := I18n(STR0037, {self:Filial, self:CodAssuntoJuridico, self:CampoAprovador})		//"Aprovador não localizado: Filial #1 Processo #2 Campo Aprovador #3"
		Else

			cEmail := JurGetDados("RD0", 1, xFilial("RD0") + cCodPart, "RD0_EMAIL")

			If Empty(cEmail)
				cErro := I18n(STR0038, {cCodPart})	//"Aprovador #1 sem e-mail cadastrado na tabela de participantes."
			Else
				self:EmailAprovador := cEmail
			EndIf
		EndIf

		If !Empty(cErro)
			lRetorno := .F.
			SetSoapFault("MTAprovadorSigajuri", cErro)
			JurConOut(cErro)
		EndIf

	EndIf

Return(lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} AbreFilial
Função que ira atualizar o ambiente para a filial do escritorio ou do parametro passado.

@param	 cEscritorio - Escritorio relacionado a NS7
@param	 cFil		 - Código da filial
@return  lRetorno 	 - Define se foi ou não atualizada a filial do ambiente
@author  Rafael Tenorio da Costa
@since   01/11/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static function AbreFilial(cEscritorio, cFil)

	Local lRetorno 	:= .T.
	Local cErro		:= ""
	Local cFuncao	:= ProcName(1)

	Default cEscritorio := ""
	Default cFil 		:= ""

	//Caso na configuração do appserver.ini na seção do web service a chave (PREPAREIN=99) esteja sem a filial a variavel cFilAnt estará em branco
	If Empty(cFilAnt)

		//Pega filial do escritório caso esteja em branco
		If Empty(cFil)
			cFil := JurGetDados('NS7', 1, xFilial('NS7') + Alltrim(cEscritorio), "NS7_CFILIA")
		EndIf

		If !Empty(cFil)
			cFilAnt := cFil
		Else
			lRetorno := .F.
			cErro	 := I18n(STR0039, {cFuncao, cEscritorio, cFil})		//"#1 - Escritório e Filial não encontrados. (#2|#3)"
			SetSoapFault(cFuncao, cErro)
			JurConOut(cErro)
		EndIf
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} CastType
Função que ira tratar o dado de uma variável por tipo informado.

@param	 cValor	 - Valor a ser tratado
@param	 cType	 - Tipo do dado
@return  xReturn - Dado tratado
@author  Willian Yoshiaki Kazahaya
@since   20/09/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CastType(cValor, cType)
Local xReturn
	If cType == "N"
		xReturn := Val(cValor)
	ElseIf cType == "D"
		xReturn := StoD(cValor)
	ElseIf cType == "L"
		xReturn := "." + AllTrim(cValor) + "."
	Else
	 	xReturn := cValor
	EndIf
Return xReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} GtByRspApl
Realiza Select na tabela Complementar do Participantes para pegar o
Grupo.

@param	 cResp - Apelido do responsável

@return  cRet - Sigla do Responsável
@author  Willian Yoshiaki Kazahaya
@since   23/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GtByRspApl(cResp)
Local cRet   := ""
Local cQuery := ""
Local cAlias := GetNextAlias()

	cQuery := " SELECT NUR_APELI "
	cQuery +=       " ,RD0_SIGLA "
	cQuery +=       " ,RD0_EMAIL "
	cQuery += " FROM " + RetSqlName("NUR") + " NUR INNER JOIN " + RetSqlName("RD0") + " RD0 ON (RD0.RD0_FILIAL = NUR.NUR_FILIAL "
	cQuery +=                                       " AND RD0_CODIGO = NUR.NUR_CPART)
	cQuery += " WHERE NUR_APELI = '" + JurLmpCpo(Upper(AllTrim(cResp))) + "'"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

	If !(cAlias)->( Eof() )
		cRet := (cAlias)->(RD0_SIGLA)
	EndIf

	(cAlias)->( DbCloseArea() )

Return cRet
// ____________________________________________________________________________
/*
{Protheus.doc} MTGetCPF
Metodo para obter o CPF do responsável a partir do e-mail.

@class   WSFluigJuridico
@param   cEmail
@author  Ronaldo Gonçalves de Oliveira
@version 1.0
@since   10/12/2018
@return  CPF do responsável.
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

WSMETHOD MTGetCPF ;
WSRECEIVE	cEmail;
WSSEND		cCPF ;
WSSERVICE	WSFluigJuridico

Local lRetorno   := .T.
Local aArea      := GetArea()
Local cQuery     := ""
Local cRD0       := GetNextAlias()

	cQuery := "SELECT MIN(RD0_CIC) CPF "
	cQuery +=  " FROM " + RetSqlName("RD0")
	cQuery += " WHERE RD0_FILIAL = '" + xFilial("RD0") + "'"
	cQuery +=   " AND LOWER(RD0_EMAIL) = '" + PADR( Lower( Alltrim(cEmail) ), TamSX3("RD0_EMAIL")[1], " ") + "'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), cRD0, .T., .F.)

	If !(cRD0)->( Eof() )
		self:cCPF := AllTrim( (cRD0)->CPF )
	Else
		self:cCPF := ""
	EndIf

	(cRD0)->( DbCloseArea() )

	RestArea(aArea)
Return(lRetorno)

//-------------------------------------------------------------------
/*
{Protheus.doc} MTAtualizaContrato
Metodo que ira atualizar as informações do contrato quando
alterados via Fluig.

@class   WSFluigJuridico
@param   AtualizaConsultivo
@since   17/12/2020
@return  True or False

	WSStruct StruAtualizaContra   to
		WSData RenovacaoAuto      As String
		WSData Escritorio         As String
		WSData Cajuri             As String
		WSData DescSolicitacao    As String
		WSData Observacao         As String
		WSData PoloAtivo          As String
		WSData PoloPassivo        As String
		WSData EntPoloPassivo     As String
		WSData EntPoloAtivo       As String
		WSData ValorContrato      As String
		WSData VigenciaInicio     As String
		WSData VigenciaFim        As String
		WSData CondPagamento      As String
		WSData NomeParteC         As String
		WSData CPFParteC          As String
		WSData EnderecoParteC     As String
		WSData BairroParteC       As String
		WSData UFParteC           As String
		WSData CEPParteC          As String
		WSData TipoParteC         As String
		WSData MunicParteC        As String
		WSDATA CampoCustomizados  AS Array of StruCustom OPTIONAL
	EndWSStruct
*/
//-------------------------------------------------------------------
WSMETHOD MTAtualizaContrato;
	WSRECEIVE AtualizaContrato ;
	WSSEND    Ok ;
	WSSERVICE WSFluigJuridico

Local cEscritorio  := self:AtualizaContrato:Escritorio
Local cCajuri      := self:AtualizaContrato:Cajuri
Local cDescSol     := self:AtualizaContrato:DescSolicitacao
Local cObservacao  := self:AtualizaContrato:Observacao
Local cRenovAuto   := AllTrim(self:AtualizaContrato:RenovacaoAuto)
Local cVlrContrato := self:AtualizaContrato:ValorContrato
Local cVigInicio   := self:AtualizaContrato:VigenciaInicio
Local cVigFim      := self:AtualizaContrato:VigenciaFim
Local cCondPag     := self:AtualizaContrato:CondPagamento
Local cPAtivo      := self:AtualizaContrato:PoloAtivo
Local cPPassivo    := self:AtualizaContrato:PoloPassivo
Local cEntPPassivo := self:AtualizaContrato:EntPoloPassivo
Local cEntPAtivo   := self:AtualizaContrato:EntPoloAtivo
Local cTipoPC      := self:AtualizaContrato:TipoParteC
Local cCpfPC       := self:AtualizaContrato:CPFParteC
Local cNomePC      := self:AtualizaContrato:NomeParteC
Local cUfPC        := self:AtualizaContrato:UFParteC
Local cCepPC       := self:AtualizaContrato:CEPParteC
Local cMunicPC     := self:AtualizaContrato:MunicParteC
Local cEndPC       := self:AtualizaContrato:EnderecoParteC
Local cBairroPC    := self:AtualizaContrato:BairroParteC
Local aCustomCpo   := self:AtualizaContrato:CampoCustomizados
Local oModel       := Nil
Local oModelNSZ    := Nil
Local oModelNT9    := Nil
Local lRetorno     := .T.
Local nI           := 1
Local aRetInsPC    := ''

Private cTipoAsj   := ''
Public c162TipoAs  := ''

Default aCustomCpo := {}

	Begin Sequence

	//Atualiza a filial do ambiente para a filial do escritorio ou do parâmetro
	If !AbreFilial(cEscritorio)
		lRetorno := .F.
		Break
	EndIf

	//--------------------------- Cadastro de parte Contrária ---------------------------------------------------
	If Empty(AllTrim(cPAtivo)) .Or. Empty(AllTrim(cPPassivo))
		aRetInsPC := JInsNewEnv(cTipoPC, cCpfPC, cNomePC, cUfPC, cCepPC, cMunicPC, cEndPC, cBairroPC, Empty(AllTrim(cPAtivo)))

		If !Empty(aRetInsPC[1]) // Mensagem de Erro da operação de inclusão da parte contrária
			SetSoapFault("MTAtualizaContrato", aRetInsPC[1])
			JurConOut(aRetInsPC[1])
			lRetorno := .F.
		EndIf

		If aRetInsPC[2][1] // É polo ativo?
			cEntPoloA := aRetInsPC[2][2] // Entidade da Parte Contrária
			cPAtivo   := aRetInsPC[2][3] // Id da Parte Contrária
		Else
			cEntPoloP := aRetInsPC[2][2] // Entidade da Parte Contrária
			cPPassivo := aRetInsPC[2][3] // Id da Parte Contrária
		EndIf
	EndIf

	If Empty(cRenovAuto)
		cRenovAuto := '2'
	EndIf

	If lRetorno
		DbSelectArea("NSZ")
		NSZ->(DbSetOrder(1)) //NSZ_FILIAL+NSZ_COD

		lRetorno := NSZ->(dbSeek(xFilial("NSZ") + cCajuri))

		If lRetorno
			c162TipoAs := NSZ->NSZ_TIPOAS
			cTipoAsJ   := NSZ->NSZ_TIPOAS

			oModel := FWLoadModel("JURA095")
			oModel:SetOperation( 4 ) //Alteração
			oModel:Activate()
			oModelNSZ := oModel:GetModel('NSZMASTER')

			//--------------------------- ASSUNTO JURIDICO ---------------------------------------------------//
			oModelNSZ:SetValue("NSZ_DETALH", cDescSol                  )
			oModelNSZ:SetValue("NSZ_OBSERV", cObservacao               )
			oModelNSZ:SetValue("NSZ_RENOVA", cRenovAuto                )
			oModelNSZ:SetValue("NSZ_VLCONT", Val(cVlrContrato)         )
			oModelNSZ:SetValue("NSZ_DTINVI", CToD(cVigInicio)          )
			oModelNSZ:SetValue("NSZ_DTTMVI", CToD(cVigFim)             )
			oModelNSZ:SetValue("NSZ_FPGTO" , cCondPag                  )

			// Campos customizados - Contrato
			lRetorno := SetCposCustom(oModelNSZ, aCustomCpo, "C")

			//--------------------------- ENVOLVIDOS ---------------------------------------------------//
			If lRetorno
				oModelNT9 = oModel:GetModel( 'NT9DETAIL' )
				
				for nI := 1 to oModelNT9:Length(.T.)
					oModelNT9:GoLine(nI)

					If oModelNT9:GetValue("NT9_TIPOEN", nI) == '1' // Polo Ativo
						J105SetDados(cEntPAtivo, cPAtivo)
						oModelNT9:SetValue("NT9_ENTIDA", cEntPAtivo)
						oModelNT9:SetValue("NT9_CODENT", cPAtivo)
						lRetorno := SetCposCustom(oModelNT9, aCustomCpo, "A")

					ElseIf oModelNT9:GetValue("NT9_TIPOEN", nI) == '2' // Polo Passivo
						J105SetDados(cEntPPassivo, cPPassivo)
						oModelNT9:SetValue("NT9_ENTIDA", cEntPPassivo)
						oModelNT9:SetValue("NT9_CODENT", cPPassivo)
						lRetorno := SetCposCustom(oModelNT9, aCustomCpo, "P")
					EndIf

					If !lRetorno
						Exit
					EndIf
				next nI
			EndIf

			// Ponto de entrada - Cadastro de Contrato.
			// oModel - Modelo da JURA095
			If Existblock( 'JWSFLGCCNT' )
				Execblock('JWSFLGCCNT', .F., .F., {@oModel, aCustomCpo})
			EndIf

			If !( oModel:VldData() ) .Or. !( oModel:CommitData() )
				cRet := STR0020 + CRLF  // "Erro: "
				cRet += STR0021 + oModel:aErrorMessage[4] + CRLF + ; // "Campo: "
						STR0022 + oModel:aErrorMessage[5] + CRLF + ; // "Razao: "
						CRLF + oModel:aErrorMessage[6] + CRLF

				SetSoapFault("MTAtualizaContrato", cRet)
				JurConOut(cRet)
				lRetorno := .F.
			EndIf

			oModel:DeActivate()
			oModel:Destroy()
		EndIf

	EndIf

	self:Ok := lRetorno
	End Sequence

Return (lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} JInsNewEnv
Função responsável por cadastrar uma nova parte contrária

@param cTipoEnv: : Tipo de envolvido
@param cCGC      : CNPJ ou CPF
@param cNome     : Nome do envolvido
@param cUF       : Estado
@param cCEP      : CEP
@param cMunic    : Município
@param cEndereco : Endereço
@param cBairro   : Bairro
@param lPoloAtivo: É polo ativo?

@since   17/12/2020
*/
//-------------------------------------------------------------------
Function JInsNewEnv(cTipoEnv, cCGC, cNome, cUF, cCEP, cMunic, cEndereco, cBairro, lPoloAtivo)
Local cEntidade  := ''
Local cPolo      := ''
Local cRet       := ''
Local cMunicipio := JurGetDados( "CC2", 4, xFilial("CC2") + UPPER(cUF) + UPPER(cMunic), "CC2_CODMUN")

	If cTipoEnv == '1'
		If Empty(AllTrim(cCGC))
			cCGC := '00000000000'
		EndIf
	ElseIf cTipoEnv == '2'
		If Empty(AllTrim(cCGC))
			cCGC := '00000000000000'
		EndIf
	EndIf

	cCEP := StrTran( cCEP, '-', '')
	cCGC := StrTran( StrTran(cCGC, '-', '') , '.', '')

	oModel184 := FWLoadModel("JURA184") // Partes Contrárias
	oModel184:SetOperation( 3 )  //Inclusao
	oModel184:Activate()

	oModel184:SetValue( "NZ2MASTER","NZ2_NOME"  , cNome      )
	oModel184:SetValue( "NZ2MASTER","NZ2_TIPOP" , cTipoEnv  )
	oModel184:SetValue( "NZ2MASTER","NZ2_CGC"   , cCGC       )
	oModel184:SetValue( "NZ2MASTER","NZ2_ESTADO", cUF        )
	oModel184:SetValue( "NZ2MASTER","NZ2_CMUNIC", cMunicipio )
	oModel184:SetValue( "NZ2MASTER","NZ2_CEP"   , cCEP       )
	oModel184:SetValue( "NZ2MASTER","NZ2_ENDE"  , cEndereco  )
	oModel184:SetValue( "NZ2MASTER","NZ2_BAIRRO", cBairro    )

	If !( oModel184:VldData()) .Or. !( oModel184:CommitData())
		cRet := STR0020 + CRLF  // "Erro: "
		cRet += STR0021 + oModel184:aErrorMessage[4] + CRLF + ; // "Campo: "
				STR0022 + oModel184:aErrorMessage[5] + CRLF + ; // "Razao: "
				CRLF + oModel184:aErrorMessage[6] + CRLF
		Break
	EndIf

	If lPoloAtivo
		cEntidade  := 'NZ2'
		cPolo := oModel184:GetValue( "NZ2MASTER","NZ2_COD" )
	Else
		cEntidade  := 'NZ2'
		cPolo := oModel184:GetValue( "NZ2MASTER","NZ2_COD" )
	EndIf

	oModel184:DeActivate()
	
Return {cRet, {lPoloAtivo, cEntidade, cPolo} }

// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/{Protheus.doc} SetCposCustom
Seta os campos customizados

@param  oSubMdl  - Submodelo
@param  aCampos  - Array campos customizados
@param  cTipo    - Grupo que irá setar os valores (C-Contrato, A-Polo Ativo, P-Polo Passivo)
@return lRet     - Indica se setou o campo
@since 21/01/2021
/*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Static Function SetCposCustom(oSubMdl, aCampos, cTipo)

Local lRet   := .T.
Local nl     := 0
Local cTipoC := ""
Local cCampo := ""
Local xValor := ""

Default oSubMdl := Nil
Default aCampos := {}
Default cTipo   := ""

For nl:= 1 to len(aCampos)
	cTipoC := SubStr(aCampos[nl]:cCampo,1,1)

	If cTipoC == cTipo
		cTipoC := SubStr(aCampos[nl]:cCampo,2,1)
		cCampo := AllTrim(SubStr(aCampos[nl]:cCampo,3,15))
		xValor := CastType(aCampos[nl]:cValor, cTipoC)
		if !Empty(xValor) .And. oSubMdl:HasField(cCampo)
			lRet := oSubMdl:SetValue( cCampo, xValor)
		Endif
	EndIf

	If !lRet
		Exit
	EndIf
Next

Return lRet

// ____________________________________________________________________________
/*
{Protheus.doc} MTAtualizaSigla2
Metodo para obter o CPF do responsável a partir do e-mail.

@class   WSFluigJuridico
@param   cEmail             - E-email do executor Fluig
@param   Escritorio         - Escritório
@param   CodAssuntoJuridico - Cajuri
@author  nishizaka.cristiane
@version 1.0
@since   21/10/2021
@return  .T./ .F. setou sigla2
*/
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
WSMETHOD MTAtualizaSigla2 ;
WSRECEIVE	cEmail, Escritorio, CodAssuntoJuridico;
WSSEND		Ok ;
WSSERVICE	wsfluigjuridico

Local oModel       := Nil
Local lRetorno     := .T.
Local cCajuri      := self:CodAssuntoJuridico
Local cResp        := self:cEmail
Local cSigla       := ""
Local cRet         := ""

Private cTipoAsj   := ""
Public c162TipoAs  := ''


	//Atualiza a filial do ambiente para a filial do escritorio ou do parâmetro
	If !AbreFilial(self:Escritorio)
		lRetorno := .F.
		Break
	EndIf

	DbSelectArea("NSZ")
	NSZ->(DbSetOrder(1)) //NSZ_FILIAL+NSZ_COD

	If dbSeek(xFilial("NSZ") + cCajuri)
		c162TipoAs := NSZ->NSZ_TIPOAS
		cTipoAsJ   := NSZ->NSZ_TIPOAS

		oModel := FWLoadModel("JURA095")
		oModel:SetOperation( 4 ) //Alteração
		oModel:Activate()

		If '@' $ cResp
			cSigla := AllTrim(JurGetDados("RD0", 7, xFilial("RD0")+ALLTRIM(UPPER(cResp)), "RD0_SIGLA"))
			oModel:SetValue( "NSZMASTER","NSZ_SIGLA2", cSigla)
		Else
			SetSoapFault("MTAtualizaSigla2", STR0046) //"Não foi possível identificar a sigla do usuário Fluig. Verifique o cadastro de Participantes e tente novamente."
			JurConOut(STR0046) //"Não foi possível identificar a sigla do usuário Fluig. Verifique o cadastro de Participantes e tente novamente."
			lRetorno := .F.
			Break
		EndIf
	EndIf
	
	If !( oModel:VldData() ) .Or. !( oModel:CommitData() )
		cRet := STR0020 + CRLF  // "Erro: "
		cRet += STR0021 + oModel:aErrorMessage[4] + CRLF + ; // "Campo: "
				STR0022 + oModel:aErrorMessage[5] + CRLF + ; // "Razao: "
				CRLF + oModel:aErrorMessage[6] + CRLF

		SetSoapFault("MTAtualizaSigla2", cRet)
		JurConOut(cRet)
		lRetorno := .F.
		Break
	EndIf

	oModel:DeActivate()

	self:Ok := lRetorno

Return(lRetorno)
