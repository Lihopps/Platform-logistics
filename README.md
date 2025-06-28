# Platform Logistics

Adds Requester and Provider for Space Platform in order to building a fully automated,Space Platform logistic network

## Installation

[Download on the Mod Portal.](https://mods.factorio.com/mod/Platform_logistics)

## Usage

### Definition

![](graphics/gui/utility/tat-title.png)

Create a Platform network :\
[item=ptflog-requester] act as [item=requester-chest].\
[item=ptflog-provider] act as [item=passive-provider-chest].\
[item=space-platform-hub] act as [item=logistic-robot].\
\
Define request in [item=ptflog-requester] (section or by circuitry).\
[item=ptflog-provider] define providing item by read green and red signal.\
Platform are auto-scheduled to get items in [item=ptflog-provider] and then deposit to the [item=ptflog-requester].\
[img=utility/warning_icon]In the [item=ptflog-requester] if a section contain [virtual-signal=signal-no-entry], the section are not handled by the network.


