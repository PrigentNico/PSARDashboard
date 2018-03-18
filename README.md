
# PSAR Dashboard

PowerShell Azure Reporting Dashboard

This dashboard will display all the information about your **Azure** subscription:

![## Navigating Between Pages](http://get-cmd.com/wp-content/uploads/2018/03/psar_menu.png)

 - Cost Consumption Usage 

![Azure Cost](http://get-cmd.com/wp-content/uploads/2018/03/psar_costpage2.png)

 - Virtual Machines usage

![Azure Virtual Machines](http://get-cmd.com/wp-content/uploads/2018/03/psar_vmusage2.png)

 - Networks usage
 - Storages usage

![Storage Accounts](http://get-cmd.com/wp-content/uploads/2018/03/psar_storagepage.png)


PSAR Dashboard is based on PoshUD.

**What is PoshUD?** 

Universal Dashboard is a cross-platform PowerShell module for developing and hosting web-based, interactive dashboards.  [https://www.poshud.com/Home](https://www.poshud.com/Home)

You must have a **valid** PoshUD license in order to run PSAR Dashboard.

**How to Run PSAR Dashboard?**

Before running PSAR Dashboard, you must install the PoshUD PowerShell Module.

    Install-Module  UniversalDashboard

More information here: http://get-cmd.com/?p=4623

Now, just run:

     .\PSarDashboard.ps1

Then you must open the your web browser and type:

> http://localhost:1002
