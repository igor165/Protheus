#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "OGX820.ch"
#Include 'tbiconn.ch'
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} OGX820SCH
Função para execução somente via Schedule.
Atualização do Plano de Vendas

@author tamyris.g	
@since 23/08/2018
@version P12
@type OGX820SCH()
/*/    
//-------------------------------------------------------------------

Function OGX820SCH()
   //MV_PAR01 – Unidade de Negocio De ?
   //MV_PAR02 – Unidade de Negocio Até ?
   //MV_PAR03 – Safra De ?
   //MV_PAR04 – Safra Até ?
   //MV_PAR05 – Grp Produto De ?
   //MV_PAR06 – Grp Produto Até ?
   //MV_PAR07 – Produto De ?
   //MV_PAR08 – Produto Até ?
     
   conout(" ********** INICIANDO PROCESSO ATUALIZAÇÃO DO PLANO DE VENDAS  *********  ")
   
   RPCSetType(3)  //Nao consome licenças
   
   conout("inicia")
   
   OGX820Exe(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08)
   
   conout(" ********** PROCESSO  FINALIZADO *********  ")
   
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Definição de função padrão para o Schedule
@author  tamyris.g
@since   06/02/2019
@version version
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
   Local aOrd := {}
   Local aParam := {}
   
   aParam := {"R"       ,;    //Processo
              "OGX820"  ,;    //PERGUNTE OU PARAMDEF
              ""        ,;    //ALIAS p/ relatorio
              aOrd      ,;    //Array de Ordenacao p/ relatorio
              ""         }     //Titulo para Relatório
Return aParam
