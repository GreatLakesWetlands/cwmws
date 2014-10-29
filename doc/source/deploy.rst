Deploying the system
====================

These instructions include sections only relevant to an installation on a virtual server  using the `QEMU <http://wiki.qemu.org/>`_ virtualizer.  Those sections are in boxes headed `Virtual machine`, they can be ignored if you're installing on a regular non-virtual system running Ubuntu.  In the `Virtual machine` sections, commands are to be run on the host system.  Commands outside the `Virtual machine` boxes should be run on the regular non-virtual system or the virtual guest system, whichever you're using.  Installation in a virtual machine is not necessarily recommended, in particular making an efficient network link from the internet to a virtual machine is not covered here.  The virtual machine deployment serves mostly to ensure that all required dependencies are documented.

These instructions to not include the ``mezzanine-project myproject`` step required to initialize a the mezzanine CMS from scratch, they assume an existing database will be used.

Create a directory to work in::
    
    ROOTDIR=/mnt/usr1/scratch/glwdeploy
    mkdir -p $ROOTDIR
    cd $ROOTDIR
    
.. topic:: Virtual machine

    Create a base image file, and boot with the Ubuntu 14.04 Server image::

        # name of base image file
        IMGFILE=glwdemo.qcow2
        
        qemu-img create -f qcow2 $IMGFILE 1024G
        
        # flags for qemu
        QFLAGS="-enable-kvm -m 4096 -smp 2 \
            -redir tcp:5555::80 -redir tcp:5800::8000 -redir tcp:2222::22"
        
        # location of the Ubuntu 14.04 server install image
        INST=/mnt/bkup/usr1proj/iso/ubuntu-14.04.1-server-amd64.iso
        
        qemu-system-x86_64 $QFLAGS -cdrom $INST -boot d $IMGFILE
        
    * default everything except username / password
    
    * disk setup: Guided - use entire disk (not bothering with LVM)
    
    * answer Yes (not default No) to write changes to disk
    
    * Install security updates automatically, or No automatic updates,
      as you prefer
    
    * Software selection - check OpenSSH server
    
    * reboots to install (language selection) again, just close the window

    Boot the system::

        # more flags now the display is not needed for the install step
        QFLAGS="$QFLAGS -display none -daemonize"

        qemu-system-x86_64 $QFLAGS $IMGFILE 
        ssh -p 2222 127.0.0.1

Log in and add ``GRUB_RECORDFAIL_TIMEOUT=10`` to ``/etc/default/grub`` to stop the
server waiting for input on reboot after an improper shutdown.  Then run these commands::
    
    sudo update-grub  # applies the timeout fix
    sudo apt-get update
    sudo apt-get upgrade

.. topic:: Virtual machine
    
    Create a snapshot to preserve this clean install.  
    Shut down the guest OS, then::
    
    
        # switch to a snapshot to preserve the clean base image
        BASEIMG=$IMGFILE
        IMGFILE=deploy_$BASEIMG
        qemu-img create -f qcow2 -b $BASEIMG $IMGFILE
        
    **Do NOT** boot the system on ``$BASEIMG`` again, that will invalidate 
    the ``$IMGFILE`` `snapshot <http://wiki.qemu.org/Documentation/CreateSnapshot>`_.
        
    Boot the system on the snapshot and log in::
        
        qemu-system-x86_64 $QFLAGS $IMGFILE 
        ssh -p 2222 127.0.0.1

Install needed components::
    
    sudo apt-get install python-virtualenv git screen unzip apache2
    
    # to get PIL (pillow) installation to work, thanks to
    # http://prateekvjoshi.com/2014/04/19/how-to-install-pil-on-ubuntu/
    sudo apt-get install python-dev libjpeg-dev libfreetype6-dev zlib1g-dev

.. topic:: Virtual machine

    The above causes a lot of installation, so make another level of snapshot for the
    more fiddly parts to follow.  Shut down the guest OS, then::
    
        BASEIMG=$IMGFILE
        IMGFILE=deploy2_$BASEIMG
        qemu-img create -f qcow2 -b $BASEIMG $IMGFILE

        qemu-system-x86_64 $QFLAGS $IMGFILE 
        ssh -p 2222 127.0.0.1

.. other thoughts - fail2ban, probably not, ufw status

Now deploy the Django Mezzanine project::
    
    mkdir glw
    cd glw
    virtualenv venv
    . venv/bin/activate
    pip install mezzanine
    
    git clone...
    
    cd dserver/cwmenduser/

At this point you need to create ``local_settings.py``, a file not included in the
``git`` repository, because it's supposed to contain local settings *including passwords and other sensitive information*.  You can generate values for the ``SECRET_KEY`` and ``NEVERCACHE_KEY`` variables with this command::

    python -c 'import uuid; print("".join(str(uuid.uuid4()) for i in range(3)))'

Copy ``local_settings.py.template`` to ``local_settings.py`` and
modify it appropriately, replacing the parts in <angle brackets>.
    
Finally, copy in glcw.db, supplied separately.  Then::
    
    python manage.py collectstatic
    python manage.py runserver 0.0.0.0:8000
    
At this point the website should be visible at http://127.0.0.1:8000
if using a regular non-virtual machine, and at http://127.0.0.1:5800 on the *host*
OS if using a virtual machine.

Apache for deploying the public website
+++++++++++++++++++++++++++++++++++++++

The original deployment of the site used `Apache <http://httpd.apache.org/>`_
and WSGI, see :ref:`django:daemon-mode`.

This assumes a regular non-virtual machine connected to the internet, 

Here's the Apache site definition needed to deploy the site::

    <VirtualHost *:80>
    
    ServerName www.greatlakeswetlands.org
    ServerAlias greatlakeswetlands.org *.greatlakeswetlands.org
    
    Alias /media/ /mnt/usr1/beav/site/esriapp/dserver/cwmenduser/media/
    Alias /static/ /mnt/usr1/beav/site/esriapp/dserver/cwmenduser/static/
    
    WSGIDaemonProcess pydaemon-glw_namebased processes=1 threads=5 python-path=/mnt/usr1/beav$
    
    WSGIScriptAlias / /mnt/usr1/beav/site/esriapp/dserver/cwmenduser/wsgi.py
    
    <Location />
    WSGIProcessGroup pydaemon-glw_namebased
    </Location>
    
    </VirtualHost>
    
This goes in ``/etc/apache2/sites-available``, e.g.
``/etc/apache2/sites-available/glw``, and is the sym-linked from
``/etc/apache2/sites-enabled``, e.g.
``/etc/apache2/sites-available/020-glw``. The ``020-`` just serves to
control the ordering of sites in the `enabled` directory.

``/mnt/usr1/beav/site/esriapp`` should be replaced with the path to
the directory when the ``git`` repository is cloned.
